import Foundation

public protocol ThreadsReaderOperations: Sendable {
  func getUser(id: String, fields: [ThreadsUserField]) async throws -> ThreadsUser
  func lookupProfile(username: String) async throws -> ThreadsUser
  func getUserPosts(
    userID: String, fields: [ThreadsMediaField], since: String?, until: String?,
    limit: Int?, before: String?, after: String?
  ) async throws -> ThreadsPage<ThreadsMedia>
  func getProfilePosts(
    username: String, fields: [ThreadsMediaField], since: String?, until: String?,
    limit: Int?, before: String?, after: String?
  ) async throws -> ThreadsPage<ThreadsMedia>
  func getUserReplies(
    userID: String, fields: [ThreadsMediaField], since: String?, until: String?,
    limit: Int?, before: String?, after: String?
  ) async throws -> ThreadsPage<ThreadsMedia>
  func getMentions(
    userID: String, fields: [ThreadsMediaField], since: String?, until: String?,
    limit: Int?, before: String?, after: String?
  ) async throws -> ThreadsPage<ThreadsMedia>
  func getGhostPosts(
    userID: String, fields: [ThreadsMediaField], since: String?, until: String?,
    limit: Int?, before: String?, after: String?
  ) async throws -> ThreadsPage<ThreadsMedia>
  func getMedia(id: String, fields: [ThreadsMediaField]) async throws -> ThreadsMedia
  func searchKeyword(
    query: String, searchType: KeywordSearchType?, searchMode: KeywordSearchMode?,
    mediaType: KeywordSearchMediaType?, fields: [ThreadsMediaField], since: String?,
    until: String?, limit: Int?, authorUsername: String?
  ) async throws -> ThreadsPage<ThreadsMedia>
  func searchLocations(
    query: String?, latitude: Double?, longitude: Double?, fields: [LocationField]
  ) async throws -> ThreadsPage<Location>
  func getLocation(id: String, fields: [LocationField]) async throws -> Location
  func getPublishingLimit(userID: String, fields: [PublishingLimitField]) async throws -> PublishingLimit
  func getContainerStatus(id: String, fields: [ContainerStatusField]) async throws -> ContainerStatus
  func getMediaInsights(mediaID: String, metrics: [String]) async throws -> ThreadsPage<Insight>
  func getUserInsights(
    userID: String, metrics: [String], since: Int?, until: Int?, breakdown: UserInsightBreakdown?
  ) async throws -> ThreadsPage<Insight>
  func getReplies(
    mediaID: String, fields: [ThreadsMediaField], reverse: Bool?, before: String?, after: String?
  ) async throws -> ThreadsPage<ThreadsMedia>
  func getConversation(
    mediaID: String, fields: [ThreadsMediaField], reverse: Bool?, before: String?, after: String?
  ) async throws -> ThreadsPage<ThreadsMedia>
  func getPendingReplies(
    mediaID: String, approvalStatus: PendingReplyApprovalStatus?, fields: [ThreadsMediaField],
    reverse: Bool?, before: String?, after: String?
  ) async throws -> ThreadsPage<ThreadsMedia>
  func getOEmbed(url: URL, maxWidth: Int?) async throws -> OEmbed
}

extension ThreadsClient: ThreadsReaderOperations {
  public func getUser(
    id: String = "me",
    fields: [ThreadsUserField] = ThreadsUserField.defaultFields
  ) async throws -> ThreadsUser {
    try await getUser(id: id, fields: fields.threadsFieldList)
  }

  public func getUser(id: String = "me", fields: String) async throws -> ThreadsUser {
    try await execute(APIRequest(path: versioned(id), query: ["fields": fields]))
  }

  public func lookupProfile(username: String) async throws -> ThreadsUser {
    try await execute(APIRequest(path: versioned("profile_lookup"), query: ["username": username]))
  }

  public func getUserPosts(
    userID: String,
    fields: [ThreadsMediaField] = ThreadsMediaField.defaultFields,
    since: String? = nil,
    until: String? = nil,
    limit: Int? = nil,
    before: String? = nil,
    after: String? = nil
  ) async throws -> ThreadsPage<ThreadsMedia> {
    try await getMediaPage(
      path: "\(userID)/threads", fields: fields, since: since, until: until,
      limit: limit, before: before, after: after
    )
  }

