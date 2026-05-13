import {setGlobalOptions} from "firebase-functions";
import {HttpsError, onCall, onRequest} from "firebase-functions/v2/https";
import {initializeApp} from "firebase-admin/app";
setGlobalOptions({maxInstances: 10});
initializeApp();

type SubmitVerificationRequest = {
  representativeName?: string;
  businessNumber?: string;
  openedOn?: string;
  licenseImageUrl?: string;
};

type SupabaseInsertResponse = {
  id: string;
};

type SupabaseUpdateResponse = {
  id: string;
  partner_status: string;
};

const PARTNER_STATUS_PENDING = "pending";

/**
 * Supabase REST API를 service role로 호출한다.
 * @param {string} path Supabase REST 경로
 * @param {"POST" | "PATCH"} method HTTP 메서드
 * @param {unknown} body 요청 본문
 * @return {Promise<T>} 응답 JSON
 */
async function supabaseRequest<T>(
  path: string,
  method: "GET" | "POST" | "PATCH" | "DELETE",
  body?: unknown,
): Promise<T> {
  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!supabaseUrl || !serviceRoleKey) {
    throw new HttpsError(
      "failed-precondition",
      "SUPABASE_URL 또는 SUPABASE_SERVICE_ROLE_KEY가 설정되지 않았습니다.",
    );
  }

  const response = await fetch(`${supabaseUrl}/rest/v1/${path}`, {
    method,
    headers: {
      "Content-Type": "application/json",
      "apikey": serviceRoleKey,
      "Authorization": `Bearer ${serviceRoleKey}`,
      "Prefer": "return=representation",
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });

  if (!response.ok) {
    const responseText = await response.text();
    throw new HttpsError(
      "internal",
      `Supabase 요청 실패: ${response.status} ${responseText}`,
    );
  }

  const data = (await response.json()) as T;
  return data;
}

/**
 * 회원 탈퇴 시 Supabase 데이터만 삭제한다.
 * Firebase 사용자 삭제는 앱에서 재인증 직후 직접 수행한다.
 */
export const deleteAccountWithDataCleanup = onCall(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    await supabaseRequest<unknown[]>(
      `stores?owner_id=eq.${uid}`,
      "DELETE",
    );
    await supabaseRequest<unknown[]>(
      `owner_verifications?owner_id=eq.${uid}`,
      "DELETE",
    );
    await supabaseRequest<unknown[]>(
      `users?id=eq.${uid}`,
      "DELETE",
    );

    return {
      success: true,
    };
  },
);

/**
 * 관리자 사업자 인증 정보를 저장하고 사용자 상태를 pending으로 갱신한다.
 */
export const submitPartnerVerification = onCall(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const data = (request.data ?? {}) as SubmitVerificationRequest;
    const representativeName = (data.representativeName ?? "").trim();
    const businessNumber = (data.businessNumber ?? "").replace(/[^0-9]/g, "");
    const openedOn = (data.openedOn ?? "").trim();
    const licenseImageUrl = (data.licenseImageUrl ?? "").trim();

    if (!representativeName) {
      throw new HttpsError("invalid-argument", "대표자명을 입력해 주세요.");
    }
    if (!/^\d{10}$/.test(businessNumber)) {
      throw new HttpsError(
        "invalid-argument",
        "사업자등록번호는 숫자 10자리여야 합니다.",
      );
    }
    if (!openedOn) {
      throw new HttpsError("invalid-argument", "개업일자를 입력해 주세요.");
    }
    if (!licenseImageUrl) {
      throw new HttpsError("invalid-argument", "등록증 이미지가 필요합니다.");
    }

    const verificationInsertResponse = await supabaseRequest<
      SupabaseInsertResponse[]
    >(
      "owner_verifications",
      "POST",
      {
        owner_id: uid,
        representative_name: representativeName,
        business_number: businessNumber,
        opened_on: openedOn,
        license_file_url: licenseImageUrl,
        status: PARTNER_STATUS_PENDING,
      },
    );

    if (verificationInsertResponse.length == 0) {
      throw new HttpsError(
        "internal",
        "사업자 인증 정보 저장에 실패했습니다.",
      );
    }

    const userUpdateResponse = await supabaseRequest<SupabaseUpdateResponse[]>(
      `users?id=eq.${uid}`,
      "PATCH",
      {
        partner_status: PARTNER_STATUS_PENDING,
      },
    );

    if (
      userUpdateResponse.length == 0 ||
      userUpdateResponse[0].partner_status != PARTNER_STATUS_PENDING
    ) {
      throw new HttpsError(
        "internal",
        "사용자 상태를 pending으로 변경하지 못했습니다.",
      );
    }

    return {
      success: true,
      partnerStatus: PARTNER_STATUS_PENDING,
      verificationId: verificationInsertResponse[0].id,
    };
  },
);

type ApprovePartnerForDemoRequest = {
  targetUid?: string;
  demoKey?: string;
};

