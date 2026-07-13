# Setup and self-test

## Build

From the repository root, build and install the App:

```bash
./scripts/build-app.sh
./scripts/install-app.sh
python3 skills/macos-ui-control/scripts/self_test.py
```

The self-test is read-only. A successful run prints the server name, tool names, and the number of running applications.

## Cursor

Prefer the running App's authenticated local endpoint. Obtain its token:

```bash
/Applications/macOS\ UI\ Bridge.app/Contents/MacOS/macos-ui-bridge token
```

Configure the endpoint and replace `TOKEN_FROM_COMMAND`:

```json
{
  "mcpServers": {
    "macos-ui-bridge": {
      "url": "http://127.0.0.1:8765/mcp",
      "headers": { "Authorization": "Bearer TOKEN_FROM_COMMAND" }
    }
  }
}
```

If the client does not support local HTTP MCP, use stdio:

```json
{
  "mcpServers": {
    "macos-ui-bridge": {
      "command": "/Applications/macOS UI Bridge.app/Contents/MacOS/macos-ui-bridge",
      "args": ["mcp"]
    }
  }
}
```

Restart or reload MCP servers, then confirm that all nine tools are visible, including `snapshot_get`, `action_run`, and `emergency_stop`.

## WorkBuddy and other MCP clients

Prefer the same authenticated URL when supported. Otherwise create a local stdio MCP server:

- command: `/Applications/macOS UI Bridge.app/Contents/MacOS/macos-ui-bridge`
- arguments: `mcp`
- working directory: `/Users/juln/Desktop/workspace/macos-ui-bridge` when the client requests one

The client must launch one process per MCP connection. Do not run the `mcp` command manually in a terminal for normal use.

## macOS permissions

Call `permissions_get`. When access is missing, the bridge opens a native dialog; choose **前往设置**, grant Accessibility and Screen Recording to the actual host process that launches the server, such as Cursor or WorkBuddy, then reopen that host.

Call `permissions_get` to confirm the state. Discovery can work with limited permissions, but UI reading and screenshots require the corresponding grants.

## Troubleshooting

- No tools: verify that `swift build` succeeded and the configured executable path exists.
- Process exits: run the self-test and inspect its stderr output.
- Empty windows: confirm the app is running and retry with the current pid from `apps_list`.
- Permission remains false: grant access to the client that launches MCP, then fully restart it.
