import Foundation

public enum ThreadGatewayVersion {
  public static let current = "0.1.0"
}

public enum ThreadGatewayCLI {
  public static func runReader(
    arguments: [String],
    environment: [String: String] = ProcessInfo.processInfo.environment
  ) async -> Int32 {
    if arguments.isEmpty || arguments.contains("--help") || arguments.first == "help" {
      print(readerHelp)
      return 0
    }
    if arguments.first == "--version" { print(ThreadGatewayVersion.current); return 0 }
    do {
      return try await executeReader(arguments: arguments, environment: environment)
    } catch {
      writeError(error)
      return 1
    }
  }

  public static func runWriter(
    arguments: [String],
    environment: [String: String] = ProcessInfo.processInfo.environment
  ) async -> Int32 {
    if arguments.isEmpty || arguments.contains("--help") || arguments.first == "help" {
      print(writerHelp)
      return 0
    }
    if arguments.first == "--version" { print(ThreadGatewayVersion.current); return 0 }
    do {
      return try await executeWriter(arguments: arguments, environment: environment)
    } catch {
      writeError(error)
      return 1
    }
  }

  private static func executeReader(arguments: [String], environment: [String: String]) async throws -> Int32 {
    let command = arguments[0]
    let options = parseOptions(Array(arguments.dropFirst()))
    if command == "scopes" {
      try printJSON(ThreadsCapabilitySet.reader.scopes.map(\.rawValue))
      return 0
    }
    if command == "auth-url" {
      let clientID = try required("client-id", options: options, environment: environment, env: "THREADS_APP_ID")
      let redirect = try requiredURL("redirect-uri", options: options, environment: environment, env: "THREADS_REDIRECT_URI")
      let request = OAuthAuthorizationRequest(
        clientID: clientID,
        redirectURI: redirect,
        scopes: ThreadsCapabilitySet.reader.scopes,
        state: options["state"]
      )
      print(try request.url().absoluteString)
      return 0
    }
    if command == "intent-post" {
      let replyControl = try optionEnum("reply-control", options: options, as: ReplyControl.self)
      let intent = PostIntent(
        text: options["text"],
        url: try optionalURL(options["url"]),
        tag: options["tag"],
        replyControl: replyControl,
        replyPostShortcode: options["reply-post-shortcode"],
        quotePostShortcode: options["quote-post-shortcode"]
      )
      print(try intent.buildURL().absoluteString)
      return 0
    }
    if command == "intent-follow" {
      print(try FollowIntent.buildURL(username: try requiredOption("username", options)).absoluteString)
      return 0
    }
    if command == "webhook-verify" {
      let request = WebhookVerificationRequest(
        mode: try requiredOption("mode", options),
        verifyToken: try requiredOption("verify-token", options),
        challenge: try requiredOption("challenge", options)
      )
      guard let challenge = request.verifiedChallenge(expectedToken: try required("expected-token", options: options, environment: environment, env: "THREADS_WEBHOOK_VERIFY_TOKEN")) else {
        throw ThreadsAPIError.invalidInput("webhook verification failed")
      }
      print(challenge)
      return 0
    }
    if command == "webhook-parse" {
      let data = try Data(contentsOf: URL(fileURLWithPath: try requiredOption("file", options)))
      try printJSON(ThreadsWebhookPayload.parse(data))
      return 0
    }
    if command == "token-debug" {
      let client = ThreadsClient()
      try printJSON(await client.debugToken(
        inputToken: try required("input-token", options: options, environment: environment, env: "THREADS_INPUT_TOKEN"),
        appAccessToken: try required("app-access-token", options: options, environment: environment, env: "THREADS_APP_ACCESS_TOKEN")
      ))
      return 0
    }
    if command == "oembed" {
      let client = ThreadsClient()
      try printJSON(await client.getOEmbed(
        url: try requiredURL("url", options: options),
        maxWidth: try optionInt("max-width", options)
      ))
      return 0
    }

    let client = ThreadsClient(accessToken: try required("access-token", options: options, environment: environment, env: "THREADS_ACCESS_TOKEN"))
    switch command {
    case "me": try printJSON(await client.getUser(
      id: options["user-id"] ?? "me",
      fields: try fieldList("fields", options: options, default: ThreadsUserField.defaultFields)
    ))
    case "profile": try printJSON(await client.lookupProfile(username: try requiredOption("username", options)))
    case "posts": try printJSON(await client.getUserPosts(
      userID: try requiredOption("user-id", options), fields: try mediaFields(options),
      since: options["since"], until: options["until"], limit: try optionInt("limit", options),
      before: options["before"], after: options["after"]
    ))
    case "profile-posts": try printJSON(await client.getProfilePosts(
      username: try requiredOption("username", options), fields: try mediaFields(options),
      since: options["since"], until: options["until"], limit: try optionInt("limit", options),
      before: options["before"], after: options["after"]
    ))
    case "user-replies": try printJSON(await client.getUserReplies(
      userID: try requiredOption("user-id", options), fields: try mediaFields(options),
      since: options["since"], until: options["until"], limit: try optionInt("limit", options),
      before: options["before"], after: options["after"]
    ))
    case "mentions": try printJSON(await client.getMentions(
      userID: try requiredOption("user-id", options), fields: try mediaFields(options),
      since: options["since"], until: options["until"], limit: try optionInt("limit", options),
      before: options["before"], after: options["after"]
    ))
    case "ghost-posts": try printJSON(await client.getGhostPosts(
      userID: try requiredOption("user-id", options), fields: try mediaFields(options),
      since: options["since"], until: options["until"], limit: try optionInt("limit", options),
      before: options["before"], after: options["after"]
    ))
    case "media": try printJSON(await client.getMedia(
      id: try requiredOption("media-id", options),
      fields: try mediaFields(options)
    ))
    case "keyword-search": try printJSON(await client.searchKeyword(
      query: try requiredOption("query", options),
      searchType: try optionEnum("search-type", options: options, as: KeywordSearchType.self, uppercase: true),
      searchMode: try optionEnum("search-mode", options: options, as: KeywordSearchMode.self, uppercase: true),
      mediaType: try optionEnum("media-type", options: options, as: KeywordSearchMediaType.self, uppercase: true),
      fields: try mediaFields(options), since: options["since"], until: options["until"],
      limit: try optionInt("limit", options), authorUsername: options["author-username"]
    ))
    case "location-search": try printJSON(await client.searchLocations(
      query: options["query"],
      latitude: try optionDouble("latitude", options),
      longitude: try optionDouble("longitude", options),
      fields: try fieldList("fields", options: options, default: LocationField.defaultFields)
    ))
    case "location": try printJSON(await client.getLocation(
      id: try requiredOption("location-id", options),
      fields: try fieldList("fields", options: options, default: LocationField.defaultFields)
    ))
    case "publishing-limit": try printJSON(await client.getPublishingLimit(
      userID: try requiredOption("user-id", options),
      fields: try fieldList("fields", options: options, default: PublishingLimitField.defaultFields)
    ))
    case "container-status": try printJSON(await client.getContainerStatus(
      id: try requiredOption("container-id", options),
      fields: try fieldList("fields", options: options, default: ContainerStatusField.defaultFields)
    ))
    case "media-insights": try printJSON(await client.getMediaInsights(
      mediaID: try requiredOption("media-id", options),
      metrics: csv(try requiredOption("metrics", options))
    ))
    case "user-insights": try printJSON(await client.getUserInsights(
      userID: try requiredOption("user-id", options), metrics: csv(try requiredOption("metrics", options)),
      since: try optionInt("since", options), until: try optionInt("until", options),
      breakdown: try optionEnum("breakdown", options: options, as: UserInsightBreakdown.self)
    ))
    case "replies": try printJSON(await client.getReplies(
      mediaID: try requiredOption("media-id", options), fields: try mediaFields(options),
      reverse: try optionBool("reverse", options), before: options["before"], after: options["after"]
    ))
    case "conversation": try printJSON(await client.getConversation(
      mediaID: try requiredOption("media-id", options), fields: try mediaFields(options),
      reverse: try optionBool("reverse", options), before: options["before"], after: options["after"]
    ))
    case "pending-replies": try printJSON(await client.getPendingReplies(
      mediaID: try requiredOption("media-id", options),
      approvalStatus: try optionEnum("approval-status", options: options, as: PendingReplyApprovalStatus.self),
      fields: try mediaFields(options), reverse: try optionBool("reverse", options),
      before: options["before"], after: options["after"]
    ))
    default: throw ThreadsAPIError.invalidInput("unknown reader command: \(command)")
    }
    return 0
  }

