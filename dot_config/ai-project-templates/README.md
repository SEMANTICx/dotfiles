# AI project configuration templates

These templates deliberately keep permissions and MCP activation project-local.
Review them before copying because each repository has different build commands
and trust boundaries.

For OpenCode:

```sh
cp ~/.config/ai-project-templates/opencode.json ./opencode.json
```

For Claude Code:

```sh
mkdir -p .claude
cp ~/.config/ai-project-templates/claude-settings.json .claude/settings.json
```

Keep `enableAllProjectMcpServers` disabled. Add individual MCP servers only after
reviewing the command, package, environment variables, and directories exposed
to that server.
