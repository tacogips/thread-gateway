# Meta Threads API Capability Matrix

Snapshot reviewed 2026-08-13. Factual authority: the official Meta HTML files
under `/tmp/thread_gateway_meta_docs`. `supported` means implemented and covered
offline; authenticated behavior is `live-test-pending` unless the operation is
purely local. Dashboard setup is recorded but is not an SDK endpoint.

## Endpoint and operation matrix

| Operation or feature | Method and path | Permission | SDK method or type | CLI command | Binary | Implementation | Test status |
|---|---|---|---|---|---|---|---|
| OAuth authorization window | local URL | requested set | `OAuthAuthorizationRequest.url` | `auth-url` | reader | supported | unit-covered |
| Code exchange | POST `/oauth/access_token` | app secret | `exchangeAuthorizationCode` | `oauth-exchange` | writer | supported | contract-covered; live-test-pending |
| Long-lived exchange | GET `/access_token` | app secret | `exchangeLongLivedToken` | `token-long-lived` | writer | supported | contract-covered; live-test-pending |
| Long-lived refresh | GET `/refresh_access_token` | user token | `refreshLongLivedToken` | `token-refresh` | writer | supported | contract-covered; live-test-pending |
| App access token | GET `/oauth/access_token` | app secret | `getAppAccessToken` | `app-token` | writer | supported | contract-covered; live-test-pending |
| Token debug | GET `/debug_token` | app token | `debugToken` | `token-debug` | reader | supported | contract-covered; live-test-pending |
| Self/app-scoped profile | GET `/{user-id}` | `threads_basic` | `getUser` | `me` | reader | supported | contract-covered; live-test-pending |
| Public profile lookup | GET `/profile_lookup` | `threads_profile_discovery` | `lookupProfile` | `profile` | reader | supported | contract-covered; live-test-pending |
| User posts | GET `/{user-id}/threads` | `threads_basic` | `getUserPosts` | `posts` | reader | supported | all fields/date/limit/cursor parameters contract-covered; live-test-pending |
| Public profile posts | GET `/profile_posts` | `threads_profile_discovery` | `getProfilePosts` | `profile-posts` | reader | supported | all fields/date/limit/cursor parameters contract-covered; live-test-pending |
| User replies | GET `/{user-id}/replies` | `threads_read_replies` | `getUserReplies` | `user-replies` | reader | supported | all fields/date/limit/cursor parameters contract-covered; live-test-pending |
| Mentions | GET `/{user-id}/mentions` | `threads_manage_mentions` | `getMentions` | `mentions` | reader | supported | all fields/date/limit/cursor parameters contract-covered; live-test-pending |
| Ghost posts | GET `/{user-id}/ghost_posts` | `threads_basic` | `getGhostPosts` | `ghost-posts` | reader | supported | all fields including status/expiration plus date/limit/cursor parameters contract-covered; live-test-pending |
| Media retrieval | GET `/{media-id}` | `threads_basic` | `getMedia` | `media` | reader | supported | media decoding covered; live-test-pending |
| Keyword search | GET `/keyword_search` | `threads_keyword_search` | `searchKeyword` | `keyword-search` | reader | supported | all filters, fields, dates, and limit contract-covered; live-test-pending |
| Location search by query or paired coordinates | GET `/location_search` | `threads_location_tagging` | `searchLocations` | `location-search` | reader | supported | `query` mapping, fields, and coordinate-pair validation covered; live-test-pending |
| Location retrieval | GET `/{location-id}` | `threads_location_tagging` | `getLocation` | `location` | reader | supported | all fields request/decoding-covered; live-test-pending |
| Publishing limit | GET `/{user-id}/threads_publishing_limit` | `threads_basic` plus operation scopes | `getPublishingLimit` | `publishing-limit` | reader | supported | all eight quota/config fields request/decoding-covered; live-test-pending |
| Container status | GET `/{container-id}` | `threads_basic` | `getContainerStatus` | `container-status` | reader | supported | decoding-covered; live-test-pending |
| Media insights | GET `/{media-id}/insights` | `threads_manage_insights` | `getMediaInsights` | `media-insights` | reader | supported | contract-covered; live-test-pending |
| User insights | GET `/{user-id}/threads_insights` | `threads_manage_insights` | `getUserInsights` | `user-insights` | reader | supported | contract-covered; live-test-pending |
| Direct replies | GET `/{media-id}/replies` | `threads_read_replies` | `getReplies` | `replies` | reader | supported | fields/reverse/before/after contract-covered; live-test-pending |
| Conversation | GET `/{media-id}/conversation` | `threads_read_replies` | `getConversation` | `conversation` | reader | supported | fields/reverse/before/after contract-covered; live-test-pending |
| Pending replies | GET `/{media-id}/pending_replies` | `threads_manage_replies` | `getPendingReplies` | `pending-replies` | reader | supported | fields/status/reverse/before/after contract-covered; live-test-pending |
| oEmbed | GET `/oembed` | none | `getOEmbed` | `oembed` | reader | supported | unauthenticated request and decoding covered; live-test-pending |
| Create text/image/video/carousel container | POST `/{user-id}/threads` | `threads_content_publish` | `createPostContainer`, `CreatePostRequest` | `create` | writer | supported | all media variants covered; live-test-pending |
| Create reply | POST `/{user-id}/threads` + `reply_to_id` | `threads_content_publish` | `CreatePostRequest.replyToID` | `create --reply-to-id` | writer | supported | encoding-covered; live-test-pending |
| Create quote | POST `/{user-id}/threads` + `quote_post_id` | `threads_content_publish` | `CreatePostRequest.quotePostID` | `create --quote-post-id` | writer | supported | encoding-covered; live-test-pending |
| Publish container | POST `/{user-id}/threads_publish` | `threads_content_publish` | `publishContainer` | `publish` | writer | supported | contract-covered; live-test-pending |
| Repost | POST `/{media-id}/repost` | `threads_content_publish` | `repost` | `repost` | writer | supported | contract-covered; live-test-pending |
| Delete post | DELETE `/{media-id}` | `threads_delete` | `deletePost` | `delete` | writer | supported | deletion-covered; live-test-pending |
| Hide/unhide reply | POST `/{reply-id}/manage_reply` | `threads_manage_replies` | `setReplyHidden` | `hide-reply`, `unhide-reply` | writer | supported | contract-covered; live-test-pending |
| Approve/ignore pending reply | POST `/{reply-id}/manage_pending_reply` | `threads_manage_replies` | `managePendingReply` | `approve-reply`, `ignore-reply` | writer | supported | contract-covered; live-test-pending |
| Webhook callback verification | local GET handling | configured token | `WebhookVerificationRequest` | `webhook-verify` | reader | supported | unit-covered |
| Webhook notification parsing | local POST body handling | topic-dependent | `ThreadsWebhookPayload.parse` | `webhook-parse` | reader | supported | unit-covered |
| Post/follow web intents | local URL construction | none | `PostIntent`, `FollowIntent` | `intent-post`, `intent-follow` | reader | supported | unit-covered |