type RejectPartnerForDemoRequest = {
  targetUid?: string;
  demoKey?: string;
};

type UploadStoreImageRequest = {
  storeId?: string;
  bucketId?: string;
  fileBase64?: string;
  fileExtension?: string;
  contentType?: string;
};

type DeleteStoreImageRequest = {
  storeId?: string;
  bucketId?: string;
  objectPath?: string;
};

type StoreOwnershipResponse = {
  id: string;
};

type StartStudyCafeUsageRequest = {
  storeId?: string;
  seatId?: string;
  durationMinutes?: number;
};

type ExtendStudyCafeUsageRequest = {
  reservationId?: string;
  additionalMinutes?: number;
};

type AcquireStudycafeSeatHoldRequest = {
  storeId?: string;
  seatId?: string;
  holdMinutes?: number;
};

type ReleaseStudycafeSeatHoldRequest = {
  holdId?: string;
};

type StudyCafeSeatHoldResponse = {
  id: string;
  store_id: string;
  user_id: string;
  seat_id: string;
  expires_at: string;
  status: string;
  created_at?: string;
  updated_at?: string;
};

type CreateSalonReservationRequest = {
  storeId?: string;
  designerId?: string;
  serviceId?: string;
  startAt?: string;
};

type SalonDesignerPayload = {
  id?: string;
  name?: string;
  introduction?: string;
  imageUrl?: string;
  isActive?: boolean;
  sortOrder?: number;
};

type SaveSalonDesignersRequest = {
  storeId?: string;
  designers?: SalonDesignerPayload[];
};

type SalonServicePayload = {
  id?: string;
  name?: string;
  description?: string;
  durationMinutes?: number;
  price?: number;
  isActive?: boolean;
  sortOrder?: number;
};

type SaveSalonServicesRequest = {
  storeId?: string;
  services?: SalonServicePayload[];
};

type SalonDesignerSchedulePayload = {
  id?: string;
  designerId?: string;
  dayOfWeek?: number;
  isWorking?: boolean;
  startTime?: string;
  endTime?: string;
};

type SaveSalonDesignerSchedulesRequest = {
  storeId?: string;
  schedules?: SalonDesignerSchedulePayload[];
};

type SaveStudyCafeDetailRequest = {
  storeId?: string;
  layoutJson?: {
    seats?: unknown[];
    elements?: unknown[];
  };
  usageOptions?: unknown[];
};

type StudyCafeReservationResponse = {
  id: string;
  store_id: string;
  user_id: string;
  seat_id: string;
  duration_minutes: number;
  start_at: string;
  end_at: string;
  status: string;
};

type SalonReservationResponse = {
  id: string;
  store_id: string;
  user_id: string;
  designer_id: string;
  service_id: string;
  start_at: string;
  end_at: string;
  slot_minutes?: number;
  status: string;
};

type SalonDesignerResponse = {
  id: string;
  store_id: string;
  name: string;
  introduction: string;
  image_url: string;
  is_active: boolean;
  sort_order: number;
  created_at?: string;
  updated_at?: string;
};

type SalonServiceResponse = {
  id: string;
  store_id: string;
  name: string;
  description: string;
  duration_minutes: number;
  price: number;
  is_active: boolean;
  sort_order: number;
  created_at?: string;
  updated_at?: string;
};

type SalonDesignerScheduleResponse = {
  id: string;
  designer_id: string;
  day_of_week: number;
  is_working: boolean;
  start_time: string;
  end_time: string;
  created_at?: string;
  updated_at?: string;
};

type StudyCafeDetailResponse = {
  id: string;
  store_id: string;
  layout_json: {
    seats?: unknown[];
    elements?: unknown[];
  };
  usage_options: unknown[];
  created_at: string;
  updated_at: string;
};

const STORE_IMAGE_BUCKET = "store_images";
const STORE_MENU_IMAGE_BUCKET = "store_menu_images";
const SALON_DESIGNER_IMAGE_BUCKET = "salon_designer_images";
const MAX_IMAGE_UPLOAD_BYTES = 5 * 1024 * 1024;
const ALLOWED_IMAGE_MIME_TYPES = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
]);

/**
 * RPC 응답이 배열 또는 단일 객체일 수 있어 단일 객체로 정규화한다.
 * @param {T | T[]} response RPC 응답 본문
 * @param {string} errorMessage 빈 배열일 때 반환할 에러 메시지
 * @return {T} 정규화된 단일 응답 객체
 */
function normalizeRpcRow<T>(response: T | T[], errorMessage: string): T {
  if (Array.isArray(response)) {
    if (response.length === 0) {
      throw new HttpsError("internal", errorMessage);
    }
    return response[0];
  }
  return response;
}

const MIME_TO_EXTENSIONS: Record<string, string[]> = {
  "image/jpeg": ["jpg", "jpeg"],
  "image/png": ["png"],
  "image/webp": ["webp"],
};

