import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum HTTPMethod: String, Sendable {
  case get = "GET"
  case post = "POST"
  case delete = "DELETE"
}

public struct APIRequest: Sendable, Equatable {
  public let method: HTTPMethod
  public let path: String
  public let query: [String: String]
  public let form: [String: String]

  public init(
    method: HTTPMethod = .get,
    path: String,
    query: [String: String] = [:],
    form: [String: String] = [:]
  ) {
    self.method = method
    self.path = path
    self.query = query
    self.form = form
  }
}

public struct APIResponse: Sendable {
  public let statusCode: Int
  public let data: Data

  public init(statusCode: Int, data: Data) {
    self.statusCode = statusCode
    self.data = data
  }
}

public protocol ThreadsTransport: Sendable {
  func send(_ request: APIRequest, baseURL: URL) async throws -> APIResponse
}

public struct URLSessionThreadsTransport: ThreadsTransport {
  private let session: URLSession

  public init(session: URLSession = .shared) {
    self.session = session
  }

  public func send(_ request: APIRequest, baseURL: URL) async throws -> APIResponse {
    guard var components = URLComponents(
      url: baseURL.appendingPathComponent(request.path),
      resolvingAgainstBaseURL: false
    ) else {
      throw ThreadsAPIError.invalidURL
    }
    if !request.query.isEmpty {
      components.queryItems = request.query.sorted { $0.key < $1.key }.map(URLQueryItem.init)
    }
    guard let url = components.url else {
      throw ThreadsAPIError.invalidURL
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = request.method.rawValue
    if !request.form.isEmpty {
      urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
      var body = URLComponents()
      body.queryItems = request.form.sorted { $0.key < $1.key }.map(URLQueryItem.init)
      urlRequest.httpBody = body.percentEncodedQuery?.data(using: .utf8)
    }
    let (data, response) = try await session.data(for: urlRequest)
    guard let http = response as? HTTPURLResponse else {
      throw ThreadsAPIError.invalidResponse
    }
    return APIResponse(statusCode: http.statusCode, data: data)
  }
}

public struct ThreadsProviderError: Codable, Error, Equatable, Sendable {
  public let message: String
  public let type: String?
  public let code: Int?
  public let errorSubcode: Int?
  public let traceID: String?

  enum CodingKeys: String, CodingKey {
    case message, type, code
    case errorSubcode = "error_subcode"
    case traceID = "fbtrace_id"
  }
}

public enum ThreadsAPIError: Error, Equatable, Sendable {
  case invalidURL
  case invalidResponse
  case invalidInput(String)
  case provider(statusCode: Int, error: ThreadsProviderError)
  case http(statusCode: Int, body: String)
  case decoding(String)
}

struct ProviderErrorEnvelope: Decodable {
  let error: ThreadsProviderError
}
