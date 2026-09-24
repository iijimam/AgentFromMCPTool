Class ATest.Agent Extends %AI.Agent
{
/// Provider to use
Parameter PROVIDER = "OpenAI";

/// Model to use
Parameter MODEL = "gpt-4.1-mini";

/// API key -- expand from environment variable at runtime
Parameter APIKEY = "@{env:OPENAI_API_KEY}";

Parameter TOOLSETS = "ATest.AgentCallTool";

XData INSTRUCTIONS [ MimeType = text/markdown ]
{
You are a database query orchestrator.

For any question related to the IRIS database, call the `Execute` tool exactly once and delegate the task to the specialized sub-agent.

Do not generate SQL or query the database yourself.

The return value from the `Execute` tool is a JSON string.

Return the `Execute` tool result exactly as received, without changing a single character.

Do not summarize, interpret, or restructure the result.

Do not add any explanation, supplementary text, Markdown, or natural-language text.

The final response must contain JSON only.

}

/// TestChat
ClassMethod TestChat(question As %String)
{
    k ^IIJ
    set agent = ..%New()
    $$$ThrowOnError(agent.%Init())
    set policy = ##class(%AI.Policy.ConsoleAuth).%New()
    set policy.AlwaysAllow=1
    do agent.ToolManager.SetAuthPolicy(policy)

    Set tools = agent.ToolManager.%Discover()
    Write !,"=== Registerd Tools ===",!
    Do tools.%ToJSON()

    // Create chat session
    set session = agent.CreateSession()

    set question="What kind of data is available?"
    set response = agent.Chat(session, question)
    Set ctx = session.GetContext()
    set ^IIJ("context")= ctx.%ToJSON()    
    write !, response.Content, !

}

}