/**
 * 업로드 바이트의 매직 넘버를 기반으로 이미지 MIME 타입을 추정한다.
 * @param {Buffer} fileBytes 업로드 파일 바이트
 * @return {string | null} 추정 MIME 타입
 */
function detectImageMimeType(fileBytes: Buffer): string | null {
  // JPEG: FF D8 FF
  if (
    fileBytes.length >= 3 &&
    fileBytes[0] === 0xff &&
    fileBytes[1] === 0xd8 &&
    fileBytes[2] === 0xff
  ) {
    return "image/jpeg";
  }

  // PNG: 89 50 4E 47 0D 0A 1A 0A
  if (
    fileBytes.length >= 8 &&
    fileBytes[0] === 0x89 &&
    fileBytes[1] === 0x50 &&
    fileBytes[2] === 0x4e &&
    fileBytes[3] === 0x47 &&
    fileBytes[4] === 0x0d &&
    fileBytes[5] === 0x0a &&
    fileBytes[6] === 0x1a &&
    fileBytes[7] === 0x0a
  ) {
    return "image/png";
  }

  // WEBP: "RIFF" + .... + "WEBP"
  if (
    fileBytes.length >= 12 &&
    fileBytes[0] === 0x52 &&
    fileBytes[1] === 0x49 &&
    fileBytes[2] === 0x46 &&
    fileBytes[3] === 0x46 &&
    fileBytes[8] === 0x57 &&
    fileBytes[9] === 0x45 &&
    fileBytes[10] === 0x42 &&
    fileBytes[11] === 0x50
  ) {
    return "image/webp";
  }

  return null;
}

/**
 * 사용자 입력 파일 메타데이터를 검증하고 서버 기준 값으로 정규화한다.
 * @param {string} requestedContentType 사용자 요청 MIME 타입
 * @param {string} requestedExtension 사용자 요청 확장자
 * @param {Buffer} fileBytes 업로드 파일 바이트
 * @return {{contentType: string, fileExtension: string}} 정규화된 메타데이터
 */
function validateAndNormalizeImageMetadata({
  requestedContentType,
  requestedExtension,
  fileBytes,
}: {
  requestedContentType: string;
  requestedExtension: string;
  fileBytes: Buffer;
}): {
  contentType: string;
  fileExtension: string;
} {
  const normalizedContentType = requestedContentType.trim().toLowerCase();
  if (!ALLOWED_IMAGE_MIME_TYPES.has(normalizedContentType)) {
    throw new HttpsError("invalid-argument", "허용되지 않은 MIME 타입입니다.");
  }

  const detectedMimeType = detectImageMimeType(fileBytes);
  if (!detectedMimeType) {
    throw new HttpsError(
      "invalid-argument",
      "지원하지 않는 이미지 형식입니다. (jpg, png, webp만 허용)",
    );
  }
  if (detectedMimeType !== normalizedContentType) {
    throw new HttpsError(
      "invalid-argument",
      "요청한 MIME 타입과 실제 파일 형식이 일치하지 않습니다.",
    );
  }

  const normalizedExtension = requestedExtension
    .trim()
    .toLowerCase()
    .replace(".", "");
  const allowedExtensions = MIME_TO_EXTENSIONS[normalizedContentType];
  if (!allowedExtensions.includes(normalizedExtension)) {
    throw new HttpsError(
      "invalid-argument",
      `MIME 타입과 확장자 조합이 올바르지 않습니다: ${normalizedContentType}`,
    );
  }

  return {
    contentType: normalizedContentType,
    fileExtension: allowedExtensions[0],
  };
}

/**
 * Storage object path를 URL-safe 형태로 인코딩한다.
 * @param {string} path 원본 object path
 * @return {string} 인코딩된 path
 */
function encodeStoragePath(path: string): string {
  return path
    .split("/")
    .map((segment) => encodeURIComponent(segment))
    .join("/");
}

/**
 * Supabase Storage REST API로 파일을 업로드하고 public URL을 반환한다.
 * @param {string} bucketId 업로드 대상 버킷
 * @param {string} objectPath 버킷 내부 object path
 * @param {Buffer} fileBytes 업로드할 파일 바이트
 * @param {string} contentType 파일 MIME 타입
 * @return {Promise<string>} 업로드된 파일의 public URL
 */
async function uploadToSupabaseStorage({
  bucketId,
  objectPath,
  fileBytes,
  contentType,
}: {
  bucketId: string;
  objectPath: string;
  fileBytes: Buffer;
  contentType: string;
}): Promise<string> {
  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !serviceRoleKey) {
    throw new HttpsError(
      "failed-precondition",
      "SUPABASE_URL 또는 SUPABASE_SERVICE_ROLE_KEY가 설정되지 않았습니다.",
    );
  }

  const encodedPath = encodeStoragePath(objectPath);
  const fileArrayBuffer = fileBytes.buffer.slice(
    fileBytes.byteOffset,
    fileBytes.byteOffset + fileBytes.byteLength,
  ) as ArrayBuffer;

  const uploadResponse = await fetch(
    `${supabaseUrl}/storage/v1/object/${bucketId}/${encodedPath}`,
    {
      method: "POST",
      headers: {
        "Content-Type": contentType,
        "apikey": serviceRoleKey,
        "Authorization": `Bearer ${serviceRoleKey}`,
        "x-upsert": "true",
      },
      body: fileArrayBuffer,
    },
  );

  if (!uploadResponse.ok) {
    const responseText = await uploadResponse.text();
    throw new HttpsError(
      "internal",
      `스토리지 업로드 실패: ${uploadResponse.status} ${responseText}`,
    );
  }

  return `${supabaseUrl}/storage/v1/object/public/${bucketId}/${encodedPath}`;
}

