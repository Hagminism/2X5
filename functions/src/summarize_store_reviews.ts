import {createHash} from "crypto";
import {GoogleGenerativeAI} from "@google/generative-ai";
import {logger} from "firebase-functions";
import {HttpsError, onCall} from "firebase-functions/v2/https";

type ReviewSource = "platform" | "naver" | "google";

type ReviewSnippetInput = {
  source?: ReviewSource;
  rating?: number;
  text?: string;
  visitPurpose?: string;
};

type SummarizeStoreReviewsRequest = {
  storeId?: string;
  storeName?: string;
  contentHash?: string;
  reviews?: ReviewSnippetInput[];
};

type StoreReviewSummaryRow = {
  store_id: string;
  content_hash: string;
  summary_json: SummaryJson;
  model: string;
  review_counts: ReviewCounts;
  expires_at: string;
};

type SummaryJson = {
  oneLine: string;
  keywords: string[];
  positiveRatio: number;
};

type ReviewCounts = {
  internal: number;
  naver: number;
  google: number;
};

const SUMMARY_MODEL = "gemini-2.5-flash";
const CACHE_TTL_HOURS = 48;
const MAX_TEXT_LENGTH = 300;
const MAX_REVIEWS_PER_SOURCE = 50;

/**
 * Supabase REST API를 service role로 호출한다.
 * @param {string} path Supabase REST 경로
 * @param {"GET" | "POST" | "PATCH" | "DELETE"} method HTTP 메서드
 * @param {unknown} body 요청 본문
 * @param {string} prefer Prefer 헤더
 * @return {Promise<T>} 응답 JSON
 */
async function supabaseRequest<T>(
  path: string,
  method: "GET" | "POST" | "PATCH" | "DELETE",
  body?: unknown,
  prefer?: string,
): Promise<T> {
  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!supabaseUrl || !serviceRoleKey) {
    throw new HttpsError(
      "failed-precondition",
      "SUPABASE_URL 또는 SUPABASE_SERVICE_ROLE_KEY가 설정되지 않았습니다.",
    );
  }

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    "apikey": serviceRoleKey,
    "Authorization": `Bearer ${serviceRoleKey}`,
  };
  if (prefer) {
    headers.Prefer = prefer;
  }

  const response = await fetch(`${supabaseUrl}/rest/v1/${path}`, {
    method,
    headers,
    body: body === undefined ? undefined : JSON.stringify(body),
  });

  if (!response.ok) {
    const responseText = await response.text();
    throw new HttpsError(
      "internal",
      `Supabase 요청 실패: ${response.status} ${responseText}`,
    );
  }

  if (response.status === 204) {
    return [] as T;
  }

  return (await response.json()) as T;
}

/**
 * 리뷰 본문을 요약 입력 길이로 자른다.
 * @param {string} value 원본 텍스트
 * @return {string} 잘린 텍스트
 */
function truncateText(value: string): string {
  const trimmed = value.trim();
  if (trimmed.length <= MAX_TEXT_LENGTH) {
    return trimmed;
  }
  return `${trimmed.slice(0, MAX_TEXT_LENGTH)}…`;
}

/**
 * 리뷰 입력을 정규화하고 소스별 상한을 적용한다.
 * @param {ReviewSnippetInput[]} reviews 원본 리뷰 목록
 * @return {ReviewSnippetInput[]} 정규화된 리뷰 목록
 */
/**
 * Callable payload의 reviews 필드를 배열로 정규화한다.
 * @param {unknown} value 요청 reviews 필드
 * @return {ReviewSnippetInput[]} 리뷰 배열
 */
function coerceReviewsInput(value: unknown): ReviewSnippetInput[] {
  if (value == null) {
    return [];
  }
  if (!Array.isArray(value)) {
    throw new HttpsError(
      "invalid-argument",
      "reviews는 배열이어야 합니다.",
    );
  }
  return value as ReviewSnippetInput[];
}

/**
 * Gemini JSON 응답을 요약 객체로 파싱한다.
 * @param {string} rawText Gemini 원문
 * @return {Pick<SummaryJson, "oneLine" | "keywords">} 파싱된 요약
 */