  private static func executeWriter(arguments: [String], environment: [String: String]) async throws -> Int32 {
    let command = arguments[0]
    let options = parseOptions(Array(arguments.dropFirst()))
    if command == "scopes" {
      try printJSON(ThreadsCapabilitySet.writer.scopes.map(\.rawValue))
      return 0
    }
    let unauthenticatedClient = ThreadsClient()
    switch command {
    case "oauth-exchange":
      try printJSON(await unauthenticatedClient.exchangeAuthorizationCode(
        clientID: try required("client-id", options: options, environment: environment, env: "THREADS_APP_ID"),
        clientSecret: try required("client-secret", options: options, environment: environment, env: "THREADS_APP_SECRET"),
        redirectURI: try requiredURL("redirect-uri", options: options, environment: environment, env: "THREADS_REDIRECT_URI"),
        code: try required("code", options: options, environment: environment, env: "THREADS_AUTH_CODE")
      ))
      return 0
    case "token-long-lived":
      try printJSON(await unauthenticatedClient.exchangeLongLivedToken(
        clientSecret: try required("client-secret", options: options, environment: environment, env: "THREADS_APP_SECRET"),
        shortLivedToken: try required("short-lived-token", options: options, environment: environment, env: "THREADS_ACCESS_TOKEN")
      ))
      return 0
    case "token-refresh":
      try printJSON(await unauthenticatedClient.refreshLongLivedToken(
        try required("access-token", options: options, environment: environment, env: "THREADS_ACCESS_TOKEN")
      ))
      return 0
    case "app-token":
      try printJSON(await unauthenticatedClient.getAppAccessToken(
        clientID: try required("client-id", options: options, environment: environment, env: "THREADS_APP_ID"),
        clientSecret: try required("client-secret", options: options, environment: environment, env: "THREADS_APP_SECRET")
      ))
      return 0
    default: break
    }

    let client = ThreadsClient(accessToken: try required("access-token", options: options, environment: environment, env: "THREADS_ACCESS_TOKEN"))
    switch command {
    case "create":
      guard let mediaType = MediaType(rawValue: try requiredOption("media-type", options).uppercased()) else {
        throw ThreadsAPIError.invalidInput("media-type must be TEXT, IMAGE, VIDEO, or CAROUSEL")
      }
      var request = CreatePostRequest(mediaType: mediaType, text: options["text"])
      request.imageURL = try optionalURL(options["image-url"])
      request.videoURL = try optionalURL(options["video-url"])
      request.children = optionalCSV(options["children"])
      request.isCarouselItem = bool(options["carousel-item"])
      request.replyToID = options["reply-to-id"]
      request.quotePostID = options["quote-post-id"]
      if let value = options["reply-control"] {
        guard let replyControl = ReplyControl(rawValue: value) else {
          throw ThreadsAPIError.invalidInput("invalid --reply-control")
        }
        request.replyControl = replyControl
      }
      request.topicTag = options["topic-tag"]
      request.linkAttachment = try optionalURL(options["link-attachment"])
      request.altText = options["alt-text"]
      request.allowlistedCountryCodes = optionalCSV(options["allowlisted-country-codes"])
      if let gifID = options["gif-id"] {
        request.gifAttachment = GIFAttachment(gifID: gifID, provider: try requiredOption("gif-provider", options))
      }
      request.locationID = options["location-id"]
      request.isSpoilerMedia = bool(options["spoiler-media"])
      request.textEntities = try spoilerEntities(options["spoiler-ranges"])
      if options["text-attachment-text"] != nil || options["text-attachment-url"] != nil || options["text-attachment-styles"] != nil {
        request.textAttachment = TextAttachment(
          plaintext: try requiredOption("text-attachment-text", options),
          linkAttachmentURL: try optionalURL(options["text-attachment-url"]),
          textWithStylingInfo: try textStylingRanges(options["text-attachment-styles"])
        )
      }
      if let pollOptions = optionalCSV(options["poll-options"]) {
        guard (2...4).contains(pollOptions.count) else {
          throw ThreadsAPIError.invalidInput("--poll-options requires two to four values")
        }
        request.pollAttachment = PollAttachment(
          optionA: pollOptions[0],
          optionB: pollOptions[1],
          optionC: pollOptions.count > 2 ? pollOptions[2] : nil,
          optionD: pollOptions.count > 3 ? pollOptions[3] : nil
        )
      }
      request.autoPublishText = bool(options["auto-publish-text"])
      request.isGhostPost = bool(options["ghost-post"])
      request.enableReplyApprovals = bool(options["enable-reply-approvals"])
      request.crossReshareToInstagram = bool(options["cross-share-to-instagram"])
      request.crossReshareToInstagramDarkMode = bool(options["cross-share-dark-mode"])
      try printJSON(await client.createPostContainer(userID: try requiredOption("user-id", options), request: request))
    case "publish": try printJSON(await client.publishContainer(userID: try requiredOption("user-id", options), creationID: try requiredOption("creation-id", options)))
    case "repost": try printJSON(await client.repost(mediaID: try requiredOption("media-id", options)))
    case "delete": try printJSON(await client.deletePost(mediaID: try requiredOption("media-id", options)))
    case "hide-reply": try printJSON(await client.setReplyHidden(replyID: try requiredOption("reply-id", options), hidden: true))
    case "unhide-reply": try printJSON(await client.setReplyHidden(replyID: try requiredOption("reply-id", options), hidden: false))
    case "approve-reply": try printJSON(await client.managePendingReply(replyID: try requiredOption("reply-id", options), approve: true))
    case "ignore-reply": try printJSON(await client.managePendingReply(replyID: try requiredOption("reply-id", options), approve: false))
    default: throw ThreadsAPIError.invalidInput("unknown writer command: \(command)")
    }
    return 0
  }

