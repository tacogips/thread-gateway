import Foundation

public struct WebhookVerificationRequest: Equatable, Sendable {
  public let mode: String
  public let verifyToken: String
  public let challenge: String

  public init(mode: String, verifyToken: String, challenge: String) {
    self.mode = mode
    self.verifyToken = verifyToken
    self.challenge = challenge
  }

  public func verifiedChallenge(expectedToken: String) -> String? {
    mode == "subscribe" && verifyToken == expectedToken ? challenge : nil
  }
}

public struct ThreadsWebhookReference: Codable, Equatable, Sendable {
  public let id: String?
  public let ownerID: String?
  public let username: String?

  enum CodingKeys: String, CodingKey {
    case id, username
    case ownerID = "owner_id"
  }
}

public struct ThreadsWebhookObject: Codable, Equatable, Sendable {
  public let id: String?
  public let username: String?
  public let text: String?
  public let mediaProductType: String?
  public let mediaType: String?
  public let mediaURL: URL?
  public let permalink: URL?
  public let timestamp: String?
  public let deletedAt: String?
  public let owner: ThreadsWebhookReference?
  public let shortcode: String?
  public let thumbnailURL: URL?
  public let altText: String?
  public let gifURL: URL?
  public let hasReplies: Bool?
  public let isQuotePost: Bool?
  public let isReply: Bool?
  public let pollAttachment: PollAttachment?
  public let repliedTo: ThreadsWebhookReference?
  public let rootPost: ThreadsWebhookReference?
  public let quotedPost: ThreadsWebhookReference?
  public let repostedPost: ThreadsWebhookReference?
  public let isVerified: Bool?
  public let profilePictureURL: URL?

  enum CodingKeys: String, CodingKey {
    case id, username, text, permalink, timestamp, owner, shortcode
    case mediaProductType = "media_product_type"
    case mediaType = "media_type"
    case mediaURL = "media_url"
    case deletedAt = "deleted_at"
    case thumbnailURL = "thumbnail_url"
    case altText = "alt_text"
    case gifURL = "gif_url"
    case hasReplies = "has_replies"
    case isQuotePost = "is_quote_post"
    case isReply = "is_reply"
    case pollAttachment = "poll_attachment"
    case repliedTo = "replied_to"
    case rootPost = "root_post"
    case quotedPost = "quoted_post"
    case repostedPost = "reposted_post"
    case isVerified = "is_verified"
    case profilePictureURL = "profile_picture_url"
  }
}

public struct ThreadsWebhookPayload: Codable, Equatable, Sendable {
  public struct Values: Codable, Equatable, Sendable {
    public let value: ThreadsWebhookObject
    public let field: String
  }

  public let appID: String
  public let topic: String
  public let targetID: String
  public let time: Int
  public let subscriptionID: String
  public let hasUIDField: Bool?
  public let values: Values

  enum CodingKeys: String, CodingKey {
    case topic, time, values
    case appID = "app_id"
    case targetID = "target_id"
    case subscriptionID = "subscription_id"
    case hasUIDField = "has_uid_field"
  }

  public static func parse(_ data: Data) throws -> ThreadsWebhookPayload {
    try JSONDecoder().decode(Self.self, from: data)
  }
}