function parseGeminiSummaryJson(
  rawText: string,
): Pick<SummaryJson, "oneLine" | "keywords"> {
  let parsed: unknown;
  try {
    parsed = JSON.parse(rawText);
  } catch {
    logger.error("Gemini JSON 파싱 실패", {
      rawPreview: rawText.slice(0, 500),
    });
    throw new HttpsError("internal", "Gemini 응답 JSON 파싱에 실패했습니다.");
  }

  if (parsed == null || typeof parsed !== "object" || Array.isArray(parsed)) {
    logger.error("Gemini JSON 형식 오류", {
      parsedType: parsed === null ? "null" : typeof parsed,
      rawPreview: rawText.slice(0, 500),
    });
    throw new HttpsError(
      "internal",
      "Gemini 응답 JSON 형식이 올바르지 않습니다.",
    );
  }

  const record = parsed as {oneLine?: unknown; keywords?: unknown};
  let oneLine = "";
  if (typeof record.oneLine === "string") {
    oneLine = record.oneLine.trim();
  }
  let keywords: string[] = [];
  if (Array.isArray(record.keywords)) {
    keywords = record.keywords
      .filter((item): item is string => typeof item === "string")
      .map((item) => item.trim())
      .filter((item) => item.length > 0)
      .slice(0, 3);
  }

  if (oneLine.length === 0) {
    logger.error("Gemini 요약 문장 누락", {
      rawPreview: rawText.slice(0, 500),
    });
    throw new HttpsError("internal", "요약 문장을 생성하지 못했습니다.");
  }

  if (keywords.length === 0) {
    return {
      oneLine,
      keywords: ["방문 후기", "서비스", "분위기"],
    };
  }

  return {oneLine, keywords};
}

/**
 * 리뷰 입력을 정규화하고 소스별 상한을 적용한다.
 * @param {ReviewSnippetInput[]} reviews 원본 리뷰 목록
 * @return {ReviewSnippetInput[]} 정규화된 리뷰 목록
 */
function normalizeReviews(reviews: ReviewSnippetInput[]): ReviewSnippetInput[] {
  const grouped: Record<ReviewSource, ReviewSnippetInput[]> = {
    platform: [],
    naver: [],
    google: [],
  };

  for (const review of reviews) {
    const source = review.source;
    if (source !== "platform" && source !== "naver" && source !== "google") {
      continue;
    }
    const text = truncateText(review.text ?? "");
    if (text.length === 0) {
      continue;
    }
    grouped[source].push({
      source,
      rating: review.rating,
      text,
      visitPurpose: review.visitPurpose?.trim(),
    });
  }

  return [
    ...grouped.platform.slice(0, MAX_REVIEWS_PER_SOURCE),
    ...grouped.naver.slice(0, MAX_REVIEWS_PER_SOURCE),
    ...grouped.google.slice(0, MAX_REVIEWS_PER_SOURCE),
  ];
}

/**
 * 해시 계산용 별점 문자열 (클라이언트와 동일 규칙).
 * @param {number | undefined} rating 별점
 * @return {string} 해시용 문자열
 */
function formatRatingForHash(rating: number | undefined): string {
  if (typeof rating !== "number" || Number.isNaN(rating)) {
    return "";
  }
  if (Number.isInteger(rating)) {
    return String(rating);
  }
  return String(rating);
}

/**
 * 리뷰 목록의 콘텐츠 해시를 계산한다.
 * @param {ReviewSnippetInput[]} reviews 리뷰 목록
 * @return {string} SHA-256 hex
 */
function computeContentHash(reviews: ReviewSnippetInput[]): string {
  const parts = reviews
    .map((review) => {
      const rating = formatRatingForHash(review.rating);
      const visitPurpose = review.visitPurpose ?? "";
      return `${review.source}|${rating}|${visitPurpose}|${review.text ?? ""}`;
    })
    .sort();
  return createHash("sha256").update(parts.join("\n"), "utf8").digest("hex");
}

/**
 * 소스별 리뷰 건수를 집계한다.
 * @param {ReviewSnippetInput[]} reviews 리뷰 목록
 * @return {ReviewCounts} 소스별 건수
 */
function countBySource(reviews: ReviewSnippetInput[]): ReviewCounts {
  return {
    internal: reviews.filter((item) => item.source === "platform").length,
    naver: reviews.filter((item) => item.source === "naver").length,
    google: reviews.filter((item) => item.source === "google").length,
  };
}