  static func parseOptions(_ arguments: [String]) -> [String: String] {
    var result: [String: String] = [:]
    var index = 0
    while index < arguments.count {
      let argument = arguments[index]
      guard argument.hasPrefix("--") else { index += 1; continue }
      let key = String(argument.dropFirst(2))
      if index + 1 < arguments.count, !arguments[index + 1].hasPrefix("--") {
        result[key] = arguments[index + 1]; index += 2
      } else {
        result[key] = "true"; index += 1
      }
    }
    return result
  }

  private static func requiredOption(_ key: String, _ options: [String: String]) throws -> String {
    guard let value = options[key], !value.isEmpty else { throw ThreadsAPIError.invalidInput("missing --\(key)") }
    return value
  }

  private static func required(
    _ key: String,
    options: [String: String],
    environment: [String: String],
    env: String
  ) throws -> String {
    if let value = options[key], !value.isEmpty { return value }
    if let value = environment[env], !value.isEmpty { return value }
    throw ThreadsAPIError.invalidInput("missing --\(key) or \(env)")
  }

  private static func requiredURL(_ key: String, options: [String: String]) throws -> URL {
    guard let url = URL(string: try requiredOption(key, options)) else { throw ThreadsAPIError.invalidInput("invalid --\(key)") }
    return url
  }

