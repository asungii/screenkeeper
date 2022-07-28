const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendTimeEndNotification = functions.database.ref("/child_users/time_end")
