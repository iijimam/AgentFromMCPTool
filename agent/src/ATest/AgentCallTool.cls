/// 自然言語で検索するエージェントを起動するクラス
Class ATest.AgentCallTool Extends %AI.Tool
{
/// Agent for Retrieving Values from the IRIS Database
/// [Argument] Specify the data you want using natural language
/// Return : JSON
ClassMethod AskDatabase(question as %String) As %DynamicObject
{
    kill ^IIJ
    set ^IIJ("time")=$zdt($h,3,1)

    Set agent = ##class(ATest.Agent).%New()
    $$$ThrowOnError(agent.%Init())

    Set delegateTool = ##class(ATest.DelegateDatabaseTask).%New()
    Set delegateTool.ParentAgent = agent
    Do agent.ToolManager.AddTool(delegateTool)

    Set tools = agent.ToolManager.%Discover()
    set ^IIJ("Discover")=tools.%ToJSON()

    Set policy = ##class(%AI.Policy.ConsoleAuth).%New()
    Set policy.AlwaysAllow = 1
    Do agent.ToolManager.SetAuthPolicy(policy)

    Set session = agent.CreateSession()
    Set res = agent.Chat(session, question)
    set resTxt = res.Content
    set ^IIJ("res")=resTxt
    
    set json = {}.%FromJSON(resTxt)
    
    return json
}
}
