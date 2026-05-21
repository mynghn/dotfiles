# grpcurl

Make ad-hoc gRPC calls against a service. The skill handles the four recurring frictions: choosing a schema source, picking the right proto module, formatting the auth header, and shaping the request payload.

**Default to autonomous decisions.** Ask the user only when (a) ambiguity can't be removed by inspection, or (b) a sensitive choice (which env, which token) deserves explicit confirmation. Never invent tokens.

## Procedure

### 0) Preflight — verify required tools

Before any other step, gate on tool availability. Don't assume any package manager or install path.

```sh
command -v grpcurl >/dev/null 2>&1 && grpcurl --version 2>&1 | head -1
```

- If `grpcurl` is missing → stop and tell the user it must be installed. Do not suggest a specific package manager; ask them how they'd like to install it (their OS/setup determines this) and resume only after they confirm it's on `$PATH`.
- Defer the `buf` check until step 2 confirms the descriptor path is needed (reflection may make `buf` unnecessary). When `buf` is needed:

```sh
command -v buf >/dev/null 2>&1 && buf --version 2>&1 | head -1
```

If `buf` is missing, stop with the same pattern — surface the requirement, don't prescribe an install command.

### 1) Endpoint + service/method

Take from the user's prompt if provided. Otherwise:
- If the prompt mentions a host (e.g. a public ingress hostname, a K8s cluster-internal name like `*.svc.cluster.local`), use it.
- If they mentioned a method name only, defer resolving its full path until step 2.
- If still ambiguous, ask — endpoint first, method second.

`endpoint` form: `host:port`. Decide transport by hostname: `*.svc.cluster.local` and other in-cluster endpoints typically need `-plaintext`; public ingress on `:443` is TLS. When unsure, probe TLS first; switch to `-plaintext` if you see a TLS handshake error.

### 2) Schema source — reflection or descriptor?

**Probe reflection first** (single fast check):

```sh
grpcurl <tls-flag> <endpoint> list 2>&1 | head -20
```

- If output lists services → **use reflection**. No `-proto`/`-protoset` flag needed downstream. Done.
- If output is `Failed to list services: server does not support the reflection API` (or similar) → fall back to descriptor.

**Descriptor fallback:**

a) **Pick the buf module** that owns the service's package. The fully-qualified service name's package prefix usually maps to a specific proto repo + subdirectory. Search known proto repositories on disk with `find <workspace> -maxdepth 4 -name buf.yaml`, then narrow by reading the module's `buf.yaml` `name:` field or by grep-ing for the `package` declaration inside the module.
   - If multiple modules plausibly match, ask the user. Don't guess silently — picking the wrong module produces confusing "unresolved import" errors downstream.

b) **Build the descriptor** from inside the module root:

```sh
cd <buf-module-root>
buf build -o /tmp/grpcurl-<short>.binpb
```

   `buf build` resolves transitive imports via `buf.yaml` deps in one pass — do NOT try to stack `-proto -import-path` flags manually; that path repeatedly fails on cross-folder imports (well-known types, shared common modules, etc.).

   If `buf build` errors on missing deps, run `buf dep update` in the module root, then retry.

c) **Pass `-protoset /tmp/grpcurl-<short>.binpb`** to grpcurl for the actual call.

### 3) Auth

Detect from the user-provided token, or ask if absent. Common patterns:

| Token shape | Header |
|---|---|
| 3 dot-separated b64 segments starting with `eyJ` (JWT) | `Authorization: Bearer <jwt>` |
| Org-specific token with a recognizable prefix (e.g. `<PREFIX>-…`) | `Authorization: <token>` *or* `Authorization: Bearer <token>` — depends on the org's gateway; if the user's prompt shows the literal prefix, treat it as the full credential and don't add `Bearer` unless told to |
| Opaque service-to-service token | A custom header named by the org's gateway (often `x-…-service-token` or `x-api-key`) |
| Anon / public method | no header |

If the prompt mentions a custom header (e.g. preview-routing header, tenant ID), include it as `-H "<Name>: <value>"`. Ask the user only if a custom header is *implied* but not spelled out.

Never embed a real token in conversation output you echo back unredacted. When showing the user the command for review, replace the token value with `<TOKEN>` and only inject it at execution time.

### 4) Payload

a) **Discover the request shape**:

```sh
# Reflection path:
grpcurl <tls-flag> <endpoint> describe <service>.<MethodRequest>

# Descriptor path:
grpcurl -protoset /tmp/grpcurl-<short>.binpb describe <service>.<MethodRequest>
```

