# thread-gateway

Swift 6 SDK and two least-privilege command-line clients for the Meta Threads
API:

- `ThreadGateway`: typed public library with injected transport, OAuth, paging,
  provider errors, webhook parsing, and web intents.
- `thread-gateway-reader`: read/non-mutating operations and reader scopes.
- `thread-gateway-writer`: credential exchange and mutating operations with
  writer scopes.

There is no umbrella `thread-gateway` executable. See the
[capability matrix](design-docs/specs/threads-api-capability-matrix.md) for every
official operation, permission, SDK method, command, binary, test, and source
update date.

## Development

```bash
mise install
mise run lint
mise run test
mise run build
swift run thread-gateway-reader --help
swift run thread-gateway-writer --help
swift run thread-gateway-reader scopes
swift run thread-gateway-writer scopes
```

## Configuration and OAuth

Secrets are environment-only and should be injected by `kinko`; never put token
or app-secret values in repository files, shell history, examples, or ordinary
configuration.

The commands recognize these variable names as applicable:

```text
THREADS_APP_ID
THREADS_APP_SECRET
THREADS_REDIRECT_URI
THREADS_AUTH_CODE
THREADS_ACCESS_TOKEN
THREADS_APP_ACCESS_TOKEN
THREADS_INPUT_TOKEN
THREADS_WEBHOOK_VERIFY_TOKEN
```

Construct a reader authorization URL without exposing a secret:

```bash
kinko exec --env THREADS_APP_ID,THREADS_REDIRECT_URI -- \
  swift run thread-gateway-reader auth-url
```

After the operator completes consent and stores the returned code in kinko,
exchange and extend the token:

```bash
kinko exec --env THREADS_APP_ID,THREADS_APP_SECRET,THREADS_REDIRECT_URI,THREADS_AUTH_CODE -- \
  swift run thread-gateway-writer oauth-exchange

kinko exec --env THREADS_APP_SECRET,THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-writer token-long-lived

kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-writer token-refresh
```

The JSON token responses are sensitive. Capture them only into the operator's
approved secret workflow; do not paste them into files or logs.

## Parameter-complete read examples

Search by keyword with the documented filters and returned media fields:

```bash
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-reader keyword-search --query Swift \
  --search-type RECENT --search-mode KEYWORD --media-type TEXT \
  --fields id,text,media_type,permalink,username,timestamp \
  --since 2026-08-01 --until 2026-08-13 --limit 50 --author-username threads
```

Search locations by the documented `query` parameter, or by a complete
latitude/longitude pair. `--fields` accepts every location field from the
reference page.

```bash
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-reader location-search --query "Menlo Park" \
  --fields id,name,address,city,country,latitude,longitude,postal_code

kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-reader location-search \
  --latitude 37.484 --longitude -122.149 --fields id,name,latitude,longitude
```

All user/profile post, user reply, mention, and ghost-post list commands expose
`--fields`, `--since`, `--until`, `--limit`, `--before`, and `--after`.
Direct reply, conversation, and pending-reply commands expose their documented
`--fields`, `--reverse`, `--before`, and `--after` cursors.

## Live smoke tests

The workflow does not execute these authenticated mutations. The controlling
operator can run them after app setup, permission review, kinko authentication,
and supplying public HTTPS media URLs. Record the returned container and media
IDs in shell variables or an approved secret-safe runner.

Text create, publish, retrieve, and delete:

```bash
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-writer create --user-id me --media-type TEXT --text "smoke test"
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-writer publish --user-id me --creation-id "$THREADS_CONTAINER_ID"
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-reader media --media-id "$THREADS_MEDIA_ID"
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-writer delete --media-id "$THREADS_MEDIA_ID"
```

Image create, publish, retrieve, and delete:

```bash
kinko exec --env THREADS_ACCESS_TOKEN,THREADS_IMAGE_URL -- \
  bash -lc 'swift run thread-gateway-writer create --user-id me --media-type IMAGE --image-url "$THREADS_IMAGE_URL"'
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-writer publish --user-id me --creation-id "$THREADS_CONTAINER_ID"
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-reader media --media-id "$THREADS_MEDIA_ID"
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-writer delete --media-id "$THREADS_MEDIA_ID"
```

Video create, publish, retrieve, and delete:

```bash
kinko exec --env THREADS_ACCESS_TOKEN,THREADS_VIDEO_URL -- \
  bash -lc 'swift run thread-gateway-writer create --user-id me --media-type VIDEO --video-url "$THREADS_VIDEO_URL"'
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-writer publish --user-id me --creation-id "$THREADS_CONTAINER_ID"
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-reader media --media-id "$THREADS_MEDIA_ID"
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-writer delete --media-id "$THREADS_MEDIA_ID"
```

Meta documents no separate `REEL` media type: reel-equivalent Threads posts use
`VIDEO`.

For a carousel, create IMAGE or VIDEO child containers, then create, publish,
retrieve, and delete the parent:

```bash
kinko exec --env THREADS_ACCESS_TOKEN,THREADS_IMAGE_URL -- \
  bash -lc 'swift run thread-gateway-writer create --user-id me --media-type IMAGE --image-url "$THREADS_IMAGE_URL" --carousel-item true'
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-writer create --user-id me --media-type CAROUSEL \
  --children "$THREADS_CHILD_CONTAINER_IDS"
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-writer publish --user-id me --creation-id "$THREADS_CONTAINER_ID"
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-reader media --media-id "$THREADS_MEDIA_ID"
kinko exec --env THREADS_ACCESS_TOKEN -- \
  swift run thread-gateway-writer delete --media-id "$THREADS_MEDIA_ID"
```

Respect Meta container processing status and publishing limits before
publishing.

## Homebrew release workflows

Existing formula and signed/notarized Cask workflows remain available and now
stage both executable products in the `thread-gateway` release artifact. See
`packaging/homebrew/README.md` and `.agents/skills/` before release work.