  private static func requiredURL(
    _ key: String,
    options: [String: String],
    environment: [String: String],
    env: String
  ) throws -> URL {
    guard let url = URL(string: try required(key, options: options, environment: environment, env: env)) else {
      throw ThreadsAPIError.invalidInput("invalid --\(key)")
    }
    return url
  }

  private static func optionalURL(_ value: String?) throws -> URL? {
    guard let value else { return nil }
    guard let url = URL(string: value) else { throw ThreadsAPIError.invalidInput("invalid URL") }
    return url
  }

  private static func csv(_ value: String?) -> [String] { optionalCSV(value) ?? [] }
  private static func optionalCSV(_ value: String?) -> [String]? {
    value?.split(separator: ",").map(String.init).filter { !$0.isEmpty }
  }
  private static func bool(_ value: String?) -> Bool? { value.map { $0 == "true" || $0 == "1" } }

  private static func optionInt(_ key: String, _ options: [String: String]) throws -> Int? {
    guard let value = options[key] else { return nil }
    guard let result = Int(value) else { throw ThreadsAPIError.invalidInput("--\(key) must be an integer") }
    return result
  }

  private static func optionDouble(_ key: String, _ options: [String: String]) throws -> Double? {
    guard let value = options[key] else { return nil }
    guard let result = Double(value) else { throw ThreadsAPIError.invalidInput("--\(key) must be a number") }
    return result
  }

