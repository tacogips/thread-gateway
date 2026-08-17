import Foundation
import Testing
@testable import ThreadGateway

@Suite("Capability separation and local helpers")
struct ScopeWebhookIntentTests {
  @Test func readerAndWriterScopesAreLeastPrivilegeAndDisjointExceptBasic() {
    let reader = Set(ThreadsCapabilitySet.reader.scopes)
    let writer = Set(ThreadsCapabilitySet.writer.scopes)
    #expect(reader.contains(.readReplies))
    #expect(!reader.contains(.contentPublish))
    #expect(writer.contains(.contentPublish))
    #expect(!writer.contains(.readReplies))
    #expect(reader.intersection(writer) == [.basic, .manageReplies, .locationTagging])
    #expect(!ThreadGatewayCLI.readerHelp.contains("delete"))
    #expect(!ThreadGatewayCLI.writerHelp.contains("keyword-search"))
  }

  @Test func helpSurfacesExposeDocumentedOperationalOptions() {
    let reader = ThreadGatewayCLI.readerHelp
    for option in [
      "--search-mode", "--media-type", "--author-username", "--fields", "--since", "--until",
      "--limit", "--before", "--after", "--latitude", "--longitude", "--reverse", "--breakdown",
      "--max-width"
    ] {
      #expect(reader.contains(option))
    }
    #expect(!reader.contains("--omit-script"))

    let writer = ThreadGatewayCLI.writerHelp
    for option in [
      "--poll-options", "--text-attachment-styles", "--gif-id", "--gif-provider",
      "--auto-publish-text", "--location-id", "--cross-share-to-instagram"
    ] {
      #expect(writer.contains(option))
    }
  }

  @Test func authorizationURLContainsOnlySelectedScopes() throws {
    let url = try OAuthAuthorizationRequest(
      clientID: "app",
      redirectURI: URL(string: "https://example.test/callback")!,
      scopes: ThreadsCapabilitySet.reader.scopes,
      state: "state"
    ).url()
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
    let scope = try #require(components.queryItems?.first { $0.name == "scope" }?.value)
    #expect(scope.contains("threads_read_replies"))
    #expect(!scope.contains("threads_content_publish"))
  }

  @Test func webhookVerificationAndTypedParsingWork() throws {
    let verification = WebhookVerificationRequest(mode: "subscribe", verifyToken: "known", challenge: "123")
    #expect(verification.verifiedChallenge(expectedToken: "known") == "123")
    #expect(verification.verifiedChallenge(expectedToken: "wrong") == nil)

    let data = Data(#"{"app_id":"app","topic":"moderate","target_id":"user","time":1,"subscription_id":"sub","values":{"value":{"id":"media","media_type":"TEXT_POST"},"field":"replies"}}"#.utf8)
    let payload = try ThreadsWebhookPayload.parse(data)
    #expect(payload.values.field == "replies")
    #expect(payload.values.value.id == "media")
  }

  @Test func webIntentURLsEncodeSupportedParameters() throws {
    let post = try PostIntent(
      text: "hello world",
      url: URL(string: "https://example.test/article"),
      tag: "Swift",
      replyControl: .followersOnly,
      quotePostShortcode: "quote"
    ).buildURL()
    let postComponents = try #require(URLComponents(url: post, resolvingAgainstBaseURL: false))
    #expect(postComponents.path == "/intent/post")
    #expect(postComponents.queryItems?.contains(URLQueryItem(name: "reply_control", value: "followers_only")) == true)

    let follow = try FollowIntent.buildURL(username: "threads")
    #expect(follow.absoluteString.contains("username=threads"))
  }
}
