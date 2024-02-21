/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://motivationapp-fa23c-default-rtdb.firebaseio.com",
});
process.env.GCLOUD_PROJECT = (req, res) =>{
  res.send(JSON.parse(process.env.FIREBASE_FUNCTION).projectId);
};
// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.dailyCheckInUpdate = functions.runWith({timeoutSeconds: 300}).pubsub
    .schedule("59 0 * * *")
    .timeZone("US/Mountain")
    .onRun(async (context) => {
      console.log("This will be run every day at 11:59 PM Moutain Time!");
      const db = admin.database();
      const promises = [];
      db.ref("tweet").once("value").then((snapshot) => {
        snapshot.forEach((snap) => {
          const tempList = snap.val().checkInList;
          if (snap.val().checkInList.length < 8) {
            tempList.push(false);
            console.log("haha");
          } else {
            tempList.push(false);
            delete tempList[0];
          }
          console.log(tempList);
          const tempKey = snap.key;
          promises.push(db.ref("tweet").child(tempKey).ref.update({
            checkInList: tempList,
            isCheckedIn: false,
          }));
          console.log("done!");
        });
      });
      await Promise.all(promises);
    });