b) **Author the JSON**:
- For payloads with ≤4 leaf fields → propose the full JSON inline, ask the user to confirm or edit.
- For larger / nested payloads → emit a JSON template with required fields scaffolded (using sane placeholders or values inferred from the user's prompt), and ask the user to fill or correct.
- **proto3 quirks to handle silently** (these follow the [protobuf JSON mapping spec](https://protobuf.dev/programming-guides/json/) — `grpcurl` rejects shapes that aren't spec-compliant on the way in):
  - Enums as integers OR symbolic names — both work; prefer the symbolic form in scaffolds.
  - `google.protobuf.Timestamp` → **RFC 3339 string**, e.g. `"2026-05-22T00:00:00Z"`. The `{"seconds": "..."}` raw-wire form (what Kotlin/Java builders use internally) is **not** accepted by JSON unmarshal — `grpcurl` returns `cannot unmarshal object into Go value of type string`.
  - `google.protobuf.Duration` → string ending in `s`, e.g. `"3.5s"`, `"600s"`.
  - `google.type.Interval` (nested) → `{"startTime": "<RFC3339>", "endTime": "<RFC3339>"}` — its inner fields are Timestamps and follow the rule above.
  - Wrapper types (`StringValue`, `Int32Value`, `BoolValue`, …) → encoded as the wrapped value directly, **not** as an object. `Int32Value(42)` → `42`, `StringValue("x")` → `"x"`, not `{"value": …}`.
  - `oneof` — set exactly one branch; omit the others.
  - `optional` scalar fields in proto3 — present as JSON `null` only when intentionally absent; otherwise omit.

c) **Don't fabricate identifiers** (IDs, foreign keys, secrets). If the user didn't supply them, ask.

### 5) Execute

Compose and run:

```sh
grpcurl \
  <tls-flag-or-empty> \
  <-protoset /tmp/...binpb  OR omitted for reflection> \
  -H "Authorization: <token>" \
  [-H "<extra-header>: <value>"] \
  -d '<json>' \
  <endpoint> \
  <service>/<Method>
```

### Response display rules

Always show the **actual response** to the user, success or failure — never substitute a summary or interpretation alone. Redact secrets (tokens, etc.) before display.

| Response size | How to display |
|---|---|
| Fits in chat in one shot (roughly ≤ 4 KB or ≤ 80 lines) | Emit the **full raw JSON in a fenced code block**, then add any interpretation underneath. |
| Larger than that | (1) Save full body to a temp file and state the path; (2) inline a generous representative slice as raw JSON (e.g. the first few elements of a list) so structure is visible; (3) add a `jq`-derived summary (count, pagination, key fields); (4) explicitly point to `<path>` for the remainder. A response that exists only as a summary, with no reachable raw, is not acceptable. |
| gRPC status error | Print the status code, message, **and all trailers** — especially `google.rpc.ErrorInfo` (`domain`, `reason`, `metadata`). If ErrorInfo is empty, say so explicitly so the user isn't left guessing whether you suppressed it. |

Always print the invoking command above the response with the token redacted to `<TOKEN>` so the user can reproduce the call themselves.

### Failure patterns

Capture stdout+stderr. Common failure patterns and remediation:

| Symptom | Likely cause | Next step |
|---|---|---|
| `Failed to list services: ... reflection API` | reflection disabled | switch to descriptor (step 2 fallback) |
| `Unimplemented` / `unknown service` | wrong service FQN, or endpoint doesn't host this service | re-verify FQN; check the endpoint is the right tier (gateway vs deeper backend) |
| `Unauthenticated` / `PermissionDenied` | wrong token shape (e.g. unwanted `Bearer` prefix) | flip header form; ask user to refresh token if expired |
| `InvalidArgument` with field name | payload field missing/wrong type | re-describe request type, fix the JSON |
| `Connection reset by peer` / `Unavailable` (~ms duration) | upstream unhealthy or routing broken — not the request | not a grpcurl-side fix; surface to the user to debug at infra/trace level |

Print the response with the command (token redacted) and a 1-line interpretation of the status.

## Notes

- For payloads sourced from a file the user already has, prefer `-d @path/to/payload.json` over inlining.
- For streaming methods, `grpcurl` reads newline-delimited JSON messages from stdin via `-d @-`; flag this if the method is server/client/bidi-streaming.
- When the user iterates with multiple calls in a session, keep the chosen schema source and auth header constant unless they change scope.
