import Foundation

public enum ThreadsAuthorizationScope: String, CaseIterable, Codable, Sendable {
  case basic = "threads_basic"
  case profileDiscovery = "threads_profile_discovery"
  case readReplies = "threads_read_replies"
  case manageInsights = "threads_manage_insights"
  case keywordSearch = "threads_keyword_search"
  case manageMentions = "threads_manage_mentions"
  case contentPublish = "threads_content_publish"
  case manageReplies = "threads_manage_replies"
  case delete = "threads_delete"
  case locationTagging = "threads_location_tagging"
  case shareToInstagram = "threads_share_to_instagram"
}

public enum ThreadsCapabilitySet: String, Codable, Sendable {
  case reader
  case writer

  public var scopes: [ThreadsAuthorizationScope] {
    switch self {
    case .reader:
      return [
        .basic, .profileDiscovery, .readReplies, .manageInsights, .keywordSearch,
        .manageMentions, .manageReplies, .locationTagging
      ]
    case .writer:
      return [.basic, .contentPublish, .manageReplies, .delete, .locationTagging, .shareToInstagram]
    }
  }
}

public struct OAuthAuthorizationRequest: Equatable, Sendable {
  public let clientID: String
  public let redirectURI: URL
  public let scopes: [ThreadsAuthorizationScope]
  public let state: String?

  public init(
    clientID: String,
    redirectURI: URL,
    scopes: [ThreadsAuthorizationScope],
    state: String? = nil
  ) {
    self.clientID = clientID
    self.redirectURI = redirectURI
    self.scopes = scopes
    self.state = state
  }

  public func url() throws -> URL {
    guard var components = URLComponents(string: "https://threads.com/oauth/authorize") else {
      throw ThreadsAPIError.invalidURL
    }
    var items = [
      URLQueryItem(name: "client_id", value: clientID),
      URLQueryItem(name: "redirect_uri", value: redirectURI.absoluteString),
      URLQueryItem(name: "scope", value: scopes.map(\.rawValue).joined(separator: ",")),
      URLQueryItem(name: "response_type", value: "code")
    ]
    if let state { items.append(URLQueryItem(name: "state", value: state)) }
    components.queryItems = items
    guard let url = components.url else { throw ThreadsAPIError.invalidURL }
    return url
  }
}