  private static func optionBool(_ key: String, _ options: [String: String]) throws -> Bool? {
    guard let value = options[key] else { return nil }
    switch value.lowercased() {
    case "true", "1": return true
    case "false", "0": return false
    default: throw ThreadsAPIError.invalidInput("--\(key) must be true or false")
    }
  }

  private static func optionEnum<Value: RawRepresentable>(
    _ key: String,
    options: [String: String],
    as type: Value.Type,
    uppercase: Bool = false
  ) throws -> Value? where Value.RawValue == String {
    guard let input = options[key] else { return nil }
    let value = uppercase ? input.uppercased() : input
    guard let result = Value(rawValue: value) else {
      throw ThreadsAPIError.invalidInput("invalid --\(key)")
    }
    return result
  }

  private static func fieldList<Value: ThreadsField>(
    _ key: String,
    options: [String: String],
    default defaultFields: [Value]
  ) throws -> [Value] {
    guard let values = optionalCSV(options[key]) else { return defaultFields }
    return try values.map { value in
      guard let field = Value(rawValue: value) else {
        throw ThreadsAPIError.invalidInput("unsupported --\(key) field: \(value)")
      }
      return field
    }
  }

  private static func mediaFields(_ options: [String: String]) throws -> [ThreadsMediaField] {
    try fieldList("fields", options: options, default: ThreadsMediaField.defaultFields)
  }

  private static func spoilerEntities(_ value: String?) throws -> [TextEntity]? {
    guard let value else { return nil }
    return try value.split(separator: ",").map { item in
      let pair = item.split(separator: ":")
      guard pair.count == 2, let offset = Int(pair[0]), let length = Int(pair[1]) else {
        throw ThreadsAPIError.invalidInput("--spoiler-ranges must use offset:length pairs")
      }
      return TextEntity(offset: offset, length: length)
    }
  }

