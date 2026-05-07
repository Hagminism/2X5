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

const STORE_IMAGE_BUCKET = "store_images";
const STORE_MENU_IMAGE_BUCKET = "store_menu_images";

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
    const fileExtension = (data.fileExtension ?? "jpg").trim().toLowerCase();
    const contentType = (data.contentType ?? "image/jpeg").trim();

    if (!storeId || !bucketId || !fileBase64) {
      throw new HttpsError("invalid-argument", "필수 파라미터가 누락되었습니다.");
    }
    if (
      bucketId !== STORE_IMAGE_BUCKET &&
      bucketId !== STORE_MENU_IMAGE_BUCKET
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

    const objectPath = `${storeId}/${Date.now()}.${fileExtension || "jpg"}`;
    const publicUrl = await uploadToSupabaseStorage({
      bucketId,
      objectPath,
      fileBytes,
      contentType,
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
      bucketId !== STORE_MENU_IMAGE_BUCKET
    ) {
      throw new HttpsError("invalid-argument", "허용되지 않은 버킷입니다.");
    }

    await assertStoreOwnership(storeId, uid);
    await deleteFromSupabaseStorage({bucketId, objectPath});
    return {success: true};
  },
);
