import Foundation

public struct IDResponse: Codable, Equatable, Sendable {
  public let id: String
  public let crossReshareToInstagramStatus: String?

  enum CodingKeys: String, CodingKey {
    case id
    case crossReshareToInstagramStatus = "crossreshare_to_ig_status"
  }
}

public struct SuccessResponse: Codable, Equatable, Sendable {
  public let success: Bool
}

public struct TokenResponse: Codable, Equatable, Sendable {
  public let accessToken: String
  public let tokenType: String?
  public let expiresIn: Int?
  public let userID: String?

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case tokenType = "token_type"
    case expiresIn = "expires_in"
    case userID = "user_id"
  }
}

public struct DebugTokenData: Codable, Equatable, Sendable {
  public let appID: String?
  public let userID: String?
  public let isValid: Bool
  public let scopes: [String]?
  public let expiresAt: Int?
  public let tokenType: String?
  public let application: String?
  public let dataAccessExpiresAt: Int?
  public let issuedAt: Int?

  enum CodingKeys: String, CodingKey {
    case appID = "app_id"
    case userID = "user_id"
    case isValid = "is_valid"
    case scopes
    case expiresAt = "expires_at"
    case tokenType = "type"
    case application
    case dataAccessExpiresAt = "data_access_expires_at"
    case issuedAt = "issued_at"
  }
}

public struct DebugTokenResponse: Codable, Equatable, Sendable {
  public let data: DebugTokenData
}

public struct Paging: Codable, Equatable, Sendable {
  public struct Cursors: Codable, Equatable, Sendable {
    public let before: String?
    public let after: String?
  }
  public let cursors: Cursors?
  public let next: String?
  public let previous: String?
}

public struct ThreadsPage<Element: Codable & Equatable & Sendable>: Codable, Equatable, Sendable {
  public let data: [Element]
  public let paging: Paging?
}

public struct RecentlySearchedKeyword: Codable, Equatable, Sendable {
  public let query: String
  public let timestamp: Int64
}

public struct ThreadsUser: Codable, Equatable, Sendable {
  public let id: String
  public let username: String?
  public let name: String?
  public let biography: String?
  public let profilePictureURL: URL?
  public let isEligibleForGeoGating: Bool?
  public let isVerified: Bool?
  public let recentlySearchedKeywords: [RecentlySearchedKeyword]?
  public let followerCount: Int?
  public let likesCount: Int?
  public let quotesCount: Int?
  public let repliesCount: Int?
  public let repostsCount: Int?
  public let viewsCount: Int?

  enum CodingKeys: String, CodingKey {
    case id, username, name, biography
    case threadsBiography = "threads_biography"
    case profilePictureURL = "profile_picture_url"
    case threadsProfilePictureURL = "threads_profile_picture_url"
    case isEligibleForGeoGating = "is_eligible_for_geo_gating"
    case isVerified = "is_verified"
    case recentlySearchedKeywords = "recently_searched_keywords"
    case followerCount = "follower_count"
    case likesCount = "likes_count"
    case quotesCount = "quotes_count"
    case repliesCount = "replies_count"
    case repostsCount = "reposts_count"
    case viewsCount = "views_count"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
    username = try values.decodeIfPresent(String.self, forKey: .username)
    name = try values.decodeIfPresent(String.self, forKey: .name)
    biography = try values.decodeIfPresent(String.self, forKey: .biography)
      ?? values.decodeIfPresent(String.self, forKey: .threadsBiography)
    profilePictureURL = try values.decodeIfPresent(URL.self, forKey: .profilePictureURL)
      ?? values.decodeIfPresent(URL.self, forKey: .threadsProfilePictureURL)
    isEligibleForGeoGating = try values.decodeIfPresent(Bool.self, forKey: .isEligibleForGeoGating)
    isVerified = try values.decodeIfPresent(Bool.self, forKey: .isVerified)
    recentlySearchedKeywords = try values.decodeIfPresent([RecentlySearchedKeyword].self, forKey: .recentlySearchedKeywords)
    followerCount = try values.decodeIfPresent(Int.self, forKey: .followerCount)
    likesCount = try values.decodeIfPresent(Int.self, forKey: .likesCount)
    quotesCount = try values.decodeIfPresent(Int.self, forKey: .quotesCount)
    repliesCount = try values.decodeIfPresent(Int.self, forKey: .repliesCount)
    repostsCount = try values.decodeIfPresent(Int.self, forKey: .repostsCount)
    viewsCount = try values.decodeIfPresent(Int.self, forKey: .viewsCount)
  }

