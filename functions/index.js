const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onTimeEnd = functions.database.ref("users/{user}/device0/time_end")
    .onUpdate((snapshot, context) => {
      const user = context.params.user;
      const t1ref = admin.database().ref(`users/${user}/fcmToken`);
      t1ref.once("value").then(function(snapshot) {
        console.log(`token1: ${snapshot.val()}`);
        const token1 = snapshot.val();
        const payload = {
          "token": token1,
          "notification": {
            "title": "cloud function demo",
            "body": "message",
          },
          "data": {
            "body": "message",
          },
        };
        admin.messaging().send(payload).then((response) => {
          // Response is a message ID string.
          console.log("Successfully sent message:", response);
          return {success: true};
        }).catch((error) => {
          return {error: error.code};
        });
      });
      const t2ref = admin.database().ref(`users/${user}/device0/fcmToken`);
      t2ref.once("value").then(function(snapshot) {
        console.log(`token2: ${snapshot.val()}`);
        const token2 = snapshot.val();
        const payload = {
          "token": token2,
          "notification": {
            "title": "cloud function demo",
            "body": "message",
          },
          "data": {
            "body": "message",
          },
        };
        admin.messaging().send(payload).then((response) => {
          // Response is a message ID string.
          console.log("Successfully sent message:", response);
          return {success: true};
        }).catch((error) => {
          return {error: error.code};
        });
      });
    });