/**
 * 별점 4점 이상 비율을 계산한다.
 * @param {ReviewSnippetInput[]} reviews 리뷰 목록
 * @return {number} 긍정 비율 (0~1)
 */
function computePositiveRatio(reviews: ReviewSnippetInput[]): number {
  const rated = reviews.filter((item) => typeof item.rating === "number");
  if (rated.length === 0) {
    return 0.0;
  }
  const positive = rated.filter((item) => (item.rating ?? 0) >= 4).length;
  return positive / rated.length;
}

/**
 * 리뷰가 없을 때 반환할 기본 요약을 만든다.
 * @param {string} storeName 매장명
 * @return {SummaryJson} 빈 요약
 */
function emptySummary(storeName: string): SummaryJson {
  return {
    oneLine:
      `${storeName}은(는) 아직 등록된 리뷰가 많지 않아, ` +
      "리뷰가 쌓이면 방문 후기를 요약해 보여드릴 예정입니다.",
    keywords: ["방문 후기", "리뷰", "매장 평가"],
    positiveRatio: 0,
  };
}

/**
 * 유효한 캐시 요약을 조회한다.
 * @param {string} storeId 매장 ID
 * @param {string} contentHash 콘텐츠 해시
 * @return {Promise<StoreReviewSummaryRow | null>} 캐시 row
 */
async function fetchCachedSummary(
  storeId: string,
  contentHash: string,
): Promise<StoreReviewSummaryRow | null> {
  const selectColumns =
    "store_id,content_hash,summary_json,model,review_counts,expires_at";
  try {
    const rows = await supabaseRequest<StoreReviewSummaryRow[]>(
      "store_review_summaries" +
      `?store_id=eq.${encodeURIComponent(storeId)}` +
      `&content_hash=eq.${encodeURIComponent(contentHash)}` +
      `&select=${selectColumns}` +
      "&limit=1",
      "GET",
    );
    const row = rows[0];
    if (!row) {
      return null;
    }
    const expiresAt = Date.parse(row.expires_at);
    if (Number.isNaN(expiresAt) || expiresAt <= Date.now()) {
      return null;
    }
    return row;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    logger.warn("캐시 조회 실패, Gemini로 진행", {storeId, message});
    return null;
  }
}

/**
 * 요약 결과를 Supabase 캐시에 저장한다.
 * @param {StoreReviewSummaryRow} row 저장할 row
 * @return {Promise<void>}
 */
async function saveCachedSummary(row: StoreReviewSummaryRow): Promise<void> {
  try {
    await supabaseRequest<unknown[]>(
      "store_review_summaries?on_conflict=store_id",
      "POST",
      row,
      "resolution=merge-duplicates,return=minimal",
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    logger.warn("요약 캐시 저장 실패", {
      storeId: row.store_id,
      message,
    });
  }
}

/**
 * Gemini로 리뷰 요약 JSON을 생성한다.
 * @param {string} storeName 매장명
 * @param {ReviewSnippetInput[]} reviews 리뷰 목록
 * @return {Promise<Pick<SummaryJson, "oneLine" | "keywords">>} 요약
 */
async function generateSummaryWithGemini(
  storeName: string,
  reviews: ReviewSnippetInput[],
): Promise<Pick<SummaryJson, "oneLine" | "keywords">> {
  const apiKey = (process.env.GEMINI_API_KEY ?? "").trim();
  if (apiKey.length === 0) {
    throw new HttpsError(
      "failed-precondition",
      "GEMINI_API_KEY가 설정되지 않았습니다.",
    );
  }

  const promptPayload = reviews.map((review) => ({
    source: review.source,
    rating: review.rating ?? null,
    visitPurpose: review.visitPurpose ?? null,
    text: review.text,
  }));

  const prompt =
    "당신은 매장 리뷰 분석가입니다. 아래 JSON 배열은 플랫폼·네이버·구글 리뷰입니다.\n" +
    "사실을 과장하지 말고 리뷰에 근거해 한국어로 요약하세요.\n" +
    "개인정보·비속어는 인용하지 마세요.\n" +
    `매장명: ${storeName}\n` +
    `리뷰 데이터: ${JSON.stringify(promptPayload)}\n` +
    "다음 JSON만 출력하세요:\n" +
    "{\"oneLine\":\"한 문장 요약\"," +
    "\"keywords\":[\"키워드1\",\"키워드2\",\"키워드3\"]}";

  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({
    model: SUMMARY_MODEL,
    generationConfig: {
      responseMimeType: "application/json",
    },
  });

  let rawText: string;
  try {
    const result = await model.generateContent(prompt);
    rawText = result.response.text().trim();
    if (rawText.length === 0) {
      throw new HttpsError("internal", "Gemini 응답 본문이 비어 있습니다.");
    }
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }
    const geminiError =
      error instanceof Error ? error.message : String(error);
    logger.error("Gemini API 호출 실패", {
      storeName,
      geminiError,
      reviewCount: reviews.length,
    });
    throw new HttpsError(
      "internal",
      `Gemini 요약 생성 실패: ${geminiError}`,
    );
  }

  return parseGeminiSummaryJson(rawText);
}