/**
 * Supabase Storage REST API에서 object를 삭제한다.
 * @param {string} bucketId 삭제 대상 버킷
 * @param {string} objectPath 버킷 내부 object path
 * @return {Promise<void>} 삭제 완료
 */
async function deleteFromSupabaseStorage({
  bucketId,
  objectPath,
}: {
  bucketId: string;
  objectPath: string;
}): Promise<void> {
  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !serviceRoleKey) {
    throw new HttpsError(
      "failed-precondition",
      "SUPABASE_URL 또는 SUPABASE_SERVICE_ROLE_KEY가 설정되지 않았습니다.",
    );
  }

  const encodedPath = encodeStoragePath(objectPath);
  const deleteResponse = await fetch(
    `${supabaseUrl}/storage/v1/object/${bucketId}/${encodedPath}`,
    {
      method: "DELETE",
      headers: {
        "apikey": serviceRoleKey,
        "Authorization": `Bearer ${serviceRoleKey}`,
      },
    },
  );
  if (!deleteResponse.ok) {
    const responseText = await deleteResponse.text();
    throw new HttpsError(
      "internal",
      `스토리지 삭제 실패: ${deleteResponse.status} ${responseText}`,
    );
  }
}

/**
 * 요청 사용자가 해당 업장의 소유자인지 확인한다.
 * @param {string} storeId 업장 ID
 * @param {string} uid Firebase UID
 * @return {Promise<void>} 소유자 검증 완료
 */
async function assertStoreOwnership(
  storeId: string,
  uid: string,
): Promise<void> {
  const stores = await supabaseRequest<StoreOwnershipResponse[]>(
    `stores?id=eq.${storeId}&owner_id=eq.${uid}&select=id&limit=1`,
    "GET",
  );
  if (stores.length === 0) {
    throw new HttpsError("permission-denied", "업장 소유자가 아닙니다.");
  }
}

export const startStudyCafeUsage = onCall(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const data = (request.data ?? {}) as StartStudyCafeUsageRequest;
    const storeId = (data.storeId ?? "").trim();
    const seatId = (data.seatId ?? "").trim();
    const durationMinutes = Number(data.durationMinutes ?? 0);

    if (!storeId || !seatId || !Number.isInteger(durationMinutes)) {
      throw new HttpsError("invalid-argument", "필수 파라미터가 누락되었습니다.");
    }
    if (durationMinutes <= 0) {
      throw new HttpsError("invalid-argument", "이용 시간은 0분보다 커야 합니다.");
    }

    try {
      const reservation = await supabaseRequest<
        StudyCafeReservationResponse | StudyCafeReservationResponse[]
      >(
        "rpc/start_studycafe_usage",
        "POST",
        {
          p_store_id: storeId,
          p_user_id: uid,
          p_seat_id: seatId,
          p_duration_minutes: durationMinutes,
        },
      );
      return normalizeRpcRow(reservation, "스터디카페 이용 시작에 실패했습니다.");
    } catch (e) {
      const message = e instanceof HttpsError ? e.message : "";
      if (message.includes("seat_held_by_other")) {
        throw new HttpsError(
          "failed-precondition",
          "다른 사용자가 해당 좌석을 선택 중입니다.",
        );
      }
      throw e;
    }
  },
);

export const extendStudyCafeUsage = onCall(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const data = (request.data ?? {}) as ExtendStudyCafeUsageRequest;
    const reservationId = (data.reservationId ?? "").trim();
    const additionalMinutes = Number(data.additionalMinutes ?? 0);

    if (!reservationId || !Number.isInteger(additionalMinutes)) {
      throw new HttpsError("invalid-argument", "필수 파라미터가 누락되었습니다.");
    }
    if (additionalMinutes <= 0) {
      throw new HttpsError("invalid-argument", "연장 시간은 0분보다 커야 합니다.");
    }

    const reservation = await supabaseRequest<
      StudyCafeReservationResponse | StudyCafeReservationResponse[]
    >(
      "rpc/extend_studycafe_usage",
      "POST",
      {
        p_reservation_id: reservationId,
        p_user_id: uid,
        p_additional_minutes: additionalMinutes,
      },
    );
    return normalizeRpcRow(reservation, "스터디카페 이용 연장에 실패했습니다.");
  },
);