## Publishing feature matrix

All rows use POST `/{user-id}/threads`, `threads_content_publish`, the writer
binary, and the `create` command. Location and Story cross-share additionally
require the permissions shown.

| Feature | Typed representation / CLI option | Additional permission | Status |
|---|---|---|---|
| Text, image, video, carousel | `MediaType`; `--media-type` | none | supported; live-test-pending |
| Reel-equivalent video | `MediaType.video` (`VIDEO`, never `REEL`) | none | supported; live-test-pending |
| Carousel children | `children`; `--children` | none | supported; live-test-pending |
| Poll | `PollAttachment.optionA...optionD`; `--poll-options` | none | supported; live-test-pending |
| Automatic text publish | `autoPublishText`; `--auto-publish-text` | none | supported; live-test-pending |
| Topic tag | `topicTag`; `--topic-tag` | none | supported; live-test-pending |
| Link attachment | `linkAttachment`; `--link-attachment` | none | supported; live-test-pending |
| Alt text | `altText`; `--alt-text` | none | supported; live-test-pending |
| Geo-gating | `allowlistedCountryCodes`; `--allowlisted-country-codes` | none | supported; live-test-pending |
| Text spoilers | `textEntities` | none | supported; live-test-pending |
| Media spoiler | `isSpoilerMedia`; `--spoiler-media` | none | supported; live-test-pending |
| Text attachment and styling | `TextAttachment`, `TextStylingRange`; `--text-attachment-text`, `--text-attachment-url`, `--text-attachment-styles` | none | supported; encoding-covered; live-test-pending |
| GIF attachment | `GIFAttachment`; `--gif-id`, `--gif-provider` | none | supported; live-test-pending |
| Ghost post | `isGhostPost`; `--ghost-post` | none | supported; live-test-pending |
| Reply approvals | `enableReplyApprovals`; `--enable-reply-approvals` | `threads_manage_replies` | supported; live-test-pending |
| Location tagging | `locationID`; `--location-id` | `threads_location_tagging` | supported; live-test-pending |
| Instagram Story cross-share | `crossReshareToInstagram`, dark mode options | `threads_share_to_instagram` | supported; live-test-pending |
| App creation/configuration | Meta App Dashboard | n/a | dashboard-only |
| Webhook topic subscription | Meta App Dashboard | Advanced Access | dashboard-only |
| Graph API Explorer token grants | Meta dashboard tool | n/a | dashboard-only |
| Official Postman collection | external reference collection | n/a | not-applicable to SDK |
| Hosting local image/video files | external public HTTPS host | n/a | not-applicable to SDK |

