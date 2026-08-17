import Foundation

public enum MediaType: String, Codable, Sendable {
  case text = "TEXT"
  case image = "IMAGE"
  case video = "VIDEO"
  case carousel = "CAROUSEL"
}

public enum ReplyControl: String, Codable, Sendable {
  case everyone
  case accountsYouFollow = "accounts_you_follow"
  case mentionedOnly = "mentioned_only"
  case parentPostAuthorOnly = "parent_post_author_only"
  case followersOnly = "followers_only"
}

public struct TextEntity: Codable, Equatable, Sendable {
  public let entityType: String
  public let offset: Int
  public let length: Int

  enum CodingKeys: String, CodingKey {
    case entityType = "entity_type"
    case offset, length
  }

  public init(offset: Int, length: Int) {
    self.entityType = "SPOILER"
    self.offset = offset
    self.length = length
  }
}

public struct PollAttachment: Codable, Equatable, Sendable {
  public let optionA: String
  public let optionB: String
  public let optionC: String?
  public let optionD: String?
  public let optionAVotesPercentage: Double?
  public let optionBVotesPercentage: Double?
  public let optionCVotesPercentage: Double?
  public let optionDVotesPercentage: Double?
  public let totalVotes: Int?
  public let expirationTimestamp: String?

  enum CodingKeys: String, CodingKey {
    case optionA = "option_a"
    case optionB = "option_b"
    case optionC = "option_c"
    case optionD = "option_d"
    case optionAVotesPercentage = "option_a_votes_percentage"
    case optionBVotesPercentage = "option_b_votes_percentage"
    case optionCVotesPercentage = "option_c_votes_percentage"
    case optionDVotesPercentage = "option_d_votes_percentage"
    case totalVotes = "total_votes"
    case expirationTimestamp = "expiration_timestamp"
  }

  public init(optionA: String, optionB: String, optionC: String? = nil, optionD: String? = nil) {
    self.optionA = optionA
    self.optionB = optionB
    self.optionC = optionC
    self.optionD = optionD
    self.optionAVotesPercentage = nil
    self.optionBVotesPercentage = nil
    self.optionCVotesPercentage = nil
    self.optionDVotesPercentage = nil
    self.totalVotes = nil
    self.expirationTimestamp = nil
  }
}

public enum TextStyle: String, Codable, Sendable {
  case bold, italic, highlight, underline, strikethrough
}

public struct TextStylingRange: Codable, Equatable, Sendable {
  public let offset: Int
  public let length: Int
  public let stylingInfo: [TextStyle]

  enum CodingKeys: String, CodingKey {
    case offset, length
    case stylingInfo = "styling_info"
  }

  public init(offset: Int, length: Int, stylingInfo: [TextStyle]) {
    self.offset = offset
    self.length = length
    self.stylingInfo = stylingInfo
  }
}

public struct TextAttachment: Codable, Equatable, Sendable {
  public let plaintext: String
  public let linkAttachmentURL: URL?
  public let textWithStylingInfo: [TextStylingRange]?

  enum CodingKeys: String, CodingKey {
    case plaintext
    case linkAttachmentURL = "link_attachment_url"
    case textWithStylingInfo = "text_with_styling_info"
  }

  public init(
    plaintext: String,
    linkAttachmentURL: URL? = nil,
    textWithStylingInfo: [TextStylingRange]? = nil
  ) {
    self.plaintext = plaintext
    self.linkAttachmentURL = linkAttachmentURL
    self.textWithStylingInfo = textWithStylingInfo
  }
}

public struct GIFAttachment: Codable, Equatable, Sendable {
  public let gifID: String
  public let provider: String

  enum CodingKeys: String, CodingKey {
    case gifID = "gif_id"
    case provider
  }

  public init(gifID: String, provider: String) {
    self.gifID = gifID
    self.provider = provider
  }
}

public struct CreatePostRequest: Equatable, Sendable {
  public var mediaType: MediaType
  public var text: String?
  public var imageURL: URL?
  public var videoURL: URL?
  public var children: [String]?
  public var isCarouselItem: Bool?
  public var replyToID: String?
  public var quotePostID: String?
  public var replyControl: ReplyControl?
  public var topicTag: String?
  public var linkAttachment: URL?
  public var altText: String?
  public var allowlistedCountryCodes: [String]?
  public var isSpoilerMedia: Bool?
  public var textEntities: [TextEntity]?
  public var textAttachment: TextAttachment?
  public var gifAttachment: GIFAttachment?
  public var pollAttachment: PollAttachment?
  public var autoPublishText: Bool?
  public var isGhostPost: Bool?
  public var enableReplyApprovals: Bool?
  public var locationID: String?
  public var crossReshareToInstagram: Bool?
  public var crossReshareToInstagramDarkMode: Bool?

  public init(mediaType: MediaType, text: String? = nil) {
    self.mediaType = mediaType
    self.text = text
  }

  func form() throws -> [String: String] {
    var values = ["media_type": mediaType.rawValue]
    func put(_ key: String, _ value: String?) { if let value { values[key] = value } }
    put("text", text)
    put("image_url", imageURL?.absoluteString)
    put("video_url", videoURL?.absoluteString)
    put("children", children?.joined(separator: ","))
    put("is_carousel_item", isCarouselItem.map(String.init))
    put("reply_to_id", replyToID)
    put("quote_post_id", quotePostID)
    put("reply_control", replyControl?.rawValue)
    put("topic_tag", topicTag)
    put("link_attachment", linkAttachment?.absoluteString)
    put("alt_text", altText)
    put("allowlisted_country_codes", allowlistedCountryCodes?.joined(separator: ","))
    put("is_spoiler_media", isSpoilerMedia.map(String.init))
    put("auto_publish_text", autoPublishText.map(String.init))
    put("is_ghost_post", isGhostPost.map(String.init))
    put("enable_reply_approvals", enableReplyApprovals.map(String.init))
    put("location_id", locationID)
    put("crossreshare_to_ig", crossReshareToInstagram.map(String.init))
    put("crossreshare_to_ig_dark_mode", crossReshareToInstagramDarkMode.map(String.init))
    let encoder = JSONEncoder()
    if let textEntities { put("text_entities", String(data: try encoder.encode(textEntities), encoding: .utf8)) }
    if let textAttachment { put("text_attachment", String(data: try encoder.encode(textAttachment), encoding: .utf8)) }
    if let gifAttachment { put("gif_attachment", String(data: try encoder.encode(gifAttachment), encoding: .utf8)) }
    if let pollAttachment { put("poll_attachment", String(data: try encoder.encode(pollAttachment), encoding: .utf8)) }
    return values
  }
}
