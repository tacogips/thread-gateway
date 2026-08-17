import Foundation

public protocol ThreadsWriterOperations: Sendable {
  func createPostContainer(userID: String, request: CreatePostRequest) async throws -> IDResponse
  func publishContainer(userID: String, creationID: String) async throws -> IDResponse
  func repost(mediaID: String) async throws -> IDResponse
  func deletePost(mediaID: String) async throws -> SuccessResponse
  func setReplyHidden(replyID: String, hidden: Bool) async throws -> SuccessResponse
  func managePendingReply(replyID: String, approve: Bool) async throws -> SuccessResponse
}

extension ThreadsClient: ThreadsWriterOperations {
  public func createPostContainer(userID: String, request: CreatePostRequest) async throws -> IDResponse {
    try await execute(APIRequest(
      method: .post,
      path: versioned("\(userID)/threads"),
      form: try request.form()
    ))
  }

  public func publishContainer(userID: String, creationID: String) async throws -> IDResponse {
    try await execute(APIRequest(
      method: .post,
      path: versioned("\(userID)/threads_publish"),
      form: ["creation_id": creationID]
    ))
  }

  public func repost(mediaID: String) async throws -> IDResponse {
    try await execute(APIRequest(method: .post, path: versioned("\(mediaID)/repost")))
  }

  public func deletePost(mediaID: String) async throws -> SuccessResponse {
    try await execute(APIRequest(method: .delete, path: versioned(mediaID)))
  }

  public func setReplyHidden(replyID: String, hidden: Bool) async throws -> SuccessResponse {
    try await execute(APIRequest(
      method: .post,
      path: versioned("\(replyID)/manage_reply"),
      form: ["hide": String(hidden)]
    ))
  }

  public func managePendingReply(replyID: String, approve: Bool) async throws -> SuccessResponse {
    try await execute(APIRequest(
      method: .post,
      path: versioned("\(replyID)/manage_pending_reply"),
      form: ["approve": String(approve)]
    ))
  }
}
