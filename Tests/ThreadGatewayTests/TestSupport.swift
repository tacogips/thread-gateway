import Foundation
@testable import ThreadGateway

actor RecordingTransport: ThreadsTransport {
  private(set) var requests: [APIRequest] = []
  var response: APIResponse

  init(json: String = #"{"id":"123"}"#, statusCode: Int = 200) {
    self.response = APIResponse(statusCode: statusCode, data: Data(json.utf8))
  }

  func send(_ request: APIRequest, baseURL: URL) async throws -> APIResponse {
    requests.append(request)
    return response
  }

  func setResponse(json: String, statusCode: Int = 200) {
    response = APIResponse(statusCode: statusCode, data: Data(json.utf8))
  }

  func lastRequest() -> APIRequest? { requests.last }
}
