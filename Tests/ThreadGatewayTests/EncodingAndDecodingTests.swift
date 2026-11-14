import Foundation
import Testing
@testable import ThreadGateway

@Suite("Encoding, decoding, and errors")
struct EncodingAndDecodingTests {
  @Test func createRequestEncodesAllMediaAndAttachmentVariants() throws {
    var request = CreatePostRequest(mediaType: .video, text: "hello")
    request.videoURL = URL(string: "https://example.test/video.mp4")
    request.children = ["one", "two"]
    request.replyToID = "reply"
    request.quotePostID = "quote"
    request.topicTag = "Swift"
    request.linkAttachment = URL(string: "https://example.test/article")
    request.altText = "accessible description"
    request.allowlistedCountryCodes = ["US", "JP"]
    request.isSpoilerMedia = true
    request.textEntities = [TextEntity(offset: 0, length: 2)]
    request.textAttachment = TextAttachment(
      plaintext: "attachment",
      textWithStylingInfo: [TextStylingRange(offset: 0, length: 3, stylingInfo: [.bold])]
    )
    request.gifAttachment = GIFAttachment(gifID: "gif", provider: "giphy")
    request.pollAttachment = PollAttachment(optionA: "A", optionB: "B")
    request.autoPublishText = true
    request.isGhostPost = true
    request.enableReplyApprovals = true
    request.locationID = "location"
    request.crossReshareToInstagram = true

    let form = try request.form()
    #expect(form["media_type"] == "VIDEO")
    #expect(form["video_url"] == "https://example.test/video.mp4")
    #expect(form["children"] == "one,two")
    #expect(form["reply_to_id"] == "reply")
    #expect(form["quote_post_id"] == "quote")
    #expect(form["allowlisted_country_codes"] == "US,JP")
    let poll = try #require(form["poll_attachment"]).data(using: .utf8).flatMap {
      try? JSONSerialization.jsonObject(with: $0) as? [String: String]
    }
    #expect(poll == ["option_a": "A", "option_b": "B"])
    let textAttachment = try #require(form["text_attachment"]).data(using: .utf8).flatMap {
      try? JSONSerialization.jsonObject(with: $0) as? [String: Any]
    }
    #expect(textAttachment?["plaintext"] as? String == "attachment")
    let styling = textAttachment?["text_with_styling_info"] as? [[String: Any]]
    #expect(styling?.first?["styling_info"] as? [String] == ["bold"])
    let gif = try #require(form["gif_attachment"]).data(using: .utf8).flatMap {
      try? JSONSerialization.jsonObject(with: $0) as? [String: String]
    }
    #expect(gif == ["gif_id": "gif", "provider": "giphy"])
    #expect(form["text_entities"]?.contains("SPOILER") == true)
    #expect(form["auto_publish_text"] == "true")
    #expect(form["crossreshare_to_ig"] == "true")
  }

  @Test func mediaVariantsAndPagingDecode() async throws {
    let json = #"{"data":[{"id":"1","media_type":"IMAGE"},{"id":"2","media_type":"VIDEO"},{"id":"3","media_type":"CAROUSEL_ALBUM"}],"paging":{"cursors":{"before":"b","after":"a"},"next":"https://next"}}"#
    let transport = RecordingTransport(json: json)
    let page: ThreadsPage<ThreadsMedia> = try await ThreadsClient(transport: transport).execute(
      APIRequest(path: "fixture"),
      authenticated: false
    )
    #expect(page.data.map(\.mediaType) == ["IMAGE", "VIDEO", "CAROUSEL_ALBUM"])
    #expect(page.paging?.cursors?.after == "a")
    #expect(page.paging?.next == "https://next")
  }

  @Test func providerErrorsAreTyped() async throws {
    let transport = RecordingTransport(
      json: #"{"error":{"message":"bad token","type":"OAuthException","code":190,"fbtrace_id":"trace"}}"#,
      statusCode: 400
    )
    do {
      let _: ThreadsMedia = try await ThreadsClient(transport: transport).execute(
        APIRequest(path: "fixture"),
        authenticated: false
      )
      Issue.record("expected provider error")
    } catch let ThreadsAPIError.provider(status, error) {
      #expect(status == 400)
      #expect(error.code == 190)
      #expect(error.traceID == "trace")
    }
  }

  @Test func malformedSuccessPayloadProducesDecodingError() async throws {
    let transport = RecordingTransport(json: #"{"unexpected":true}"#)
    do {
      let _: ThreadsMedia = try await ThreadsClient(transport: transport).execute(
        APIRequest(path: "fixture"),
        authenticated: false
      )
      Issue.record("expected decoding error")
    } catch let ThreadsAPIError.decoding(message) {
      #expect(!message.isEmpty)
    }
  }

  @Test func locationSearchDecodesNumericProviderIDs() async throws {
    let transport = RecordingTransport(json: #"{"data":[{"id":12345,"name":"Place","latitude":1.5,"longitude":2.5}]}"#)
    let page: ThreadsPage<Location> = try await ThreadsClient(transport: transport).execute(
      APIRequest(path: "fixture"),
      authenticated: false
    )
    #expect(page.data.first?.id == "12345")
  }

  @Test func documentedProfileMediaQuotaPollAndOEmbedFieldsDecode() async throws {
    let decoder = JSONDecoder()
    let user = try decoder.decode(ThreadsUser.self, from: Data(#"""
    {
      "id":"user","threads_biography":"bio","threads_profile_picture_url":"https://example.test/profile.jpg",
      "is_verified":true,"recently_searched_keywords":[{"query":"swift","timestamp":1735707600000}],
      "follower_count":10,"likes_count":11,"quotes_count":12,"replies_count":13,"reposts_count":14,"views_count":15
    }
    """#.utf8))
    #expect(user.biography == "bio")
    #expect(user.isVerified == true)
    #expect(user.recentlySearchedKeywords?.first?.query == "swift")
    #expect(user.viewsCount == 15)

    let media = try decoder.decode(ThreadsMedia.self, from: Data(#"""
    {
      "id":"media","media_product_type":"THREADS","thumbnail_url":"https://example.test/thumb.jpg",
      "owner":{"id":"owner"},"children":{"data":[{"id":"child"}]},"has_replies":true,
      "root_post":{"id":"root"},"replied_to":"parent","quoted_post":{"id":"quoted"},
      "ghost_post_status":"ARCHIVED","ghost_post_expiration_timestamp":"2026-01-02T00:00:00+0000",
      "location_id":"location","is_verified":true,"profile_picture_url":"https://example.test/profile.jpg",
      "poll_attachment":{"option_a":"A","option_b":"B","option_a_votes_percentage":0.25,"total_votes":4,"expiration_timestamp":"2026-01-01T00:00:00+0000"}
    }
    """#.utf8))
    #expect(media.owner?.id == "owner")
    #expect(media.children?.data.first?.id == "child")
    #expect(media.repliedTo?.id == "parent")
    #expect(media.pollAttachment?.totalVotes == 4)
    #expect(media.ghostPostStatus == "ARCHIVED")
    #expect(media.ghostPostExpirationTimestamp == "2026-01-02T00:00:00+0000")

    let quota = try decoder.decode(PublishingLimit.self, from: Data(#"""
    {
      "data":[{"quota_usage":1,"config":{"quota_total":250,"quota_duration":86400},
      "reply_quota_usage":2,"reply_config":{"quota_total":1000},"delete_quota_usage":3,
      "delete_config":{"quota_total":100},"location_search_quota_usage":4,
      "location_search_config":{"quota_total":500}}]
    }
    """#.utf8))
    #expect(quota.data.first?.replyQuotaUsage == 2)
    #expect(quota.data.first?.locationSearchConfig?["quota_total"] == 500)

    let embed = try decoder.decode(OEmbed.self, from: Data(#"""
    {
      "html":"<blockquote></blockquote>","provider_name":"Threads","provider_url":"https://www.threads.com/","width":658
    }
    """#.utf8))
    #expect(embed.providerURL?.host == "www.threads.com")
    #expect(embed.width == 658)
  }
}