## Parameter and returned-field coverage

| Surface | Representation | Coverage decision |
|---|---|---|
| App-scoped profile fields | `ThreadsUserField`, `ThreadsUser` | implemented; all reference fields plus public-profile counters and recently searched keywords |
| Media fields | `ThreadsMediaField`, `ThreadsMedia` | implemented; union of media, post, reply, mention, ghost, keyword, poll, text-attachment, and location-tagging fields |
| Location fields | `LocationField`, `Location` | implemented; all eight reference fields |
| Publishing-limit fields | `PublishingLimitField`, `PublishingQuotaUsage` | implemented; publish, reply, delete, and location-search usage/config pairs |
| Container fields | `ContainerStatusField`, `ContainerStatus` | implemented; `id`, `status`, and `error_message` |
| Debug-token and oEmbed fields | `DebugTokenData`, `OEmbed` | implemented; every field on their reference pages |
| Insight response variants | `Insight`, `InsightValue`, breakdown/link value types | implemented; time series, total values, link totals, and demographic breakdowns |
| Location search name discrepancy | SDK/CLI send `query` | the authoritative reference page and requested contract use `query`; the older location-tagging guide examples still show `q` |
| Provider behavior | authenticated endpoints and unauthenticated oEmbed | live-test-pending; no secrets or live calls were used |
| App creation and webhook subscriptions | Meta App Dashboard | dashboard-only |
| Postman collection and public media hosting | external tools/services | not-applicable to SDK |

## Official source inventory and update dates

| File | Updated |
|---|---|
| `changelog.html` | 2026-08-12 |
| `create-posts.html` | 2026-07-02 |
| `create-posts__ghost-posts.html` | 2026-07-02 |
| `create-posts__location-tagging.html` | 2026-07-02 |
| `create-posts__polls.html` | 2026-07-02 |
| `create-posts__share-to-ig-stories.html` | 2026-07-02 |
| `create-posts__spoilers.html` | 2026-07-02 |
| `create-posts__text-attachments.html` | 2026-07-02 |
| `get-started.html` | 2026-06-30 |
| `get-started__app-access-tokens.html` | 2026-07-02 |
| `get-started__create-an-app.html` | 2025-06-04 |
| `get-started__get-access-tokens-and-permissions.html` | 2026-08-12 |
| `get-started__long-lived-tokens.html` | 2025-03-27 |
| `insights.html` | 2026-01-30 |
| `keyword-search.html` | 2026-01-21 |
| `overview.html` | 2025-12-22 |
| `posts.html` | 2026-04-14 |
| `posts__accessibility.html` | 2024-08-21 |
| `posts__delete-posts.html` | 2025-07-22 |
| `posts__geo-gating.html` | 2024-08-19 |
| `posts__quote-posts.html` | 2025-12-22 |
| `posts__reposts.html` | 2024-12-16 |
| `reference.html` | 2025-10-17 |
| `reference__debug.html` | 2025-06-04 |
| `reference__insights.html` | 2024-11-08 |
| `reference__location-search.html` | 2025-07-22 |
| `reference__locations.html` | 2025-05-27 |
| `reference__media-retrieval.html` | 2026-04-20 |
| `reference__oembed.html` | 2026-03-03 |
| `reference__publishing.html` | 2026-04-20 |
| `reference__reply-management.html` | 2026-02-13 |
| `reference__user.html` | 2025-12-16 |
| `reply-management.html` | 2026-02-13 |
| `retrieve-and-discover-posts.html` | 2025-06-12 |
| `retrieve-and-discover-posts__retrieve-posts.html` | 2026-04-14 |
| `retrieve-and-manage-replies.html` | 2025-03-21 |
| `retrieve-and-manage-replies__create-replies.html` | 2025-12-22 |
| `retrieve-and-manage-replies__replies-and-conversations.html` | 2026-02-02 |
| `retrieve-and-manage-replies__retrieve-replies.html` | 2026-02-02 |
| `threads-mentions.html` | 2025-03-27 |
| `threads-profiles.html` | 2026-04-13 |
| `threads-web-intents.html` | 2026-03-19 |
| `tools-and-resources.html` | 2025-03-21 |
| `tools-and-resources__embed-a-threads-post.html` | 2026-03-03 |
| `tools-and-resources__postman-collection.html` | 2026-05-06 |
| `troubleshooting.html` | 2025-07-14 |
| `troubleshooting__debug-access-token.html` | 2025-06-04 |
| `webhooks.html` | 2026-06-30 |
