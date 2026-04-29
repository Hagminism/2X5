import {setGlobalOptions} from "firebase-functions";
import {HttpsError, onCall, onRequest} from "firebase-functions/v2/https";
setGlobalOptions({maxInstances: 10});

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
  method: "GET" | "POST" | "PATCH",
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
