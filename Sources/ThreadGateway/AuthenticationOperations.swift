import Foundation

public extension ThreadsClient {
  func exchangeAuthorizationCode(
    clientID: String,
    clientSecret: String,
    redirectURI: URL,
    code: String
  ) async throws -> TokenResponse {
    try await execute(APIRequest(
      method: .post,
      path: "oauth/access_token",
      form: [
        "client_id": clientID,
        "client_secret": clientSecret,
        "grant_type": "authorization_code",
        "redirect_uri": redirectURI.absoluteString,
        "code": code
      ]
    ), authenticated: false)
  }

  func exchangeLongLivedToken(
    clientSecret: String,
    shortLivedToken: String
  ) async throws -> TokenResponse {
    try await execute(APIRequest(
      path: "access_token",
      query: [
        "grant_type": "th_exchange_token",
        "client_secret": clientSecret,
        "access_token": shortLivedToken
      ]
    ), authenticated: false)
  }

  func refreshLongLivedToken(_ token: String) async throws -> TokenResponse {
    try await execute(APIRequest(
      path: "refresh_access_token",
      query: ["grant_type": "th_refresh_token", "access_token": token]
    ), authenticated: false)
  }

  func getAppAccessToken(clientID: String, clientSecret: String) async throws -> TokenResponse {
    try await execute(APIRequest(
      path: "oauth/access_token",
      query: [
        "client_id": clientID,
        "client_secret": clientSecret,
        "grant_type": "client_credentials"
      ]
    ), authenticated: false)
  }

  func debugToken(inputToken: String, appAccessToken: String) async throws -> DebugTokenResponse {
    try await execute(APIRequest(
      path: versioned("debug_token"),
      query: ["input_token": inputToken, "access_token": appAccessToken]
    ), authenticated: false)
  }
}
