// import "jsr:@supabase/functions-js/edge-runtime.d.ts";
// // --- Reusable CORS Headers ---
// const corsHeaders = {
//   'Access-Control-Allow-Origin': '*',
//   'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
// };
// const geminiApiKey = Deno.env.get("GEMINI_API_KEY");
// if (!geminiApiKey) {
//   throw new Error("GEMINI_API_KEY environment variable is not set");
// }
// // Model for text and vision (gemini-1.5-flash and similar often support multimodal input)
// // Ensure 'gemini-2.5-flash-preview-05-20' also supports multimodal input in the way described below.
// const GEMINI_MODEL_NAME = "gemini-2.5-flash-preview-05-20"; // Your specified model
// const GEMINI_API_URL = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL_NAME}:generateContent?key=${geminiApiKey}`;
// console.log("INFO: 'translate-message' (Callable Version, Full CORS) initialized.");
// Deno.serve(async (req)=>{
//   // Handle CORS preflight requests
//   if (req.method === 'OPTIONS') {
//     return new Response('ok', {
//       headers: corsHeaders
//     });
//   }
//   try {
//     const body = await req.json();
//     const requestType = body.type; // 'text' or 'image'
//     const target_language = body.target_language;

//     if (!requestType || !target_language) {
//       throw new Error("Missing 'type' or 'target_language' field in body.");
//     }

//     const toLang = target_language;
//     let geminiRequestBody;

//     if (requestType === 'text') {
//       const text = body.text;
//       if (!text) {
//         throw new Error("Missing 'text' field for 'text' type request.");
//       }

//       const textPrompt = [
//         `You are a helpful translator and cultural assistant.`,
//         `The user’s message below (the "Situation") describes a situation they are in, and they want to speak to someone in ${toLang}.`,
//         `Based on that situation, produce exactly one appropriate utterance in ${toLang} that the user could say out loud right now, plus a romanization so they can read it, and a breakdown explaining each part in the language of the original "Situation" text (the detected source language).`,
//         `Also, identify the language of the user's input "Situation" text and return its ISO 639-1 code. Let's call this the "detected_source_language".`,
//         `For the "breakdown", each "gloss" MUST be in the "detected_source_language".`,
//         `Respond in strict JSON with only these four keys:`,
//         `  "utterance": "<the target-language sentence>",`,
//         `  "romanization": "<how to pronounce it (in Latin letters)>",`,
//         `  "breakdown": [`,
//         `    { "part": "<each word or phrase in ${toLang}>", "gloss": "<brief meaning in the detected_source_language>" },`,
//         `    …`,
//         `  ],`,
//         `  "detected_language": "<ISO 639-1 code of the detected source language>"`,
//         `\n---`,
//         `Situation: "${text.trim()}"`
//       ].join("\n\n");

//       geminiRequestBody = {
//           contents: [{ parts: [{ text: textPrompt }] }],
//           generationConfig: {
//             temperature: 0.2,
//             maxOutputTokens: 2048,
//             response_mime_type: "application/json"
//           }
//       };

//     } else if (requestType === 'image') {
//       const base64Image = body.image;
//       if (!base64Image) {
//         throw new Error("Missing 'image' field for 'image' type request.");
//       }

//       const imagePrompt = [
//         `You are an OCR and translation assistant.`,
//         `First, extract all text from the provided image. Let's call this "extracted_text".`,
//         `Second, identify the language of the "extracted_text" and return its ISO 639-1 code. Let's call this the "detected_source_language".`,
//         `Third, translate the "extracted_text" into ${toLang}.`,
//         `Produce exactly one appropriate utterance in ${toLang} based on the "extracted_text", plus a romanization so it can be read, and a breakdown explaining each part of the translated utterance in the "detected_source_language".`,
//         `Respond in strict JSON with only these five keys:`,
//         `  "extracted_text": "<the full text extracted from the image>",`,
//         `  "utterance": "<the ${toLang} translation of the extracted_text>",`,
//         `  "romanization": "<how to pronounce the translated utterance (in Latin letters)>",`,
//         `  "breakdown": [`,
//         `    { "part": "<each word or phrase of the translated utterance in ${toLang}>", "gloss": "<brief meaning in the detected_source_language>" },`,
//         `    …`,
//         `  ],`,
//         `  "detected_language": "<ISO 639-1 code of the detected_source_language from the image text>"`,
//         `If no text is found in the image, "extracted_text" should be an empty string, and other translation-related fields can be null or empty as appropriate for an empty input.`,
//         `Do not add any extra keys or commentary—only valid JSON.`
//       ].join("\n\n");

//       geminiRequestBody = {
//         contents: [
//           {
//             parts: [
//               { text: imagePrompt },
//               {
//                 inline_data: {
//                   mime_type: "image/jpeg", // Or "image/png" - ensure this matches client
//                   data: base64Image
//                 }
//               }
//             ]
//           }
//         ],
//         generationConfig: {
//           temperature: 0.2,
//           maxOutputTokens: 2048, // OCR + translation might need more tokens
//           response_mime_type: "application/json"
//         }
//       };

//     } else {
//       throw new Error(`Unsupported request type: ${requestType}`);
//     }

//     const geminiResponse = await fetch(GEMINI_API_URL, {
//       method: "POST",
//       headers: { "Content-Type": "application/json" },
//       body: JSON.stringify(geminiRequestBody)
//     });

//     if (!geminiResponse.ok) {
//       const errorBody = await geminiResponse.text();
//       console.error(`Gemini API request failed with status ${geminiResponse.status}: ${errorBody}`);
//       throw new Error(`Gemini API request failed: ${geminiResponse.status}`);
//     }

//     const geminiResponseData = await geminiResponse.json();

//     if (!geminiResponseData.candidates || !geminiResponseData.candidates[0].content || !geminiResponseData.candidates[0].content.parts || !geminiResponseData.candidates[0].content.parts[0].text) {
//       console.error("Unexpected Gemini API response structure:", JSON.stringify(geminiResponseData));
//       throw new Error("Failed to parse Gemini response: structure unexpected.");
//     }

//     const rawContent = geminiResponseData.candidates[0].content.parts[0].text.trim();
//     // The rawContent is expected to be a JSON string from Gemini, so we return it directly.
//     // The client (ChatService) will parse this JSON string.

//     // Return the AI response with CORS headers
//     return new Response(rawContent, {
//       headers: {
//         ...corsHeaders,
//         "Content-Type": "application/json"
//       },
//       status: 200
//     });
//   } catch (e) {
//     console.error("ERROR in function execution:", e.message);
//     // Also include CORS headers in error responses
//     return new Response(JSON.stringify({
//       error: e.message
//     }), {
//       headers: {
//         ...corsHeaders,
//         "Content-Type": "application/json"
//       },
//       status: 400
//     });
//   }
// });
