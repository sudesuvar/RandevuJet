/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.checkAndCreateAppointment =
functions.https.onCall(async (data, context) => {
  console.log("📥 Gelen veri:", data);

  // Gelen veriler gerçek payload "data" alanında oluyor
  const appointmentDate = data.data.appointmentDate;
  const appointmentTime = data.data.appointmentTime;
  const customerUid = data.data.customerUid;
  const salonName = data.data.salonName;
  const otherFields = data.data.otherFields;

  console.log("🧪 appointmentDate:", appointmentDate);
  console.log("🧪 appointmentTime:", appointmentTime);
  console.log("🧪 customerUid:", customerUid);
  console.log("🧪 salonName:", salonName);

  if (!appointmentDate || !appointmentTime || !customerUid || !salonName) {
    console.log("⚠️ Eksik alanlar:", {
      appointmentDate,
      appointmentTime,
      customerUid,
      salonName,
    });
    throw new functions.https.HttpsError("invalid-argument", "Eksik veri.");
  }

  try {
    const existingAppointments = await db
        .collection("appointments")
        .where("appointmentDate", "==", appointmentDate)
        .where("appointmentTime", "==", appointmentTime)
        .where("salonName", "==", salonName)
        .get();

    if (!existingAppointments.empty) {
      return {
        success: false,
        message: "Bu saat için zaten bir randevu var.",
      };
    }

    await db.collection("appointments").add({
      appointmentDate,
      appointmentTime,
      customerUid,
      salonName,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      ...otherFields,
    });

    return {success: true, message: "Randevu başarıyla alındı."};
  } catch (error) {
    console.error("❌ Randevu alma hatası:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