export const acquireStudycafeSeatHold = onCall(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const data = (request.data ?? {}) as AcquireStudycafeSeatHoldRequest;
    const storeId = (data.storeId ?? "").trim();
    const seatId = (data.seatId ?? "").trim();
    const holdMinutes = Number(data.holdMinutes ?? 10);

    if (!storeId || !seatId || !Number.isInteger(holdMinutes)) {
      throw new HttpsError("invalid-argument", "필수 파라미터가 누락되었습니다.");
    }
    if (holdMinutes < 1 || holdMinutes > 60) {
      throw new HttpsError(
        "invalid-argument",
        "홀드 시간은 1분 이상 60분 이하여야 합니다.",
      );
    }

    try {
      const hold = await supabaseRequest<
        StudyCafeSeatHoldResponse | StudyCafeSeatHoldResponse[]
      >(
        "rpc/acquire_studycafe_seat_hold",
        "POST",
        {
          p_store_id: storeId,
          p_user_id: uid,
          p_seat_id: seatId,
          p_hold_minutes: holdMinutes,
        },
      );
      return normalizeRpcRow(
        hold,
        "스터디카페 좌석 홀드를 획득하지 못했습니다.",
      );
    } catch (e) {
      const message = e instanceof HttpsError ? e.message : "";
      if (message.includes("seat_held_by_other")) {
        throw new HttpsError(
          "failed-precondition",
          "다른 사용자가 해당 좌석을 선택 중입니다.",
        );
      }
      if (message.includes("seat_already_reserved")) {
        throw new HttpsError(
          "failed-precondition",
          "이미 예약된 좌석입니다.",
        );
      }
      throw e;
    }
  },
);

export const releaseStudycafeSeatHold = onCall(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const data = (request.data ?? {}) as ReleaseStudycafeSeatHoldRequest;
    const holdId = (data.holdId ?? "").trim();
    if (!holdId) {
      throw new HttpsError("invalid-argument", "holdId가 필요합니다.");
    }

    await supabaseRequest<boolean>(
      "rpc/release_studycafe_seat_hold",
      "POST",
      {
        p_hold_id: holdId,
        p_user_id: uid,
      },
    );
    return {success: true};
  },
);

export const createSalonReservation = onCall(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const data = (request.data ?? {}) as CreateSalonReservationRequest;
    const storeId = (data.storeId ?? "").trim();
    const designerId = (data.designerId ?? "").trim();
    const serviceId = (data.serviceId ?? "").trim();
    const startAt = (data.startAt ?? "").trim();

    if (!storeId || !designerId || !serviceId || !startAt) {
      throw new HttpsError("invalid-argument", "필수 파라미터가 누락되었습니다.");
    }

    try {
      const reservation = await supabaseRequest<
        SalonReservationResponse | SalonReservationResponse[]
      >(
        "rpc/create_salon_reservation",
        "POST",
        {
          p_store_id: storeId,
          p_user_id: uid,
          p_designer_id: designerId,
          p_service_id: serviceId,
          p_start_at: startAt,
        },
      );
      return normalizeRpcRow(reservation, "미용실 예약 생성에 실패했습니다.");
    } catch (e) {
      const message = e instanceof HttpsError ? e.message : "";
      if (message.includes("salon_slot_already_reserved")) {
        throw new HttpsError(
          "failed-precondition",
          "이미 예약된 시간입니다.",
        );
      }
      if (message.includes("salon_designer_not_working")) {
        throw new HttpsError(
          "failed-precondition",
          "선택한 시간에는 디자이너가 근무하지 않습니다.",
        );
      }
      if (message.includes("salon_start_time")) {
        throw new HttpsError(
          "failed-precondition",
          "선택한 시간이 예약 슬롯과 맞지 않습니다.",
        );
      }
      throw e;
    }
  },
);

export const saveSalonDesigners = onCall(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const data = (request.data ?? {}) as SaveSalonDesignersRequest;
    const storeId = (data.storeId ?? "").trim();
    const designers = Array.isArray(data.designers) ? data.designers : [];
    if (!storeId) {
      throw new HttpsError("invalid-argument", "storeId가 필요합니다.");
    }

    await assertStoreOwnership(storeId, uid);

    const saved: SalonDesignerResponse[] = [];
    for (const designer of designers) {
      const id = (designer.id ?? "").trim();
      const name = (designer.name ?? "").trim();
      if (!name) {
        throw new HttpsError("invalid-argument", "디자이너 이름이 필요합니다.");
      }
      const payload = {
        store_id: storeId,
        name,
        introduction: (designer.introduction ?? "").trim(),
        image_url: (designer.imageUrl ?? "").trim(),
        is_active: designer.isActive ?? true,
        sort_order: Number.isInteger(designer.sortOrder) ?
          designer.sortOrder :
          0,
        updated_at: new Date().toISOString(),
      };
      const rows = id ?
        await supabaseRequest<SalonDesignerResponse[]>(
          `salon_designers?id=eq.${id}&store_id=eq.${storeId}&select=*`,
          "PATCH",
          payload,
        ) :
        await supabaseRequest<SalonDesignerResponse[]>(
          "salon_designers?select=*",
          "POST",
          payload,
        );
      if (rows.length === 0) {
        throw new HttpsError("permission-denied", "디자이너 저장 권한이 없습니다.");
      }
      saved.push(rows[0]);
    }
    return saved;
  },
);