export const summarizeStoreReviews = onCall(
  {
    secrets: [
      "SUPABASE_URL",
      "SUPABASE_SERVICE_ROLE_KEY",
      "GEMINI_API_KEY",
    ],
    timeoutSeconds: 120,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    try {
      const data = (request.data ?? {}) as SummarizeStoreReviewsRequest;
      const storeId = (data.storeId ?? "").trim();
      const storeName = (data.storeName ?? "").trim() || "이 매장";
      const clientHash = (data.contentHash ?? "").trim();
      const normalizedReviews = normalizeReviews(
        coerceReviewsInput(data.reviews),
      );

      if (!storeId) {
        throw new HttpsError("invalid-argument", "storeId가 필요합니다.");
      }

      const reviewCounts = countBySource(normalizedReviews);
      if (normalizedReviews.length === 0) {
        return {
          cacheHit: false,
          summary: emptySummary(storeName),
          reviewCounts,
        };
      }

      const contentHash = computeContentHash(normalizedReviews);
      if (clientHash.length > 0 && clientHash !== contentHash) {
        logger.warn("contentHash 불일치", {
          storeId,
          uid,
          clientHash,
          serverHash: contentHash,
          reviewCount: normalizedReviews.length,
        });
        throw new HttpsError(
          "invalid-argument",
          "리뷰 데이터가 변경되었습니다.",
        );
      }

      const cached = await fetchCachedSummary(storeId, contentHash);
      if (cached) {
        logger.info("리뷰 요약 캐시 히트", {storeId, contentHash});
        return {
          cacheHit: true,
          summary: cached.summary_json,
          reviewCounts: cached.review_counts,
        };
      }

      logger.info("리뷰 요약 Gemini 생성 시작", {
        storeId,
        reviewCount: normalizedReviews.length,
        reviewCounts,
      });

      const generated = await generateSummaryWithGemini(
        storeName,
        normalizedReviews,
      );
      const summary: SummaryJson = {
        oneLine: generated.oneLine,
        keywords: generated.keywords,
        positiveRatio: computePositiveRatio(normalizedReviews),
      };

      const expiresAt = new Date(
        Date.now() + CACHE_TTL_HOURS * 60 * 60 * 1000,
      ).toISOString();

      await saveCachedSummary({
        store_id: storeId,
        content_hash: contentHash,
        summary_json: summary,
        model: SUMMARY_MODEL,
        review_counts: reviewCounts,
        expires_at: expiresAt,
      });

      return {
        cacheHit: false,
        summary,
        reviewCounts,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }
      const message = error instanceof Error ? error.message : String(error);
      const stack = error instanceof Error ? error.stack : undefined;
      logger.error("summarizeStoreReviews 처리 중 예외", {
        uid,
        errorMessage: message,
        stack,
      });
      throw new HttpsError("internal", "리뷰 요약 처리 중 오류가 발생했습니다.");
    }
  },
);

export const invalidateStoreReviewSummary = onCall(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"],
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const requestData = (request.data ?? {}) as {storeId?: string};
    const storeId = requestData.storeId?.trim();
    if (!storeId) {
      throw new HttpsError("invalid-argument", "storeId가 필요합니다.");
    }

    await supabaseRequest<unknown[]>(
      `store_review_summaries?store_id=eq.${encodeURIComponent(storeId)}`,
      "DELETE",
    );

    return {success: true};
  },
);