  private static func textStylingRanges(_ value: String?) throws -> [TextStylingRange]? {
    guard let value else { return nil }
    return try value.split(separator: ",").map { item in
      let parts = item.split(separator: ":", maxSplits: 2)
      guard parts.count == 3, let offset = Int(parts[0]), let length = Int(parts[1]) else {
        throw ThreadsAPIError.invalidInput("--text-attachment-styles must use offset:length:style+style")
      }
      let styles = try parts[2].split(separator: "+").map { rawStyle in
        guard let style = TextStyle(rawValue: String(rawStyle)) else {
          throw ThreadsAPIError.invalidInput("invalid text attachment style: \(rawStyle)")
        }
        return style
      }
      return TextStylingRange(offset: offset, length: length, stylingInfo: styles)
    }
  }

  private static func printJSON<Value: Encodable>(_ value: Value) throws {
    let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(value)
    guard let output = String(bytes: data, encoding: .utf8) else {
      throw ThreadsAPIError.decoding("failed to encode UTF-8 JSON output")
    }
    print(output)
  }

  private static func writeError(_ error: Error) {
    let message = "error: \(String(describing: error))\n"
    FileHandle.standardError.write(Data(message.utf8))
  }

  public static let readerHelp = """
  thread-gateway-reader — read-only Threads API client

  Commands:
    scopes, auth-url, token-debug
    me, profile, posts, profile-posts, user-replies, mentions, ghost-posts, media
    keyword-search, location-search, location, publishing-limit, container-status
    media-insights, user-insights, replies, conversation, pending-replies, oembed
    webhook-verify, webhook-parse, intent-post, intent-follow

  Retrieval options:
    me: --user-id --fields
    profile: --username
    posts, user-replies, mentions, ghost-posts: --user-id --fields --since --until --limit --before --after
    profile-posts: --username --fields --since --until --limit --before --after
    media: --media-id --fields
    keyword-search: --query --search-type TOP|RECENT --search-mode KEYWORD|TAG
      --media-type TEXT|IMAGE|VIDEO --fields --since --until --limit --author-username
    location-search: --query and/or paired --latitude/--longitude, plus --fields
    location: --location-id --fields
    publishing-limit: --user-id --fields
    container-status: --container-id --fields
    media-insights: --media-id --metrics
    user-insights: --user-id --metrics --since --until --breakdown country|city|age|gender
    replies, conversation: --media-id --fields --reverse --before --after
    pending-replies: --media-id --approval-status pending|ignored --fields --reverse --before --after
    oembed: --url --max-width (no access token required)

  Local options:
    auth-url: --client-id --redirect-uri --state
    token-debug: --input-token --app-access-token
    intent-post: --text --url --tag --reply-control --reply-post-shortcode --quote-post-shortcode
    intent-follow: --username
    webhook-verify: --mode --verify-token --challenge --expected-token
    webhook-parse: --file

  Authentication: inject THREADS_ACCESS_TOKEN with kinko; tokens are never stored.
  """

  public static let writerHelp = """
  thread-gateway-writer — mutating Threads API client

  Commands:
    scopes, oauth-exchange, token-long-lived, token-refresh, app-token
    create, publish, repost, delete
    hide-reply, unhide-reply, approve-reply, ignore-reply

  create supports TEXT, IMAGE, VIDEO (including reel-equivalent posts), and CAROUSEL.
  create options:
    --user-id --media-type --text --image-url --video-url --children --carousel-item
    --reply-to-id --quote-post-id --reply-control --topic-tag --link-attachment --alt-text
    --allowlisted-country-codes --spoiler-media --spoiler-ranges --poll-options
    --text-attachment-text --text-attachment-url --text-attachment-styles
    --gif-id --gif-provider --auto-publish-text --ghost-post --enable-reply-approvals
    --location-id --cross-share-to-instagram --cross-share-dark-mode
  Other operations: publish --user-id --creation-id; repost/delete --media-id;
    reply management --reply-id.
  Credential options:
    oauth-exchange: --client-id --client-secret --redirect-uri --code
    token-long-lived: --client-secret --short-lived-token
    token-refresh: --access-token
    app-token: --client-id --client-secret
  Authentication: inject THREADS_ACCESS_TOKEN and app credentials with kinko; secrets are never stored.
  """
}
