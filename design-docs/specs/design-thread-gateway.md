# Thread Gateway Design

## Status and authority

Implemented for Swift 6. The only API factual authority is the 48-page official
Meta snapshot in `/tmp/thread_gateway_meta_docs`. Its changelog was updated
2026-08-12; individual page dates are recorded in
`threads-api-capability-matrix.md`. Live behavior still requires operator-owned
credentials and remains explicitly pending.

## Package boundary

`ThreadGateway` is the single public library. It contains only provider-neutral
transport injection plus typed Threads DTOs, requests, errors, pagination,
OAuth helpers, webhook parsing, web intents, and API operations.

Two thin executables depend on it:

- `thread-gateway-reader` exposes read/non-mutating business operations and the
  reader scope set.
- `thread-gateway-writer` exposes publishing, token exchange, moderation, and
  deletion operations and the writer scope set.

There is no umbrella executable. Shared support code does not merge the command
catalogs or OAuth scope projections.

## Transport and concurrency

`ThreadsTransport` is an injected `Sendable` async protocol. `ThreadsClient` is
a `Sendable` value that creates typed `APIRequest` values and decodes typed
responses. `URLSessionThreadsTransport` performs form or query encoding. Tests
inject an actor-based recording transport, so no network or secrets are needed.

All public DTOs are `Codable`, `Equatable`, and `Sendable`. Provider error
envelopes become `ThreadsAPIError.provider`; malformed success responses become
`ThreadsAPIError.decoding`. Paginated endpoints return `ThreadsPage<Element>`
with typed cursors and next/previous URLs.

## Authorization and configuration

The library defines closed `ThreadsAuthorizationScope` values. Reader scopes
include the minimum grants required by all documented GET endpoints; this
necessarily overlaps writer grants for pending-reply and location reads.
Authorization URLs are constructed locally. Access tokens and app credentials are accepted from command options or
environment variables; production use injects the variables through `kinko`.
The package never persists credentials.

OAuth code exchange, long-lived exchange/refresh, and app-token creation are
writer commands because they create or rotate credentials. Token debug is a
reader command because it is observational.

## Operations

The capability matrix is the traceability contract. Every reference endpoint
has an explicit typed client method. Publishing variants share
`CreatePostRequest`, whose closed `MediaType` is `TEXT`, `IMAGE`, `VIDEO`, or
`CAROUSEL`. Meta documents no separate `REEL` type; reel-equivalent posts use
`media_type=VIDEO`.

Replies and quotes use the same container endpoint with typed IDs. Polls,
automatic text publish, topic tags, links, alt text, country allowlists,
spoilers, styled text attachments, provider GIF IDs, ghost posts, reply
approvals, location tagging, and Instagram Story cross-share are typed creation
fields. Hide/unhide, approve/ignore, repost, publish, and delete are distinct
writer methods.

Webhook verification checks the subscription mode and configured verification
token, then returns the challenge. Notification JSON decodes into a typed
payload. Post and follow web intents are local URL builders and require no API
token.

## CLI contract

Both CLIs support `--help`, `--version`, and `scopes`. Reader help contains only
read/local commands. Writer help contains only credential-management and
mutating commands. JSON output is stable and suitable for automation. Errors go
to standard error with a nonzero exit status.

## Verification

Contract tests assert HTTP methods, paths, parameters, form/query encoding,
decoding, provider errors, paging, media variants, deletion, webhook behavior,
web intents, and scope separation. Required release checks are `swiftlint`,
`swift test`, `swift build`, both `mise` equivalents, and both executable help
commands. Live smoke commands are documented but are never run by this workflow.
