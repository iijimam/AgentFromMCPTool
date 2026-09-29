# Invoking an AI Hub Agent from an MCP Tool

This project is a small reproducible example for testing whether an AI Hub Agent can be invoked from inside an MCP tool.

> I use "IRIS for UNIX (Ubuntu Server LTS for x86-64 Containers) 2026.3.0AI (Build 136U) Tue Aug 18 2026 09:52:07 EDT"

---

---

## Test pattern

The `AskDatabase` method in [`BTest.AgentCallTool`](./agent/src/BTest/AgentCallTool.cls) runs successfully when called directly from the IRIS Terminal.

However, when the same method is exposed as an MCP tool and invoked through MCP, the request times out after 60 seconds, even though the inner agent completes successfully.


## Additional Information: Agent → Tool → Agent → Tools

In this additional test, an outer Agent calls `AskDatabase` as a local tool.

The `AskDatabase` tool then creates and runs another AI Hub Agent, which calls the required tools and returns the final result.


---

## Setup / Run

### 1. Create a `.env` file

Create a `.env` file in the project root and set your OpenAI API key.

```env
OPENAI_API_KEY=your_openai_api_key
```

### 2. Start the containers

```bash
docker compose up -d
```

### 3. Open an IRIS terminal

Open an IRIS terminal in the container.

If needed, use a command similar to:

```bash
docker compose exec agent iris session IRIS
```

---

## Direct ObjectScript Execution

### Terminal

```objectscript
set j=##class(BTest.AgentCallTool).AskDatabase("What kind of data is available?")
USER>do j.%ToJSON()
{"Summary":"Available data includes basic patient information and prescription data.","Evidence":["Patient - Contains basic patient information","Prescription - Contains prescription data"],"result":{}}
```

After running this command, you can inspect the "^IIJ2" global to confirm that the inner agent completed successfully and returned a result.

```
zwrite ^IIJ2
```

The contexts can be used to confirm the actual tool calls performed by the agents.

For example:

```text
SetGlo
  → GetGlobals
```

The result of ^IIJ2("Agent2-context") is shown below:

```text
^IIJ2("Agent2-context")="[{""role"":""user"",""content"":""What kind of data is available?""},{""role"":""assistant"",""content"":null,""tool_calls"":[{""id"":""call_fe8EBwPZyMJM3LapAa73YSpF"",""name"":""SetGlo"",""arguments"":""{}""}]},{""role"":""tool"",""tool_call_id"":""call_fe8EBwPZyMJM3LapAa73YSpF"",""content"":""{\""Message\"":\""Initialization completed\""}""},{""role"":""assistant"",""content"":null,""tool_calls"":[{""id"":""call_c24HhlCNOok9nzjW4WkvKZGK"",""name"":""GetGlobals"",""arguments"":""{}""}]},{""role"":""tool"",""tool_call_id"":""call_c24HhlCNOok9nzjW4WkvKZGK"",""content"":""[{\""contents\"":\""Contains basic patient information\"",\""name\"":\""Patient\""},{\""contents\"":\""Contains prescription data\"",\""name\"":\""Prescription\""}]""},{""role"":""assistant"",""content"":""{\""Summary\"":\""There are two types of data available: basic patient information and prescription data.\"",\""Evidence\"":[\""Patient data contains basic patient information\"",\""Prescription data contains prescription data\""],\""result\"":{}}""}]"
```


### MCP Tester

The file [`mcptest.http`](./agent/src/mcptest.http) can be used with the REST Client extension in VS Code.

Run the requests in order. After sending the request around line 37, the MCP call times out after 60 seconds:

You can also reproduce the same behavior using [MCP Inspector](https://modelcontextprotocol.io/docs/2026-07-28/tools/inspector).

```
data: {"jsonrpc":"2.0","id":3,"result":{"content":[{"type":"text","text":"WebSocket error: REST tool call to /mcp/btest/v1/tool_call timed out after 60s"}],"isError":true}}
```


After the timeout, inspect ^IIJ2 again:

```
zwrite ^IIJ2
```

The global contains the same inner agent execution result as the direct Terminal test.

This indicates that the inner agent completes successfully, but the MCP request still times out.


### Additional Test: Agent → Tool → Agent → Tools

```objectscript
Do ##class(BTest.Agent).TestChat()
```

The inner agent can call its tools and return the final result.

For example, the execution flow can be confirmed in the agent context as:

```text
AskDatabase
  → SetGlo
  → GetGlobals
  → Final JSON response
```


After running, you can check "^IIJ2" global to confirm returning answer from agent.

```
zwrite ^IIJ2
```
After running, you can inspect the `^IIJ2` global to confirm that the inner agent completed successfully.

The result is the same as in the direct Terminal test.

---
## Question

The inner agent completes successfully both when called directly and when invoked through MCP, as confirmed by `^IIJ2`.

However, only the MCP request times out after 60 seconds.

Is there any known limitation or additional configuration required when an MCP tool synchronously invokes an AI Hub Agent and waits for its result?
