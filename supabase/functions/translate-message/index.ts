// import "jsr:@supabase/functions-js/edge-runtime.d.ts";
// import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// // --- Gemini API Setup ---
// // This function requires the GEMINI_API_KEY to be set in your Supabase project's secrets.
// const geminiApiKey = Deno.env.get("GEMINI_API_KEY");
// if (!geminiApiKey) {
//   throw new Error("GEMINI_API_KEY environment variable is not set");
// }

// // The API endpoint is updated to use the newer, more capable gemini-2.0-flash model.
// const GEMINI_API_URL =
//   `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${geminiApiKey}`;

// console.log("INFO: 'translate-message' function (Gemini 2.0 Flash) initialized.");

// // The main server process that handles incoming webhook requests.
// Deno.serve(async (req) => {
//   // 1. --- VALIDATE WEBHOOK PAYLOAD ---
//   // Ensure the request is a POST request from the webhook.
//   if (req.method !== "POST") {
//     return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405 });
//   }

//   let webhookPayload;
//   try {
//     webhookPayload = await req.json();
//     // We only care about new messages being inserted, so we ignore other event types like UPDATE or DELETE.
//     if (webhookPayload.type !== 'INSERT') {
//       console.log(`INFO: Ignoring event of type '${webhookPayload.type}'.`);
//       return new Response("OK");
//     }
//   } catch (e) {
//     console.error("ERROR: Failed to parse webhook payload.", e);
//     return new Response(JSON.stringify({ error: "Invalid webhook payload" }), { status: 400 });
//   }

//   // 2. --- EXTRACT MESSAGE DATA ---
//   // The 'record' property of the webhook payload contains the newly inserted row data.
//   const message = webhookPayload.record;
//   const { id: messageId, content: text } = message;

//   // If the message has no content, there's nothing to translate.
//   if (!text) {
//     console.log(`INFO: Ignoring message ID ${messageId} with no content.`);
//     return new Response("OK");
//   }
  
//   // For now, the target language is hardcoded. In a future version, this could
//   // be dynamic based on user preferences or room settings.
//   const toLang = "Japanese";

//   console.log(`INFO: Processing message ID ${messageId}: "${text}"`);

//   // 3. --- BUILD PROMPT AND CALL GEMINI ---
//   const prompt = [
//     `You are a helpful translator and cultural assistant for a traveler.`,
//     `Your task is to process the user's input based on these rules:`,
//     `1. If the input is a single word (ignoring punctuation), provide a direct translation.`,
//     `2. Otherwise, detect the source language and translate the user's input into a polite, natural sentence in ${toLang}.`,
//     `Your response MUST be a single, valid JSON object with NO MARKDOWN formatting (e.g., no \`\`\`json).`,
//     `The JSON object must contain only these keys: "detected_source", "utterance", "romanization", and a "breakdown" array of objects with a "part" and "gloss" key.`,
//     `---`,
//     `User input: "${text.trim()}"`,
//   ].join("\n");

//   let aiResponse;
//   try {
//     // Call the Gemini API using Deno's native fetch.
//     const geminiResponse = await fetch(GEMINI_API_URL, {
//       method: "POST",
//       headers: { "Content-Type": "application/json" },
//       body: JSON.stringify({
//         contents: [{ parts: [{ text: prompt }] }],
//         generationConfig: {
//           temperature: 0.2,
//           maxOutputTokens: 512,
//         },
//       }),
//     });

//     if (!geminiResponse.ok) {
//       const errorBody = await geminiResponse.text();
//       throw new Error(`Gemini API request failed with status ${geminiResponse.status}: ${errorBody}`);
//     }

//     const responseData = await geminiResponse.json();
//     const rawContent = responseData.candidates[0].content.parts[0].text.trim() ?? "{}";
//     aiResponse = JSON.parse(rawContent);
//     console.log(`INFO: Successfully parsed Gemini response for message ID ${messageId}.`);

//   } catch (e) {
//     console.error(`ERROR: Gemini API call or JSON parsing failed for message ID ${messageId}.`, e);
//     return new Response(JSON.stringify({ error: "Failed to process AI translation" }), { status: 500 });
//   }

//   // 4. --- UPDATE THE MESSAGE IN SUPABASE ---
//   try {
//     // We create a new Supabase client with the SERVICE_ROLE_KEY to bypass
//     // Row Level Security policies for this backend update.
//     const supabaseAdmin = createClient(
//       Deno.env.get("SUPABASE_URL")!,
//       Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
//     );

//     // Prepare the data object with the results from the AI.
//     const updateData = {
//       output: aiResponse.utterance,
//       target_language: toLang,
//       romanisation: aiResponse.romanization,
//       breakdown: aiResponse.breakdown, // Assumes 'breakdown' column is type jsonb
//     };

//     // Update the specific message row using its ID.
//     const { error } = await supabaseAdmin
//       .from("messages")
//       .update(updateData)
//       .eq("id", messageId);

//     if (error) throw new Error(error.message);
    
//     console.log(`SUCCESS: Message ID ${messageId} successfully updated with translation.`);
//   } catch (e) {
//     console.error(`ERROR: Failed to update message ID ${messageId} in Supabase.`, e);
//     return new Response(JSON.stringify({ error: "Failed to update database" }), { status: 500 });
//   }

//   // 5. --- RETURN SUCCESS RESPONSE ---
//   // A 200 OK response tells the Supabase webhook that the event was handled successfully.
//   return new Response("OK", { status: 200 });
// });