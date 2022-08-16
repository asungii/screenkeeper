const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onTimeEnd = functions.database.ref("users/{user}/device0/time_end")
    .onUpdate((snapshot, context) => {
      const user = context.params.user;
      // when in this .onUpdate, use .after
      const timeEnd = snapshot.after.val();
      // i don't know why but toLocaleTimeString() doesn't work
      const date = new Date(timeEnd*1000);
      const offset = date.getTimezoneOffset() / 60;
      const newDateHours = date.getHours() + offset;
      date.setHours(newDateHours);
      console.log(date);
      const newDate = date.toString();
      const t1Ref = admin.database().ref(`users/${user}/fcmToken`);
      t1Ref.once("value").then(function(snapshot) {
        // when in specific call, no .after
        const token1 = snapshot.val();
        const payload = {
          "token": token1,
          "notification": {
            "title": "cloud function demo",
            "body": newDate,
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
      const t2Ref = admin.database().ref(`users/${user}/device0/fcmToken`);
      t2Ref.once("value").then(function(snapshot) {
        const token2 = snapshot.val();
        const payload = {
          "token": token2,
          "notification": {
            "title": "cloud function demo",
            "body": newDate,
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
