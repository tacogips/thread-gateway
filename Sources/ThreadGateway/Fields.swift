public protocol ThreadsField: RawRepresentable, CaseIterable, Sendable where RawValue == String {}

public extension Collection where Element: ThreadsField {
  var threadsFieldList: String { map(\.rawValue).joined(separator: ",") }
}

public enum ThreadsUserField: String, CaseIterable, Codable, Sendable, ThreadsField {
  case id
  case username
  case name
  case profilePictureURL = "threads_profile_picture_url"
  case biography = "threads_biography"
  case isVerified = "is_verified"
  case recentlySearchedKeywords = "recently_searched_keywords"

  public static let defaultFields: [Self] = [
    .id, .username, .name, .profilePictureURL, .biography, .isVerified, .recentlySearchedKeywords
  ]
}

public enum ThreadsMediaField: String, CaseIterable, Codable, Sendable, ThreadsField {
  case id
  case mediaProductType = "media_product_type"
  case mediaType = "media_type"
  case mediaURL = "media_url"
  case permalink
  case owner
  case username
  case text
  case timestamp
  case shortcode
  case thumbnailURL = "thumbnail_url"
  case children
  case isQuotePost = "is_quote_post"
  case altText = "alt_text"
  case linkAttachmentURL = "link_attachment_url"
  case hasReplies = "has_replies"
  case isReply = "is_reply"
  case isReplyOwnedByMe = "is_reply_owned_by_me"
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
  case replyApprovalStatus = "reply_approval_status"

  public static let defaultFields: [Self] = [
    .id, .text, .mediaProductType, .mediaType, .mediaURL, .permalink, .username,
    .timestamp, .shortcode, .isQuotePost, .isReply
  ]

  public static let pendingReplyDefaultFields: [Self] = defaultFields + [.replyApprovalStatus]

  public static let allDocumentedFields: [Self] = Array(allCases)
}

public enum LocationField: String, CaseIterable, Codable, Sendable, ThreadsField {
  case id
  case name
  case address
  case city
  case country
  case latitude
  case longitude
  case postalCode = "postal_code"

  public static let defaultFields: [Self] = Array(allCases)
}

public enum PublishingLimitField: String, CaseIterable, Codable, Sendable, ThreadsField {
  case quotaUsage = "quota_usage"
  case config
  case replyQuotaUsage = "reply_quota_usage"
  case replyConfig = "reply_config"
  case deleteQuotaUsage = "delete_quota_usage"
  case deleteConfig = "delete_config"
  case locationSearchQuotaUsage = "location_search_quota_usage"
  case locationSearchConfig = "location_search_config"

  public static let defaultFields: [Self] = Array(allCases)
}

public enum ContainerStatusField: String, CaseIterable, Codable, Sendable, ThreadsField {
  case id
  case status
  case errorMessage = "error_message"

  public static let defaultFields: [Self] = Array(allCases)
}

public enum KeywordSearchType: String, CaseIterable, Codable, Sendable {
  case top = "TOP"
  case recent = "RECENT"
}

public enum KeywordSearchMode: String, CaseIterable, Codable, Sendable {
  case keyword = "KEYWORD"
  case tag = "TAG"
}

public enum KeywordSearchMediaType: String, CaseIterable, Codable, Sendable {
  case text = "TEXT"
  case image = "IMAGE"
  case video = "VIDEO"
}

public enum PendingReplyApprovalStatus: String, CaseIterable, Codable, Sendable {
  case pending
  case ignored
}

public enum UserInsightBreakdown: String, CaseIterable, Codable, Sendable {
  case country
  case city
  case age
  case gender
}
