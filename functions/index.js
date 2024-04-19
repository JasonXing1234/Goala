const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");
const moment = require("moment-timezone");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://motivationapp-fa23c-default-rtdb.firebaseio.com",
});
process.env.GCLOUD_PROJECT = (req, res) =>{
  res.send(JSON.parse(process.env.FIREBASE_FUNCTION).projectId);
};
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
            if (snap.val().currentDays > 8) {
              tempList.push(false);
              delete tempList[0];
            }
          }
          console.log(tempList);
          const tempKey = snap.key;
          const tempDays = snap.val().currentDays;
          promises.push(db.ref("tweet").child(tempKey).ref.update({
            checkInList: tempList,
            isCheckedIn: false,
            currentDays: tempDays + 1,
          }));
          console.log("done!");
        });
      });
      await Promise.all(promises);
    },
    );

exports.sendUserNotifications = functions.pubsub.schedule("* * * * *")
  .onRun(async (context) => {
  const now = new Date();
  let currentDay = now.getDay();
  if (now.getDay() == 0) {
    currentDay = 7;
  } else {
    currentDay = now.getDay();
  }
  // Sunday - 0, Monday - 1, ..., Saturday - 6
  // Convert the current time to Mountain Time (MT)
  const currentTimeMT = moment().tz("America/Denver");
  let currentTime = currentTimeMT.format("MM/DD/YYYY HH:mm").substring(11, 16); // "HH:MM" format
  if (currentTime.charAt(0) === "0") {
    currentTime = currentTimeMT.format("MM/DD/YYYY HH:mm").substring(12, 16);
  } if (currentTime.charAt(3) === "0") {
    currentTime = currentTimeMT.format("MM/DD/YYYY HH:mm").substring(11, 14)+currentTimeMT.toISOString().substring(15, 16);
  } if (currentTime.charAt(0) === "0" && currentTime.charAt(3) === "0") {
    currentTime = currentTimeMT.format("MM/DD/YYYY HH:mm").substring(12, 14)+currentTimeMT.toISOString().substring(15, 16);
  }
  admin.database().ref("GoalNotifications").once("value").then((snapshot) => {
    snapshot.forEach((snap) => {
      if (parseInt(snap.val().day) === currentDay) {
        const notificationTime = snap.val().notiTime;
        console.log((snap.val().notiTime + " / " + currentTime));
        if (notificationTime === currentTime) {
          console.log("sent!");
          sendPushNotification(snap.val().userID, "goal");
        }
      }
    },
   );
  });
  /* for (let i = 0; i < notifications.length; i++) {
    console.log("haha2");
    const notification = notifications[i];
    if (parseInt(notification.day) === currentDay) {
      const notificationTime = notification.notiTime;
      if (notificationTime === currentTime) {
        console.log("sent!");
        sendPushNotification(notification.userID, i);
      }
    }
  }*/
});

function sendPushNotification(userID, goalID) {
  const message = {
    notification: {
      title: "Goal Reminder",
      body: "It's time to" + goalID,
    },
    token: userID,
  };

  admin.messaging().send(message)
    .then((response) => {
      console.log("Successfully sent message:", response);
      })
      .catch((error) => {
        console.log("Error sending message:", error);
    });
}
