/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { setGlobalOptions } = require("firebase-functions");
const { onCall } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const axios = require("axios");

initializeApp();
setGlobalOptions({ maxInstances: 10 });

exports.signInWithNaver = onCall(async (request) => {
  const accessToken = request.data.accessToken;

  // 1. 네이버 API로 사용자 정보 조회
  const { data } = await axios.get("https://openapi.naver.com/v1/nid/me", {
    headers: { Authorization: `Bearer ${accessToken}` },
  });

  const { id, email, name } = data.response;

  // 2. Firebase Custom Token 발급
  const customToken = await getAuth().createCustomToken(`naver:${id}`, {
    provider: "naver",
    email,
    name,
  });

  return { customToken };
});
