import Foundation

public struct PostIntent: Equatable, Sendable {
  public var text: String?
  public var url: URL?
  public var tag: String?
  public var replyControl: ReplyControl?
  public var replyPostShortcode: String?
  public var quotePostShortcode: String?

  public init(
    text: String? = nil,
    url: URL? = nil,
    tag: String? = nil,
    replyControl: ReplyControl? = nil,
    replyPostShortcode: String? = nil,
    quotePostShortcode: String? = nil
  ) {
    self.text = text
    self.url = url
    self.tag = tag
    self.replyControl = replyControl
    self.replyPostShortcode = replyPostShortcode
    self.quotePostShortcode = quotePostShortcode
  }

  public func buildURL() throws -> URL {
    guard var components = URLComponents(string: "https://www.threads.com/intent/post") else {
      throw ThreadsAPIError.invalidURL
    }
    var items: [URLQueryItem] = []
    if let text { items.append(URLQueryItem(name: "text", value: text)) }
    if let url { items.append(URLQueryItem(name: "url", value: url.absoluteString)) }
    if let tag { items.append(URLQueryItem(name: "tag", value: tag)) }
    if let replyControl { items.append(URLQueryItem(name: "reply_control", value: replyControl.rawValue)) }
    if let replyPostShortcode { items.append(URLQueryItem(name: "reply_post_shortcode", value: replyPostShortcode)) }
    if let quotePostShortcode { items.append(URLQueryItem(name: "quote_post_shortcode", value: quotePostShortcode)) }
    components.queryItems = items
    guard let url = components.url else { throw ThreadsAPIError.invalidURL }
    return url
  }
}

public enum FollowIntent {
  public static func buildURL(username: String) throws -> URL {
    guard var components = URLComponents(string: "https://www.threads.com/intent/follow") else {
      throw ThreadsAPIError.invalidURL
    }
    components.queryItems = [URLQueryItem(name: "username", value: username)]
    guard let url = components.url else { throw ThreadsAPIError.invalidURL }
    return url
  }
}