  public func getProfilePosts(
    username: String,
    fields: [ThreadsMediaField] = ThreadsMediaField.defaultFields,
    since: String? = nil,
    until: String? = nil,
    limit: Int? = nil,
    before: String? = nil,
    after: String? = nil
  ) async throws -> ThreadsPage<ThreadsMedia> {
    var query = try pageQuery(
      fields: fields.threadsFieldList, since: since, until: until,
      limit: limit, before: before, after: after
    )
    query["username"] = username
    return try await execute(APIRequest(path: versioned("profile_posts"), query: query))
  }

  public func getUserReplies(
    userID: String,
    fields: [ThreadsMediaField] = ThreadsMediaField.defaultFields,
    since: String? = nil,
    until: String? = nil,
    limit: Int? = nil,
    before: String? = nil,
    after: String? = nil
  ) async throws -> ThreadsPage<ThreadsMedia> {
    try await getMediaPage(
      path: "\(userID)/replies", fields: fields, since: since, until: until,
      limit: limit, before: before, after: after
    )
  }

  public func getMentions(
    userID: String,
    fields: [ThreadsMediaField] = ThreadsMediaField.defaultFields,
    since: String? = nil,
    until: String? = nil,
    limit: Int? = nil,
    before: String? = nil,
    after: String? = nil
  ) async throws -> ThreadsPage<ThreadsMedia> {
    try await getMediaPage(
      path: "\(userID)/mentions", fields: fields, since: since, until: until,
      limit: limit, before: before, after: after
    )
  }

  public func getGhostPosts(
    userID: String,
    fields: [ThreadsMediaField] = ThreadsMediaField.defaultFields,
    since: String? = nil,
    until: String? = nil,
    limit: Int? = nil,
    before: String? = nil,
    after: String? = nil
  ) async throws -> ThreadsPage<ThreadsMedia> {
    try await getMediaPage(
      path: "\(userID)/ghost_posts", fields: fields, since: since, until: until,
      limit: limit, before: before, after: after
    )
  }

  public func getMedia(
    id: String,
    fields: [ThreadsMediaField] = ThreadsMediaField.defaultFields
  ) async throws -> ThreadsMedia {
    try await getMedia(id: id, fields: fields.threadsFieldList)
  }

  public func getMedia(id: String, fields: String) async throws -> ThreadsMedia {
    try await execute(APIRequest(path: versioned(id), query: ["fields": fields]))
  }

  public func searchKeyword(
    query searchQuery: String,
    searchType: KeywordSearchType? = nil,
    searchMode: KeywordSearchMode? = nil,
    mediaType: KeywordSearchMediaType? = nil,
    fields: [ThreadsMediaField] = ThreadsMediaField.defaultFields,
    since: String? = nil,
    until: String? = nil,
    limit: Int? = nil,
    authorUsername: String? = nil
  ) async throws -> ThreadsPage<ThreadsMedia> {
    if let limit, !(0...100).contains(limit) {
      throw ThreadsAPIError.invalidInput("limit must be between 0 and 100")
    }
    var query = ["q": searchQuery, "fields": fields.threadsFieldList]
    if let searchType { query["search_type"] = searchType.rawValue }
    if let searchMode { query["search_mode"] = searchMode.rawValue }
    if let mediaType { query["media_type"] = mediaType.rawValue }
    if let since { query["since"] = since }
    if let until { query["until"] = until }
    if let limit { query["limit"] = String(limit) }
    if let authorUsername { query["author_username"] = authorUsername }
    return try await execute(APIRequest(path: versioned("keyword_search"), query: query))
  }

  public func searchLocations(
    query searchQuery: String? = nil,
    latitude: Double? = nil,
    longitude: Double? = nil,
    fields: [LocationField] = LocationField.defaultFields
  ) async throws -> ThreadsPage<Location> {
    guard (latitude == nil) == (longitude == nil) else {
      throw ThreadsAPIError.invalidInput("latitude and longitude must be provided together")
    }
    guard searchQuery != nil || latitude != nil else {
      throw ThreadsAPIError.invalidInput("location search requires query or latitude/longitude")
    }
    var query = ["fields": fields.threadsFieldList]
    if let searchQuery { query["query"] = searchQuery }
    if let latitude { query["latitude"] = String(latitude) }
    if let longitude { query["longitude"] = String(longitude) }
    return try await execute(APIRequest(path: versioned("location_search"), query: query))
  }

  public func getLocation(
    id: String,
    fields: [LocationField] = LocationField.defaultFields
  ) async throws -> Location {
    try await execute(APIRequest(path: versioned(id), query: ["fields": fields.threadsFieldList]))
  }