  public func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: CodingKeys.self)
    try values.encode(id, forKey: .id)
    try values.encodeIfPresent(username, forKey: .username)
    try values.encodeIfPresent(name, forKey: .name)
    try values.encodeIfPresent(biography, forKey: .biography)
    try values.encodeIfPresent(profilePictureURL, forKey: .profilePictureURL)
    try values.encodeIfPresent(isEligibleForGeoGating, forKey: .isEligibleForGeoGating)
    try values.encodeIfPresent(isVerified, forKey: .isVerified)
    try values.encodeIfPresent(recentlySearchedKeywords, forKey: .recentlySearchedKeywords)
    try values.encodeIfPresent(followerCount, forKey: .followerCount)
    try values.encodeIfPresent(likesCount, forKey: .likesCount)
    try values.encodeIfPresent(quotesCount, forKey: .quotesCount)
    try values.encodeIfPresent(repliesCount, forKey: .repliesCount)
    try values.encodeIfPresent(repostsCount, forKey: .repostsCount)
    try values.encodeIfPresent(viewsCount, forKey: .viewsCount)
  }
}

public struct ThreadsMediaReference: Codable, Equatable, Sendable {
  public let id: String

  enum CodingKeys: CodingKey { case id }

  public init(from decoder: Decoder) throws {
    if let value = try? decoder.singleValueContainer().decode(String.self) {
      id = value
    } else {
      id = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .id)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: CodingKeys.self)
    try values.encode(id, forKey: .id)
  }
}

public struct ThreadsMediaChildren: Codable, Equatable, Sendable {
  public let data: [ThreadsMedia]
}

public struct ThreadsMedia: Codable, Equatable, Sendable {
  public let id: String
  public let text: String?
  public let mediaProductType: String?
  public let mediaType: String?
  public let mediaURL: URL?
  public let permalink: URL?
  public let owner: ThreadsMediaReference?
  public let username: String?
  public let timestamp: String?
  public let shortcode: String?
  public let thumbnailURL: URL?
  public let children: ThreadsMediaChildren?
  public let isQuotePost: Bool?
  public let isReply: Bool?
  public let isReplyOwnedByMe: Bool?
  public let replyApprovalStatus: String?
  public let altText: String?
  public let linkAttachmentURL: URL?
  public let hasReplies: Bool?
  public let rootPost: ThreadsMediaReference?
  public let repliedTo: ThreadsMediaReference?
  public let hideStatus: String?
  public let replyAudience: String?
  public let quotedPost: ThreadsMediaReference?
  public let repostedPost: ThreadsMediaReference?
  public let gifURL: URL?
  public let pollAttachment: PollAttachment?
  public let topicTag: String?
  public let isSpoilerMedia: Bool?
  public let textEntities: [TextEntity]?
  public let textAttachment: TextAttachment?
  public let ghostPostStatus: String?
  public let ghostPostExpirationTimestamp: String?
  public let locationID: String?
  public let location: Location?
  public let isVerified: Bool?
  public let profilePictureURL: URL?

  enum CodingKeys: String, CodingKey {
    case id, text, permalink, username, timestamp, shortcode
    case mediaProductType = "media_product_type"
    case mediaType = "media_type"
    case mediaURL = "media_url"
    case owner, children
    case thumbnailURL = "thumbnail_url"
    case isQuotePost = "is_quote_post"
    case isReply = "is_reply"
    case isReplyOwnedByMe = "is_reply_owned_by_me"
    case replyApprovalStatus = "reply_approval_status"
    case altText = "alt_text"
    case linkAttachmentURL = "link_attachment_url"
    case hasReplies = "has_replies"
    case rootPost = "root_post"
    case repliedTo = "replied_to"
    case hideStatus = "hide_status"
    case replyAudience = "reply_audience"
    case quotedPost = "quoted_post"
    case repostedPost = "reposted_post"
    case gifURL = "gif_url"
    case pollAttachment = "poll_attachment"
    case topicTag = "topic_tag"
    case isSpoilerMedia = "is_spoiler_media"
    case textEntities = "text_entities"
    case textAttachment = "text_attachment"
    case ghostPostStatus = "ghost_post_status"
    case ghostPostExpirationTimestamp = "ghost_post_expiration_timestamp"
    case locationID = "location_id"
    case location
    case isVerified = "is_verified"
    case profilePictureURL = "profile_picture_url"
  }
}

public struct Location: Codable, Equatable, Sendable {
  public let id: String
  public let name: String?
  public let address: String?
  public let latitude: Double?
  public let longitude: Double?
  public let city: String?
  public let country: String?
  public let postalCode: String?

