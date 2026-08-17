import Foundation

public struct ThreadsClient: Sendable {
  public static let defaultFields = ThreadsMediaField.defaultFields.threadsFieldList

  public let accessToken: String?
  public let apiVersion: String
  public let baseURL: URL
  private let transport: any ThreadsTransport

  public init(
    accessToken: String? = nil,
    apiVersion: String = "v1.0",
    baseURL: URL = URL(string: "https://graph.threads.com")!,
    transport: any ThreadsTransport = URLSessionThreadsTransport()
  ) {
    self.accessToken = accessToken
    self.apiVersion = apiVersion
    self.baseURL = baseURL
    self.transport = transport
  }

  public func execute<Response: Decodable & Sendable>(
    _ request: APIRequest,
    authenticated: Bool = true,
    as type: Response.Type = Response.self
  ) async throws -> Response {
    var query = request.query
    if authenticated, let accessToken { query["access_token"] = accessToken }
    let response = try await transport.send(
      APIRequest(method: request.method, path: request.path, query: query, form: request.form),
      baseURL: baseURL
    )
    guard (200..<300).contains(response.statusCode) else {
      if let envelope = try? JSONDecoder().decode(ProviderErrorEnvelope.self, from: response.data) {
        throw ThreadsAPIError.provider(statusCode: response.statusCode, error: envelope.error)
      }
      throw ThreadsAPIError.http(
        statusCode: response.statusCode,
        body: String(data: response.data, encoding: .utf8) ?? ""
      )
    }
    do {
      return try JSONDecoder().decode(Response.self, from: response.data)
    } catch {
      throw ThreadsAPIError.decoding(String(describing: error))
    }
  }

  func versioned(_ path: String) -> String {
    "\(apiVersion)/\(path)"
  }

  func pageQuery(
    fields: String,
    since: String? = nil,
    until: String? = nil,
    limit: Int? = nil,
    before: String? = nil,
    after: String? = nil
  ) throws -> [String: String] {
    if before != nil, after != nil {
      throw ThreadsAPIError.invalidInput("before and after cannot be used together")
    }
    if let limit, !(0...100).contains(limit) {
      throw ThreadsAPIError.invalidInput("limit must be between 0 and 100")
    }
    var query = ["fields": fields]
    if let since { query["since"] = since }
    if let until { query["until"] = until }
    if let limit { query["limit"] = String(limit) }
    if let before { query["before"] = before }
    if let after { query["after"] = after }
    return query
  }
}