  public func getPublishingLimit(
    userID: String,
    fields: [PublishingLimitField] = PublishingLimitField.defaultFields
  ) async throws -> PublishingLimit {
    try await execute(APIRequest(
      path: versioned("\(userID)/threads_publishing_limit"),
      query: ["fields": fields.threadsFieldList]
    ))
  }

  public func getContainerStatus(
    id: String,
    fields: [ContainerStatusField] = ContainerStatusField.defaultFields
  ) async throws -> ContainerStatus {
    try await execute(APIRequest(path: versioned(id), query: ["fields": fields.threadsFieldList]))
  }

  public func getMediaInsights(mediaID: String, metrics: [String]) async throws -> ThreadsPage<Insight> {
    try await execute(APIRequest(path: versioned("\(mediaID)/insights"), query: ["metric": metrics.joined(separator: ",")]))
  }

  public func getUserInsights(
    userID: String,
    metrics: [String],
    since: Int? = nil,
    until: Int? = nil,
    breakdown: UserInsightBreakdown? = nil
  ) async throws -> ThreadsPage<Insight> {
    var query = ["metric": metrics.joined(separator: ",")]
    if let since { query["since"] = String(since) }
    if let until { query["until"] = String(until) }
    if let breakdown { query["breakdown"] = breakdown.rawValue }
    return try await execute(APIRequest(path: versioned("\(userID)/threads_insights"), query: query))
  }

  public func getReplies(
    mediaID: String,
    fields: [ThreadsMediaField] = ThreadsMediaField.defaultFields,
    reverse: Bool? = nil,
    before: String? = nil,
    after: String? = nil
  ) async throws -> ThreadsPage<ThreadsMedia> {
    try await getReplyPage(
      path: "\(mediaID)/replies", fields: fields, reverse: reverse,
      approvalStatus: nil, before: before, after: after
    )
  }

  public func getConversation(
    mediaID: String,
    fields: [ThreadsMediaField] = ThreadsMediaField.defaultFields,
    reverse: Bool? = nil,
    before: String? = nil,
    after: String? = nil
  ) async throws -> ThreadsPage<ThreadsMedia> {
    try await getReplyPage(
      path: "\(mediaID)/conversation", fields: fields, reverse: reverse,
      approvalStatus: nil, before: before, after: after
    )
  }

  public func getPendingReplies(
    mediaID: String,
    approvalStatus: PendingReplyApprovalStatus? = nil,
    fields: [ThreadsMediaField] = ThreadsMediaField.pendingReplyDefaultFields,
    reverse: Bool? = nil,
    before: String? = nil,
    after: String? = nil
  ) async throws -> ThreadsPage<ThreadsMedia> {
    try await getReplyPage(
      path: "\(mediaID)/pending_replies", fields: fields, reverse: reverse,
      approvalStatus: approvalStatus, before: before, after: after
    )
  }

  public func getOEmbed(url: URL, maxWidth: Int? = nil) async throws -> OEmbed {
    if let maxWidth, !(320...658).contains(maxWidth) {
      throw ThreadsAPIError.invalidInput("maxWidth must be between 320 and 658")
    }
    var query = ["url": url.absoluteString]
    if let maxWidth { query["maxwidth"] = String(maxWidth) }
    return try await execute(APIRequest(path: versioned("oembed"), query: query), authenticated: false)
  }

  private func getMediaPage(
    path: String,
    fields: [ThreadsMediaField],
    since: String?,
    until: String?,
    limit: Int?,
    before: String?,
    after: String?
  ) async throws -> ThreadsPage<ThreadsMedia> {
    let query = try pageQuery(
      fields: fields.threadsFieldList, since: since, until: until,
      limit: limit, before: before, after: after
    )
    return try await execute(APIRequest(path: versioned(path), query: query))
  }

  private func getReplyPage(
    path: String,
    fields: [ThreadsMediaField],
    reverse: Bool?,
    approvalStatus: PendingReplyApprovalStatus?,
    before: String?,
    after: String?
  ) async throws -> ThreadsPage<ThreadsMedia> {
    var query = try pageQuery(
      fields: fields.threadsFieldList, before: before, after: after
    )
    if let reverse { query["reverse"] = String(reverse) }
    if let approvalStatus { query["approval_status"] = approvalStatus.rawValue }
    return try await execute(APIRequest(path: versioned(path), query: query))
  }
}