export const saveSalonServices = onCall(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const data = (request.data ?? {}) as SaveSalonServicesRequest;
    const storeId = (data.storeId ?? "").trim();
    const services = Array.isArray(data.services) ? data.services : [];
    if (!storeId) {
      throw new HttpsError("invalid-argument", "storeId가 필요합니다.");
    }

    await assertStoreOwnership(storeId, uid);

    const saved: SalonServiceResponse[] = [];
    for (const service of services) {
      const id = (service.id ?? "").trim();
      const name = (service.name ?? "").trim();
      const durationMinutes = Number(service.durationMinutes ?? 0);
      const price = Number(service.price ?? 0);
      if (!name || !Number.isInteger(durationMinutes) || durationMinutes <= 0) {
        throw new HttpsError("invalid-argument", "시술 정보가 올바르지 않습니다.");
      }
      if (!Number.isInteger(price) || price < 0) {
        throw new HttpsError("invalid-argument", "시술 가격이 올바르지 않습니다.");
      }
      const payload = {
        store_id: storeId,
        name,
        description: (service.description ?? "").trim(),
        duration_minutes: durationMinutes,
        price,
        is_active: service.isActive ?? true,
        sort_order: Number.isInteger(service.sortOrder) ? service.sortOrder : 0,
        updated_at: new Date().toISOString(),
      };
      const rows = id ?
        await supabaseRequest<SalonServiceResponse[]>(
          `salon_services?id=eq.${id}&store_id=eq.${storeId}&select=*`,
          "PATCH",
          payload,
        ) :
        await supabaseRequest<SalonServiceResponse[]>(
          "salon_services?select=*",
          "POST",
          payload,
        );
      if (rows.length === 0) {
        throw new HttpsError("permission-denied", "시술 저장 권한이 없습니다.");
      }
      saved.push(rows[0]);
    }
    return saved;
  },
);

export const saveSalonDesignerSchedules = onCall(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const data = (request.data ?? {}) as SaveSalonDesignerSchedulesRequest;
    const storeId = (data.storeId ?? "").trim();
    const schedules = Array.isArray(data.schedules) ? data.schedules : [];
    if (!storeId) {
      throw new HttpsError("invalid-argument", "storeId가 필요합니다.");
    }

    await assertStoreOwnership(storeId, uid);

    const saved: SalonDesignerScheduleResponse[] = [];
    for (const schedule of schedules) {
      const id = (schedule.id ?? "").trim();
      const designerId = (schedule.designerId ?? "").trim();
      const dayOfWeek = Number(schedule.dayOfWeek ?? -1);
      if (!designerId || !Number.isInteger(dayOfWeek) || dayOfWeek < 0 ||
        dayOfWeek > 6) {
        throw new HttpsError("invalid-argument", "근무표 정보가 올바르지 않습니다.");
      }

      const designers = await supabaseRequest<{id: string}[]>(
        `salon_designers?id=eq.${designerId}&store_id=eq.${storeId}` +
          "&select=id&limit=1",
        "GET",
      );
      if (designers.length === 0) {
        throw new HttpsError("permission-denied", "디자이너 저장 권한이 없습니다.");
      }

      const payload = {
        designer_id: designerId,
        day_of_week: dayOfWeek,
        is_working: schedule.isWorking ?? true,
        start_time: (schedule.startTime ?? "10:00").trim(),
        end_time: (schedule.endTime ?? "19:00").trim(),
        updated_at: new Date().toISOString(),
      };

      let targetId = id;
      if (!targetId) {
        const existingRows = await supabaseRequest<{id: string}[]>(
          `salon_designer_schedules?designer_id=eq.${designerId}` +
            `&day_of_week=eq.${dayOfWeek}&select=id&limit=1`,
          "GET",
        );
        targetId = existingRows[0]?.id ?? "";
      }

      const rows = targetId ?
        await supabaseRequest<SalonDesignerScheduleResponse[]>(
          `salon_designer_schedules?id=eq.${targetId}&select=*`,
          "PATCH",
          payload,
        ) :
        await supabaseRequest<SalonDesignerScheduleResponse[]>(
          "salon_designer_schedules?select=*",
          "POST",
          payload,
        );
      if (rows.length === 0) {
        throw new HttpsError("internal", "근무표 저장에 실패했습니다.");
      }
      saved.push(rows[0]);
    }
    return saved;
  },
);

