import * as admin from "firebase-admin";
import {onDocumentDeleted} from "firebase-functions/v2/firestore";
import {getAuth} from "firebase-admin/auth";

admin.initializeApp();

// Function that deletes users in the users table in the firebase authentication tab whenever the corresponding
// user document gets deleted in the users collection in Cloud Firestore
export const deleteAuthUserOnFirestoreDelete = onDocumentDeleted("users/{uid}", async (event) => {
  const uid = event.params.uid;

  try {
    await getAuth().deleteUser(uid);
    console.log(`Successfullyt deleted user: ${uid}`);
  } catch (err) {
    console.error(`Error deleting user: ${uid}`, err);
  }
});
