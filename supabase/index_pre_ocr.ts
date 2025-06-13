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
// // Use the correct 'gemini-1.5-flash' model name
// const GEMINI_API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=${geminiApiKey}`;
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
//     // Destructure both 'text' and 'target_language' from the request body
//     const { text, target_language } = body;
//     // Verify that both required fields are present
//     if (!text || !target_language) {
//       throw new Error("Missing 'text' or 'target_language' field in body.");
//     }
//     // Use the dynamic target_language from the request
//     const toLang = target_language;
//     const prompt = [
//       `You are a helpful translator and cultural assistant.`,
//       `The user’s message below (the "Situation") describes a situation they are in, and they want to speak to someone in ${toLang}.`,
//       `Based on that situation, produce exactly one appropriate utterance in ${toLang} that the user could say out loud right now, plus a romanization so they can read it, and a breakdown explaining each part in the language of the original "Situation" text (the detected source language).`,
//       `Also, identify the language of the user's input "Situation" text and return its ISO 639-1 code.`,
//       `Respond in strict JSON with only these four keys:`,
//       `  "utterance": "&lt;the target-language sentence&gt;",`,
//       `  "romanization": "&lt;how to pronounce it (in Latin letters)&gt;",`,
//       `  "breakdown": [`,
//       `    { "part": "&lt;each word or phrase in ${toLang}&gt;", "gloss": "&lt;brief meaning in the detected source language&gt;" },`,
//       `    …`,
//       `  ],`,
//       `  "detected_language": "&lt;ISO 639-1 code of the detected source language&gt;"`,
//       `\n---`,
//       `Situation: "${text.trim()}"`
//     ].join("\n\n");
//     const geminiResponse = await fetch(GEMINI_API_URL, {
//       method: "POST",
//       headers: {
//         "Content-Type": "application/json"
//       },
//       body: JSON.stringify({
//         contents: [
//           {
//             parts: [
//               {
//                 text: prompt
//               }
//             ]
//           }
//         ],
//         generationConfig: {
//           temperature: 0.2,
//           maxOutputTokens: 2048,
//           response_mime_type: "application/json"
//         }
//       })
//     });
//     if (!geminiResponse.ok) {
//       const errorBody = await geminiResponse.text();
//       throw new Error(`Gemini API request failed with status ${geminiResponse.status}: ${errorBody}`);
//     }
//     const responseData = await geminiResponse.json();
//     const rawContent = responseData.candidates[0].content.parts[0].text.trim();
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