export const saveStudyCafeDetail = onCall(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const data = (request.data ?? {}) as SaveStudyCafeDetailRequest;
    const storeId = (data.storeId ?? "").trim();
    if (!storeId) {
      throw new HttpsError("invalid-argument", "storeId가 필요합니다.");
    }

    await assertStoreOwnership(storeId, uid);

    const layoutJson = data.layoutJson ?? {};
    const seats = Array.isArray(layoutJson.seats) ? layoutJson.seats : [];
    const elements = Array.isArray(layoutJson.elements) ?
      layoutJson.elements :
      [];
    const usageOptions = Array.isArray(data.usageOptions) ?
      data.usageOptions :
      [];

    const nowIso = new Date().toISOString();
    const payload = {
      store_id: storeId,
      layout_json: {
        seats,
        elements,
      },
      usage_options: usageOptions,
      updated_at: nowIso,
    };

    const existingRows = await supabaseRequest<{id: string}[]>(
      `studycafe_detail?store_id=eq.${storeId}&select=id&limit=1`,
      "GET",
    );

    const detailRows = existingRows.length === 0 ?
      await supabaseRequest<StudyCafeDetailResponse[]>(
        "studycafe_detail?select=*",
        "POST",
        payload,
      ) :
      await supabaseRequest<StudyCafeDetailResponse[]>(
        `studycafe_detail?id=eq.${existingRows[0].id}&select=*`,
        "PATCH",
        payload,
      );

    if (detailRows.length === 0) {
      throw new HttpsError("internal", "스터디카페 상세 저장에 실패했습니다.");
    }

    return detailRows[0];
  },
);

/**
 * 데모용으로 특정 partner 사용자를 승인 상태로 변경한다.
 * @param {string} targetUid 승인할 사용자 UID
 * @param {string} demoKey 데모 승인용 임의 키
 * @return {Promise<void>} HTTP 응답
 */
export const approvePartnerForDemo = onRequest(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY", "DEMO_ADMIN_KEY"],
  },
  async (request, response) => {
    if (request.method !== "POST") {
      response.status(405).json({message: "POST 메서드만 허용됩니다."});
      return;
    }

    const body = (request.body ?? {}) as ApprovePartnerForDemoRequest;
    const targetUid = (body.targetUid ?? "").trim();
    const demoKey = (body.demoKey ?? "").trim();
    const expectedDemoKey = (process.env.DEMO_ADMIN_KEY ?? "").trim();

    if (!targetUid) {
      response.status(400).json({message: "targetUid가 필요합니다."});
      return;
    }
    if (!expectedDemoKey || demoKey !== expectedDemoKey) {
      response.status(403).json({message: "승인 키가 올바르지 않습니다."});
      return;
    }

    const users = await supabaseRequest<
      Array<{id: string; partner_status: string | null}>
    >(
      `users?id=eq.${targetUid}&select=id,partner_status`,
      "GET",
    );

    if (users.length === 0) {
      response.status(404).json({message: "대상 사용자를 찾지 못했습니다."});
      return;
    }

    const currentStatus = users[0].partner_status;
    if (currentStatus !== PARTNER_STATUS_PENDING) {
      response.status(409).json({
        message: `현재 상태(${currentStatus ?? "null"})에서는 승인할 수 없습니다.`,
      });
      return;
    }

    const updatedUsers = await supabaseRequest<
      Array<{id: string; partner_status: string}>
    >(
      `users?id=eq.${targetUid}`,
      "PATCH",
      {partner_status: "approved"},
    );

    const verificationFilter =
      `owner_verifications?owner_id=eq.${targetUid}` +
      `&status=eq.${PARTNER_STATUS_PENDING}`;
    await supabaseRequest(
      verificationFilter,
      "PATCH",
      {status: "approved"},
    );

    if (
      updatedUsers.length === 0 ||
      updatedUsers[0].partner_status !== "approved"
    ) {
      response.status(500).json({message: "사용자 승인 상태 변경에 실패했습니다."});
      return;
    }

    response.status(200).json({
      success: true,
      targetUid,
      beforeStatus: currentStatus,
      afterStatus: updatedUsers[0].partner_status,
    });
  },
);

/**
 * 데모용으로 특정 partner 사용자를 반려 상태로 변경한다.
 * @param {string} targetUid 반려할 사용자 UID
 * @param {string} demoKey 데모 승인용 임의 키
 * @return {Promise<void>} HTTP 응답
 */
