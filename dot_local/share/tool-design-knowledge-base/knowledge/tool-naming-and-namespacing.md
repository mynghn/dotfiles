---
name: tool-naming-and-namespacing
description: Use when naming a tool or function, choosing verbs/prefixes, grouping tools by service or resource, or fixing wrong-tool selection and name collisions in a crowded or multi-server (MCP) tool set.
last_refreshed: 2026-06-20
sources:
  - Anthropic, "Writing effective tools for agents — with agents", 2025 — https://www.anthropic.com/engineering/writing-tools-for-agents
  - Anthropic, "Building effective agents" (Appendix 2: Prompt engineering your tools), 2024 — https://www.anthropic.com/engineering/building-effective-agents
  - Model Context Protocol, "Tools" specification (2025-06-18), 2025 — https://modelcontextprotocol.io/specification/2025-06-18/server/tools
---

**What it is.** The tool's *name* is the primary selection key the model reads when deciding which function to call — and, under MCP, the literal `name` field functions as the tool's unique identifier passed in `tools/call`, so it carries both semantic and protocol weight (MCP spec, 2025). This practice covers two levers: (1) clear, action-oriented names that say what one tool does, and (2) namespacing — shared prefixes that group tools by service or resource and prevent collisions across a crowded or multi-server tool set.

**Why / Evidence.** When an agent has dozens of MCP servers and hundreds of tools, and "tools overlap in function or have a vague purpose, agents can get confused about which ones to use" — selection happens on names and descriptions before any call is made (Anthropic, 2025). Namespacing measurably helps the model select the right tools at the right time; Anthropic reports that even the choice between *prefix*- and *suffix*-based schemes "can have non-trivial effects" on eval results, varying by model (Anthropic, 2025). Distinct names with clear boundaries matter most when using many similar tools (Anthropic, 2024). The litmus test: "Is it obvious how to use this tool, based on the description and parameters, or would you need to think carefully about it? If so, then it's probably also true for the model" (Anthropic, 2024). At the protocol layer, names function as unique identifiers within a server, and an unrecognized name is a hard protocol error (`Unknown tool`), not a graceful degradation (MCP spec, 2025).

**How to apply.** Lead with a verb that names the action and a concrete object: prefer `search_contacts` / `message_contact` over a vague `list_contacts` whose purpose blurs into its neighbors (Anthropic, 2025). Namespace by a common prefix — service-based (`asana_search`, `jira_search`) or resource-based (`asana_projects_search`, `asana_users_search`) — to group families and dodge collisions when multiple servers expose same-named verbs (Anthropic, 2025); MCP clients sometimes auto-prefix merged servers with the server name so two `search` tools never clash. Keep names unambiguous and self-consistent across the set; if two names could plausibly both fit a request, rename until each maps to one job. Don't smuggle disambiguation that belongs in the name into the description — and don't lean on the description to rescue a vague name. Treat prefix-vs-suffix and the wording itself as eval-tunable, not settled by taste: test both on your own model (Anthropic, 2025).

**Takeaway.** Make the name carry the selection decision on its own: an action verb + object that names one job, under a service/resource prefix that prevents collisions — then let evals, not intuition, pick the scheme.

**Boundary.** General prose quality of the surrounding `description` text lives in [[tool-description-writing]]; *how many* tools to expose and pruning the overall set lives in [[tool-set-size-and-selection]]. This entry owns only the name string and its prefix.

Related: [[tool-description-writing]], [[tool-set-size-and-selection]], [[tool-granularity-and-consolidation]], [[input-schema-design]]
