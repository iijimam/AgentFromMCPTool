Class BTest.Agent2 Extends %AI.Agent
{
/// Provider to use
Parameter PROVIDER = "OpenAI";

/// Model to use
Parameter MODEL = "gpt-4.1-mini";

/// API key -- expand from environment variable at runtime
Parameter APIKEY = "@{env:OPENAI_API_KEY}";

Parameter TOOLSETS = "BTest.Tools";

XData INSTRUCTIONS [ MimeType = text/markdown ]
{
You are a global data assistant for InterSystems IRIS.

Follow these steps exactly:
1. Always run SetGlo first as the initialization step.
2. Run GetGender when needed.

Store the retrieved information in the result field of the JSON below.

- Output JSON only.
- Do not add Markdown or any explanatory text outside the JSON.
- Return the JSON in a single-line compact format.
- Use an empty string or empty array for information that does not exist.

{"Summary":"","Evidence":[],"result":{}}
}
}
