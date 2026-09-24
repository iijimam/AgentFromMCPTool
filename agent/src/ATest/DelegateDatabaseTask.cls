Class ATest.DelegateDatabaseTask Extends %AI.Tool
{

Parameter DESCRIPTION ="Delegate a database question.";

Property ParentAgent As %AI.Agent;

/// Answers questions about global variables.
/// [Argument] Question text
/// Returns the answer as JSON.
Method Execute(task As %String) As %String [ WebMethod ]
{
    Try {
        set systemPrompt =
            "You are a global data assistant for InterSystems IRIS."*$C(13,10)_
            "Follow these steps exactly."_$C(13,10)_
            "1. Always run SetGlo first as the initialization step."_$C(13,10)_
            "2. Run GetGender when needed."_$C(13,10)_
            "Store the retrieved information in the result field of the JSON below."_$C(13,10)_
            "- Output JSON only."_$C(13,10)_
            "- Do not add Markdown or any explanatory text outside the JSON."_$C(13,10)_
            "- Return the JSON in a single-line compact format."_$C(13,10)_
            "- Use an empty string or empty array for information that does not exist."_$C(13,10)_
            "{""Summary"":"""",""Evidence"":[],""result"":{}}"
        Set subagent = ##class(%AI.Agent.SubAgent).Create(
            ..ParentAgent,
            systemPrompt,
            ""
        )

        set subagent.ToolManager=##class(%AI.ToolMgr).%New()
        set dbtool=##class(ATest.Tools).%New()
        do subagent.ToolManager.AddTool(dbtool)
        Set tools = subagent.ToolManager.%Discover()
        Set ^IIJ("SubDiscover") = tools.%ToJSON()

        Set policy = ##class(%AI.Policy.ConsoleAuth).%New()
        Set policy.AlwaysAllow = 1
        Do subagent.ToolManager.SetAuthPolicy(policy)

        Set session = subagent.CreateSession()
        Set response = subagent.Run(session, task,10)
        Set ^IIJ("subagent-res") = response.Content

        Set ctx = session.GetContext()
        set ^IIJ("subagent-context")=ctx.%ToJSON()
        Return response.Content

    } Catch ex {
        Return "Error in database delegation: "_ex.DisplayString()
    }
}
}
