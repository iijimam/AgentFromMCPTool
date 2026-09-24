Class BTest.Agent Extends %AI.Agent
{
/// Provider to use
Parameter PROVIDER = "OpenAI";

/// Model to use
Parameter MODEL = "gpt-4.1-mini";

/// API key -- expand from environment variable at runtime
Parameter APIKEY = "@{env:OPENAI_API_KEY}";

Parameter TOOLSETS = "BTest.AgentCallTool";

XData INSTRUCTIONS [ MimeType = text/markdown ]
{
You are a database query orchestrator.

For any question related to the IRIS database, call the AskDatabase tool exactly once.

Do not query the database yourself.

Return the AskDatabase result exactly as received, without modifying, summarizing, interpreting, or restructuring it.

Do not add any explanation, supplementary text, Markdown, or natural-language text.

The final response must contain JSON only.
}

/// チャット
ClassMethod TestChat(question As %String)
{
    kill ^IIJ2
    set agent = ..%New()
    $$$ThrowOnError(agent.%Init())
    set policy = ##class(%AI.Policy.ConsoleAuth).%New()
    set policy.AlwaysAllow=1
    do agent.ToolManager.SetAuthPolicy(policy)

    Set tools = agent.ToolManager.%Discover()
    Write !,"=== Resisterd Tools ===",!
    Do tools.%ToJSON()

    // Create chat session
    set session = agent.CreateSession()

    //
    set question="What kind of data is available?"
    set response = agent.Chat(session, question)
    Set ctx = session.GetContext()
    set ^IIJ2("Agent1-context")= ctx.%ToJSON()    
    write !, response.Content, !

}

}
