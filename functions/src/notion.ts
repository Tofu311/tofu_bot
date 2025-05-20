// import * as functions from "firebase-functions";
// import * as dotenv from "dotenv";
import {onRequest} from "firebase-functions/v2/https";
import {Request, Response} from "express";
import * as admin from "firebase-admin";
import {defineSecret} from "firebase-functions/params";

const notionApiKey = defineSecret("NOTION_API_KEY");
const notionDbId = defineSecret("NOTION_DB_ID");

// Cloud Function to fetch Notion page URLs, requires authentication from Firebase users
// Might have to have better type safety then "Promise<any>", but for now its gonna have to work
export const getNotionPageList = onRequest(async (req: Request, res: Response): Promise<any> => {
  console.log("FUNCTION STARTED");

  const idToken = req.headers.authorization?.split("Bearer ")[1];
  console.log("Received ID token?", !!idToken);

  if (!idToken) {
    console.warn("No ID token received.");
    return res.status(401).send("Unauthorized: No Firebase ID token provided");
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const uid = decodedToken.uid;
    console.log(`Authenticated request from user: ${uid}`);
  } catch (err) {
    console.error("Invalid Firebase ID token", err);
    return res.status(403).send("Unauthorized: Invalid Firebase ID token");
  }

  const NOTION_API_KEY = notionApiKey.value();
  const NOTION_DB_ID = notionDbId.value();

  console.log("NOTION_API_KEY defined?", !!NOTION_API_KEY);
  console.log("NOTION_DB_ID defined?", !!NOTION_DB_ID);

  if (!NOTION_API_KEY || !NOTION_DB_ID) {
    console.error("Missing NOTION_KEY or NOTION_DB in environment");
    return res.status(500).send("Missing Notion configuration");
  }

  try {
    const response = await fetch(`https://api.notion.com/v1/databases/${NOTION_DB_ID}/query`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${NOTION_API_KEY}`,
        "Content-Type": "application/json",
        "Notion-Version": "2022-06-28",
      },
      body: JSON.stringify({}),
    });

    if (!response.ok) {
      const body = await response.text();
      console.error("Notion API failed:", response.status, body);
      return res.status(response.status).send(`Notion error: ${body}`);
    }

    const data = await response.json();
    console.log("Data from Notion:", JSON.stringify(data));

    const pages = data.results.map((page: any) => page.url);
    console.log("Parsed page URLs:", pages);

    return res.status(200).json(pages);
  } catch (err) {
    console.error("Unhandled error:", err);
    return res.status(500).send("Failed to fetch Notion data");
  }
});
