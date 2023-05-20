const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
exports.myFunction = functions.firestore.document("keywords/{keywordId}").onCreate((snap, context) => {

    // Get an object representing the document
    // e.g. {'name': 'Marie', 'age': 66}
    const newValue = snap.data();

    // access a particular field as you would any JS property
    const name = newValue.name;

    // perform desired operations ...
});
