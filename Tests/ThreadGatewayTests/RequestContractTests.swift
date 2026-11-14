import Foundation
import Testing
@testable import ThreadGateway

@Suite("Threads API request contracts")
struct RequestContractTests {
  @Test func userPostPagingMapsEveryDocumentedParameter() async throws {
    let transport = RecordingTransport(json: #"{"data":[],"paging":{"cursors":{"after":"next"}}}"#)
    let client = ThreadsClient(accessToken: "fixture-token", transport: transport)

    _ = try await client.getUserPosts(
      userID: "me", fields: [.id, .locationID], since: "2026-01-01", until: "2026-02-01",
      limit: 25, before: "cursor", after: nil
    )

    let request = try #require(await transport.lastRequest())
    #expect(request.method == .get)
    #expect(request.path == "v1.0/me/threads")
    #expect(request.query["fields"] == "id,location_id")
    #expect(request.query["since"] == "2026-01-01")
    #expect(request.query["until"] == "2026-02-01")
    #expect(request.query["limit"] == "25")
    #expect(request.query["before"] == "cursor")
    #expect(request.query["after"] == nil)
    #expect(request.query["access_token"] == "fixture-token")
  }

  @Test func profileReplyMentionAndGhostPagingMapEveryDocumentedParameter() async throws {
    let transport = RecordingTransport(json: #"{"data":[]}"#)
    let client = ThreadsClient(accessToken: "token", transport: transport)

    _ = try await client.getProfilePosts(
      username: "threads", fields: [.id], since: "1", until: "2",
      limit: 10, before: "profile-before", after: nil
    )
    var request = try #require(await transport.lastRequest())
    #expect(request.path == "v1.0/profile_posts")
    #expect(request.query["username"] == "threads")
    #expect(request.query["fields"] == "id")
    #expect(request.query["since"] == "1")
    #expect(request.query["until"] == "2")
    #expect(request.query["limit"] == "10")
    #expect(request.query["before"] == "profile-before")

    _ = try await client.getProfilePosts(username: "threads", after: "profile-after")
    request = try #require(await transport.lastRequest())
    #expect(request.query["after"] == "profile-after")

    _ = try await client.getUserReplies(
      userID: "me", fields: [.id], since: "3", until: "4",
      limit: 20, before: "replies-before", after: nil
    )
    request = try #require(await transport.lastRequest())
    #expect(request.path == "v1.0/me/replies")
    #expect(request.query["fields"] == "id")
    #expect(request.query["since"] == "3")
    #expect(request.query["until"] == "4")
    #expect(request.query["limit"] == "20")
    #expect(request.query["before"] == "replies-before")

    _ = try await client.getUserReplies(userID: "me", after: "replies-after")
    request = try #require(await transport.lastRequest())
    #expect(request.query["after"] == "replies-after")

    _ = try await client.getMentions(
      userID: "me", fields: [.id], since: "5", until: "6",
      limit: 30, before: "mentions-before", after: nil
    )
    request = try #require(await transport.lastRequest())
    #expect(request.path == "v1.0/me/mentions")
    #expect(request.query["fields"] == "id")
    #expect(request.query["since"] == "5")
    #expect(request.query["until"] == "6")
    #expect(request.query["limit"] == "30")
    #expect(request.query["before"] == "mentions-before")

    _ = try await client.getMentions(userID: "me", after: "mentions-after")
    request = try #require(await transport.lastRequest())
    #expect(request.query["after"] == "mentions-after")

    _ = try await client.getGhostPosts(
      userID: "me", fields: [.id, .ghostPostStatus, .ghostPostExpirationTimestamp],
      since: "7", until: "8", limit: 40, before: "ghost-before", after: nil
    )
    request = try #require(await transport.lastRequest())
    #expect(request.path == "v1.0/me/ghost_posts")
    #expect(request.query["fields"] == "id,ghost_post_status,ghost_post_expiration_timestamp")
    #expect(request.query["since"] == "7")
    #expect(request.query["until"] == "8")
    #expect(request.query["limit"] == "40")
    #expect(request.query["before"] == "ghost-before")

    _ = try await client.getGhostPosts(userID: "me", after: "ghost-after")
    request = try #require(await transport.lastRequest())
    #expect(request.query["after"] == "ghost-after")
  }

  @Test func typedProfileAndMediaFieldsMapAllDocumentedSelections() async throws {
    let transport = RecordingTransport(json: #"{"id":"user"}"#)
    let client = ThreadsClient(accessToken: "token", transport: transport)

    _ = try await client.getUser(id: "me", fields: ThreadsUserField.defaultFields)
    var request = try #require(await transport.lastRequest())
    #expect(request.query["fields"] == "id,username,name,threads_profile_picture_url,threads_biography,is_verified,recently_searched_keywords")

    await transport.setResponse(json: #"{"id":"media"}"#)
    _ = try await client.getMedia(id: "media", fields: ThreadsMediaField.allDocumentedFields)
    request = try #require(await transport.lastRequest())
    let requestedFields = Set(try #require(request.query["fields"]).split(separator: ",").map(String.init))
    #expect(requestedFields == Set(ThreadsMediaField.allCases.map(\.rawValue)))
  }

  @Test func OAuthCodeExchangeUsesFormEncodingAndNoImplicitToken() async throws {
    let transport = RecordingTransport(json: #"{"access_token":"short","user_id":"42"}"#)
    let client = ThreadsClient(accessToken: "must-not-leak", transport: transport)

    _ = try await client.exchangeAuthorizationCode(
      clientID: "app",
      clientSecret: "secret",
      redirectURI: URL(string: "https://example.test/callback")!,
      code: "code"
    )

    let request = try #require(await transport.lastRequest())
    #expect(request.method == .post)
    #expect(request.path == "oauth/access_token")
    #expect(request.query["access_token"] == nil)
    #expect(request.form["grant_type"] == "authorization_code")
    #expect(request.form["redirect_uri"] == "https://example.test/callback")
  }

  @Test func keywordSearchMapsEveryDocumentedParameter() async throws {
    let transport = RecordingTransport(json: #"{"data":[]}"#)
    let client = ThreadsClient(accessToken: "token", transport: transport)

    _ = try await client.searchKeyword(
      query: "swift", searchType: .recent, searchMode: .tag, mediaType: .image,
      fields: [.id, .text, .topicTag], since: "1700000000", until: "1710000000",
      limit: 10, authorUsername: "threads"
    )
    let request = try #require(await transport.lastRequest())
    #expect(request.path == "v1.0/keyword_search")
    #expect(request.query["q"] == "swift")
    #expect(request.query["search_type"] == "RECENT")
    #expect(request.query["search_mode"] == "TAG")
    #expect(request.query["media_type"] == "IMAGE")
    #expect(request.query["fields"] == "id,text,topic_tag")
    #expect(request.query["since"] == "1700000000")
    #expect(request.query["until"] == "1710000000")
    #expect(request.query["limit"] == "10")
    #expect(request.query["author_username"] == "threads")
  }

  @Test func locationSearchUsesQueryFieldsAndPairedCoordinates() async throws {
    let transport = RecordingTransport(json: #"{"data":[]}"#)
    let client = ThreadsClient(accessToken: "token", transport: transport)

    _ = try await client.searchLocations(
      query: "Menlo Park", latitude: 37.48, longitude: -122.15,
      fields: [.id, .name, .postalCode]
    )
    let request = try #require(await transport.lastRequest())
    #expect(request.path == "v1.0/location_search")
    #expect(request.query["query"] == "Menlo Park")
    #expect(request.query["q"] == nil)
    #expect(request.query["latitude"] == "37.48")
    #expect(request.query["longitude"] == "-122.15")
    #expect(request.query["fields"] == "id,name,postal_code")

    do {
      _ = try await client.searchLocations(latitude: 37.48)
      Issue.record("expected coordinate pair validation")
    } catch let ThreadsAPIError.invalidInput(message) {
      #expect(message.contains("together"))
    }
  }

  @Test func locationQuotaContainerAndInsightFieldsAreComplete() async throws {
    let transport = RecordingTransport(json: #"{"id":"location"}"#)
    let client = ThreadsClient(accessToken: "token", transport: transport)

    _ = try await client.getLocation(id: "location")
    var request = try #require(await transport.lastRequest())
    #expect(request.query["fields"] == "id,name,address,city,country,latitude,longitude,postal_code")

    await transport.setResponse(json: #"{"data":[]}"#)
    _ = try await client.getPublishingLimit(userID: "me")
    request = try #require(await transport.lastRequest())
    #expect(request.query["fields"] == "quota_usage,config,reply_quota_usage,reply_config,delete_quota_usage,delete_config,location_search_quota_usage,location_search_config")

    await transport.setResponse(json: #"{"id":"container","status":"FINISHED"}"#)
    _ = try await client.getContainerStatus(id: "container")
    request = try #require(await transport.lastRequest())
    #expect(request.query["fields"] == "id,status,error_message")

    await transport.setResponse(json: #"{"data":[]}"#)
    _ = try await client.getMediaInsights(mediaID: "media", metrics: ["views", "likes"])
    request = try #require(await transport.lastRequest())
    #expect(request.path == "v1.0/media/insights")
    #expect(request.query["metric"] == "views,likes")

    _ = try await client.getUserInsights(userID: "me", metrics: ["views"], since: 1, until: 2)
    request = try #require(await transport.lastRequest())
    #expect(request.query["since"] == "1")
    #expect(request.query["until"] == "2")

    _ = try await client.getUserInsights(
      userID: "me", metrics: ["follower_demographics"], breakdown: .country
    )
    request = try #require(await transport.lastRequest())
    #expect(request.query["breakdown"] == "country")
  }

  @Test func replyEndpointsMapDocumentedFieldsSortingFiltersAndCursors() async throws {
    let transport = RecordingTransport(json: #"{"data":[]}"#)
    let client = ThreadsClient(accessToken: "token", transport: transport)

    _ = try await client.getReplies(
      mediaID: "media", fields: [.id, .isVerified], reverse: false, before: nil, after: "after"
    )
    var request = try #require(await transport.lastRequest())
    #expect(request.query["fields"] == "id,is_verified")
    #expect(request.query["reverse"] == "false")
    #expect(request.query["after"] == "after")

    _ = try await client.getPendingReplies(
      mediaID: "media", approvalStatus: .ignored, fields: [.id, .replyApprovalStatus],
      reverse: true, before: "before", after: nil
    )
    request = try #require(await transport.lastRequest())
    #expect(request.query["approval_status"] == "ignored")
    #expect(request.query["reverse"] == "true")
    #expect(request.query["before"] == "before")

    _ = try await client.getPendingReplies(mediaID: "media")
    request = try #require(await transport.lastRequest())
    #expect(request.query["fields"] == ThreadsMediaField.pendingReplyDefaultFields.threadsFieldList)
    #expect(request.query["fields"]?.contains("reply_approval_status") == true)
    #expect(!ThreadsMediaField.defaultFields.contains(.replyApprovalStatus))
  }

  @Test func replyManagementAndDeletionUseCorrectMethods() async throws {
    let transport = RecordingTransport(json: #"{"success":true}"#)
    let client = ThreadsClient(accessToken: "token", transport: transport)

    _ = try await client.setReplyHidden(replyID: "reply", hidden: true)
    var request = try #require(await transport.lastRequest())
    #expect(request.method == .post)
    #expect(request.path == "v1.0/reply/manage_reply")
    #expect(request.form == ["hide": "true"])

    _ = try await client.managePendingReply(replyID: "pending", approve: false)
    request = try #require(await transport.lastRequest())
    #expect(request.path == "v1.0/pending/manage_pending_reply")
    #expect(request.form == ["approve": "false"])

    _ = try await client.deletePost(mediaID: "media")
    request = try #require(await transport.lastRequest())
    #expect(request.method == .delete)
    #expect(request.path == "v1.0/media")
  }

  @Test func oEmbedUsesCurrentUnauthenticatedContract() async throws {
    let transport = RecordingTransport(json: #"{"html":"<blockquote></blockquote>"}"#)
    let client = ThreadsClient(accessToken: "must-not-leak", transport: transport)

    _ = try await client.getOEmbed(
      url: URL(string: "https://www.threads.com/t/example")!,
      maxWidth: 658
    )

    let request = try #require(await transport.lastRequest())
    #expect(request.path == "v1.0/oembed")
    #expect(request.query["url"] == "https://www.threads.com/t/example")
    #expect(request.query["maxwidth"] == "658")
    #expect(request.query["access_token"] == nil)
    #expect(request.query["omit_script"] == nil)

    _ = try await client.getOEmbed(
      url: URL(string: "https://www.threads.com/t/example")!,
      maxWidth: 320
    )
    let minimumRequest = try #require(await transport.lastRequest())
    #expect(minimumRequest.query["maxwidth"] == "320")

    for invalidWidth in [319, 659] {
      do {
        _ = try await client.getOEmbed(
          url: URL(string: "https://www.threads.com/t/example")!,
          maxWidth: invalidWidth
        )
        Issue.record("expected maxWidth validation for \(invalidWidth)")
      } catch let ThreadsAPIError.invalidInput(message) {
        #expect(message.contains("320") && message.contains("658"))
      }
    }
  }
}