  enum CodingKeys: String, CodingKey {
    case id, name, address, latitude, longitude, city, country
    case postalCode = "postal_code"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if let stringID = try? values.decode(String.self, forKey: .id) {
      id = stringID
    } else {
      id = String(try values.decode(Int.self, forKey: .id))
    }
    name = try values.decodeIfPresent(String.self, forKey: .name)
    address = try values.decodeIfPresent(String.self, forKey: .address)
    latitude = try values.decodeIfPresent(Double.self, forKey: .latitude)
    longitude = try values.decodeIfPresent(Double.self, forKey: .longitude)
    city = try values.decodeIfPresent(String.self, forKey: .city)
    country = try values.decodeIfPresent(String.self, forKey: .country)
    postalCode = try values.decodeIfPresent(String.self, forKey: .postalCode)
  }

  public func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: CodingKeys.self)
    try values.encode(id, forKey: .id)
    try values.encodeIfPresent(name, forKey: .name)
    try values.encodeIfPresent(address, forKey: .address)
    try values.encodeIfPresent(latitude, forKey: .latitude)
    try values.encodeIfPresent(longitude, forKey: .longitude)
    try values.encodeIfPresent(city, forKey: .city)
    try values.encodeIfPresent(country, forKey: .country)
    try values.encodeIfPresent(postalCode, forKey: .postalCode)
  }
}

public struct InsightValue: Codable, Equatable, Sendable {
  public let value: Int?
  public let endTime: String?
  public let breakdowns: [InsightBreakdown]?

  enum CodingKeys: String, CodingKey {
    case value, breakdowns
    case endTime = "end_time"
  }
}

public struct InsightBreakdownResult: Codable, Equatable, Sendable {
  public let dimensionValues: [String]
  public let value: Int

  enum CodingKeys: String, CodingKey {
    case dimensionValues = "dimension_values"
    case value
  }
}

public struct InsightBreakdown: Codable, Equatable, Sendable {
  public let dimensionKeys: [String]
  public let results: [InsightBreakdownResult]

  enum CodingKeys: String, CodingKey {
    case dimensionKeys = "dimension_keys"
    case results
  }
}

public struct InsightLinkValue: Codable, Equatable, Sendable {
  public let value: Int
  public let linkURL: URL

  enum CodingKeys: String, CodingKey {
    case value
    case linkURL = "link_url"
  }
}

public struct Insight: Codable, Equatable, Sendable {
  public let id: String?
  public let name: String
  public let period: String?
  public let title: String?
  public let description: String?
  public let values: [InsightValue]?
  public let totalValue: InsightValue?
  public let linkTotalValues: [InsightLinkValue]?

  enum CodingKeys: String, CodingKey {
    case id, name, period, title, description, values
    case totalValue = "total_value"
    case linkTotalValues = "link_total_values"
  }
}

public struct PublishingQuotaUsage: Codable, Equatable, Sendable {
  public let quotaUsage: Int?
  public let config: [String: Int]?
  public let replyQuotaUsage: Int?
  public let replyConfig: [String: Int]?
  public let deleteQuotaUsage: Int?
  public let deleteConfig: [String: Int]?
  public let locationSearchQuotaUsage: Int?
  public let locationSearchConfig: [String: Int]?

  enum CodingKeys: String, CodingKey {
    case quotaUsage = "quota_usage"
    case config
    case replyQuotaUsage = "reply_quota_usage"
    case replyConfig = "reply_config"
    case deleteQuotaUsage = "delete_quota_usage"
    case deleteConfig = "delete_config"
    case locationSearchQuotaUsage = "location_search_quota_usage"
    case locationSearchConfig = "location_search_config"
  }
}

public struct PublishingLimit: Codable, Equatable, Sendable {
  public let data: [PublishingQuotaUsage]
}

public struct ContainerStatus: Codable, Equatable, Sendable {
  public let id: String?
  public let status: String
  public let errorMessage: String?

  enum CodingKeys: String, CodingKey {
    case id, status
    case errorMessage = "error_message"
  }
}

public struct OEmbed: Codable, Equatable, Sendable {
  public let version: String?
  public let type: String?
  public let title: String?
  public let html: String
  public let authorName: String?
  public let providerName: String?
  public let providerURL: URL?
  public let width: Int?

  enum CodingKeys: String, CodingKey {
    case version, type, title, html, width
    case authorName = "author_name"
    case providerName = "provider_name"
    case providerURL = "provider_url"
  }
}
