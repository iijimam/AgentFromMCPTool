# Invoking an AI Hub Agent from an MCP Tool

This project is a small reproducible example for testing whether an AI Hub Agent can be invoked from inside an MCP tool.

Two patterns are included.

> I use "IRIS for UNIX (Ubuntu Server LTS for x86-64 Containers) 2026.3.0AI (Build 136U) Tue Aug 18 2026 09:52:07 EDT"

---

## Case A: Using a SubAgent

```text
Agent
  → AskDatabase tool
    → Parent Agent
      → Delegate tool
        → SubAgent
          → Tools
````

In this case, the `AskDatabase` tool creates a parent agent.

The parent agent delegates the database-related task to a sub-agent through a delegation tool.

The sub-agent then calls the required tools and returns the final result.

---

## Case B: Using a Normal Agent

```text
Agent
  → AskDatabase tool
    → Normal Agent
      → Tools
```

In this case, the `AskDatabase` tool directly creates and runs another AI Hub Agent without using a SubAgent.

The inner agent calls the required tools and returns the final result.

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

Both cases can be executed directly from ObjectScript.

### Case A

```objectscript
Do ##class(ATest.Agent).TestChat()
```

### Case B

```objectscript
Do ##class(BTest.Agent).TestChat()
```

When both cases are executed directly from ObjectScript, the agent execution completes successfully.

The inner agent can call its tools and return the final result.

For example, the execution flow can be confirmed in the agent context as:

```text
AskDatabase
  → SetGlo
  → GetGlobals
  → Final JSON response
```

This shows that the behavior does not appear to be specific to SubAgent.

Both the SubAgent pattern and the normal Agent pattern can execute successfully when called directly from ObjectScript.

---

## Checking the Agent Context

For debugging and verification, the execution contexts are stored in globals.

### Case A

Case A stores the parent-agent and sub-agent contexts in:

```objectscript
^IIJ
```

You can inspect them with:

```objectscript
ZW ^IIJ
```

### Case B

Case B stores the outer-agent and inner-agent contexts in:

```objectscript
^IIJ2
```

You can inspect them with:

```objectscript
ZW ^IIJ2
```

The contexts can be used to confirm the actual tool calls performed by the agents.

For example:

```text
SetGlo
  → GetGlobals
```

or, depending on the question:

```text
SetGlo
  → GetGender
```

---

## MCP Tool Execution

The `AskDatabase` method is also exposed as an MCP tool.

Conceptually, the intended architecture is:

```text
MCP Client
  → MCP Tool
    → AI Hub Agent
      → Tools
      → Result
```

However, when the same method is invoked from the MCP Tool Tester or an MCP client, the request times out after 60 seconds.

```text
WebSocket error: REST tool call to /mcp/atest/v1/tool_call timed out after 60s
```

This occurs even though the same agent execution completes when called directly from ObjectScript.

The same behavior is observed with both:

* a normal AI Hub Agent
* a SubAgent-based implementation

Therefore, this does not appear to be specific to SubAgent.

---

## Question

The main question is:

**Is invoking an AI Hub Agent synchronously from inside an MCP tool currently a supported pattern?**

If this pattern is supported:

* Is there a recommended implementation pattern?
* Is any additional configuration required?

If this pattern is not currently supported:

* Is support for this architecture planned for a future release?

---

## Additional Observation

When the same code is executed directly from ObjectScript, the expected result is returned successfully, but messages such as the following may also appear:

```text
Could not decrement IRIS object Oref(...) counter at drop! ERR:
IRIS(
         General(
                         "<INVALID OREF>",
                                              ),
                                                )
```

The agent execution itself still completes and returns the expected result.

For now, this is being treated as a separate issue from the MCP 60-second timeout.