export const rejectPartnerForDemo = onRequest(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY", "DEMO_ADMIN_KEY"],
  },
  async (request, response) => {
    if (request.method !== "POST") {
      response.status(405).json({message: "POST 메서드만 허용됩니다."});
      return;
    }

    const body = (request.body ?? {}) as RejectPartnerForDemoRequest;
    const targetUid = (body.targetUid ?? "").trim();
    const demoKey = (body.demoKey ?? "").trim();
    const expectedDemoKey = (process.env.DEMO_ADMIN_KEY ?? "").trim();

    if (!targetUid) {
      response.status(400).json({message: "targetUid가 필요합니다."});
      return;
    }
    if (!expectedDemoKey || demoKey !== expectedDemoKey) {
      response.status(403).json({message: "승인 키가 올바르지 않습니다."});
      return;
    }

    const users = await supabaseRequest<
      Array<{id: string; partner_status: string | null}>
    >(
      `users?id=eq.${targetUid}&select=id,partner_status`,
      "GET",
    );

    if (users.length === 0) {
      response.status(404).json({message: "대상 사용자를 찾지 못했습니다."});
      return;
    }

    const currentStatus = users[0].partner_status;
    if (currentStatus !== PARTNER_STATUS_PENDING) {
      response.status(409).json({
        message: `현재 상태(${currentStatus ?? "null"})에서는 반려할 수 없습니다.`,
      });
      return;
    }

    const updatedUsers = await supabaseRequest<
      Array<{id: string; partner_status: string}>
    >(
      `users?id=eq.${targetUid}`,
      "PATCH",
      {partner_status: "rejected"},
    );

    const verificationFilter =
      `owner_verifications?owner_id=eq.${targetUid}` +
      `&status=eq.${PARTNER_STATUS_PENDING}`;
    await supabaseRequest(
      verificationFilter,
      "PATCH",
      {status: "rejected"},
    );

    if (
      updatedUsers.length === 0 ||
      updatedUsers[0].partner_status !== "rejected"
    ) {
      response.status(500).json({message: "사용자 반려 상태 변경에 실패했습니다."});
      return;
    }

    response.status(200).json({
      success: true,
      targetUid,
      beforeStatus: currentStatus,
      afterStatus: updatedUsers[0].partner_status,
    });
  },
);

/**
 * 관리자 업장 이미지를 Firebase Functions 경유로 Supabase Storage에 업로드한다.
 */
export const uploadStoreImageToSupabase = onCall(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const data = (request.data ?? {}) as UploadStoreImageRequest;
    const storeId = (data.storeId ?? "").trim();
    const bucketId = (data.bucketId ?? "").trim();
    const fileBase64 = (data.fileBase64 ?? "").trim();
    const requestedFileExtension = (data.fileExtension ?? "jpg")
      .trim()
      .toLowerCase();
    const requestedContentType = (data.contentType ?? "image/jpeg").trim();

    if (!storeId || !bucketId || !fileBase64) {
      throw new HttpsError("invalid-argument", "필수 파라미터가 누락되었습니다.");
    }
    if (
      bucketId !== STORE_IMAGE_BUCKET &&
      bucketId !== STORE_MENU_IMAGE_BUCKET &&
      bucketId !== SALON_DESIGNER_IMAGE_BUCKET
    ) {
      throw new HttpsError("invalid-argument", "허용되지 않은 버킷입니다.");
    }

    await assertStoreOwnership(storeId, uid);

    let fileBytes: Buffer;
    try {
      fileBytes = Buffer.from(fileBase64, "base64");
    } catch (_) {
      throw new HttpsError("invalid-argument", "이미지 데이터 형식이 올바르지 않습니다.");
    }
    if (fileBytes.length === 0) {
      throw new HttpsError("invalid-argument", "이미지 데이터가 비어 있습니다.");
    }
    if (fileBytes.length > MAX_IMAGE_UPLOAD_BYTES) {
      throw new HttpsError(
        "invalid-argument",
        "이미지 파일 크기는 5MB를 초과할 수 없습니다.",
      );
    }

    const normalizedMetadata = validateAndNormalizeImageMetadata({
      requestedContentType,
      requestedExtension: requestedFileExtension,
      fileBytes,
    });

    const objectPath = `${storeId}/${Date.now()}.` +
      normalizedMetadata.fileExtension;
    const publicUrl = await uploadToSupabaseStorage({
      bucketId,
      objectPath,
      fileBytes,
      contentType: normalizedMetadata.contentType,
    });

    return {publicUrl};
  },
);

/**
 * 관리자 업장 이미지를 Firebase Functions 경유로 Supabase Storage에서 삭제한다.
 */
export const deleteStoreImageFromSupabase = onCall(
  {
    secrets: ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const data = (request.data ?? {}) as DeleteStoreImageRequest;
    const storeId = (data.storeId ?? "").trim();
    const bucketId = (data.bucketId ?? "").trim();
    const objectPath = (data.objectPath ?? "").trim();

    if (!storeId || !bucketId || !objectPath) {
      throw new HttpsError("invalid-argument", "필수 파라미터가 누락되었습니다.");
    }
    if (
      bucketId !== STORE_IMAGE_BUCKET &&
      bucketId !== STORE_MENU_IMAGE_BUCKET &&
      bucketId !== SALON_DESIGNER_IMAGE_BUCKET
    ) {
      throw new HttpsError("invalid-argument", "허용되지 않은 버킷입니다.");
    }

    await assertStoreOwnership(storeId, uid);
    await deleteFromSupabaseStorage({bucketId, objectPath});
    return {success: true};
  },
);
