/// 自然言語で検索するエージェントを起動するクラス
Class BTest.AgentCallTool Extends %AI.Tool
{
/// Agent that retrieves data from the IRIS database.
/// Argument: Data to retrieve
/// Returns: JSON string
ClassMethod AskDatabase(question as %String) As %DynamicObject
{
    kill ^IIJ2
    set ^IIJ2("time")=$zdt($h,3,1)

    Set agent = ##class(BTest.Agent2).%New()
    $$$ThrowOnError(agent.%Init())

    Set tools = agent.ToolManager.%Discover()
    set ^IIJ2("Discover")=tools.%ToJSON()

    Set policy = ##class(%AI.Policy.ConsoleAuth).%New()
    Set policy.AlwaysAllow = 1
    Do agent.ToolManager.SetAuthPolicy(policy)

    Set session = agent.CreateSession()
    Set res = agent.Chat(session, question)
    set resTxt = res.Content
    set ^IIJ2("res")=resTxt
    Set ctx = session.GetContext()
    set ^IIJ2("Agent2-context")= ctx.%ToJSON()   
    set json = {}.%FromJSON(resTxt)
    
    return json
}
}
