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
    },
    );

exports.sendUserNotifications = functions.pubsub.schedule("* * * * *")
  .onRun(async (context) => {
  const now = new Date();
  const currentDay = now.getDay(); // Sunday - 0, Monday - 1, ..., Saturday - 6
  const currentTime = now.toISOString().substring(11, 16); // "HH:MM" format
  admin.database().ref("GoalNotifications").once("value").then((snapshot) => {
    snapshot.forEach((snap) => {
      if (parseInt(snap.val().day) === currentDay) {
        const notificationTime = snap.val().notiTime;
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

exports.sendPokeNotification = functions.https.onCall((data, context) => {
  const token = data.token;
  const displayName = data.user;// Device token of the recipient user
  console.log("Successfully sent message:", response);
  const message = {
    notification: {
      title: displayName + "You are poked!",
      body: "You have a new message.",
    },
    token: token,
  };
  console.log("Successfully sent message:", response);

  return admin.messaging().send(message)
    .then((response) => {
      return {success: true, response: response};
    })
    .catch((error) => {
      return {success: false, error: error};
    });
});

