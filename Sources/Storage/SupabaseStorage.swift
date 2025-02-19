import Foundation
import Helpers

public typealias SupabaseLogger = Helpers.SupabaseLogger
public typealias SupabaseLogMessage = Helpers.SupabaseLogMessage

public struct StorageClientConfiguration: Sendable {
  public let url: URL
  public var headers: [String: String]
  public let session: StorageHTTPSession
  public let logger: (any SupabaseLogger)?

  public init(
    url: URL,
    headers: [String: String],
    session: StorageHTTPSession = .init(),
    logger: (any SupabaseLogger)? = nil
  ) {
    self.url = url
    self.headers = headers
    self.session = session
    self.logger = logger
  }
}

public class SupabaseStorageClient: StorageBucketApi, @unchecked Sendable {
  /// Perform file operation in a bucket.
  /// - Parameter id: The bucket id to operate on.
  /// - Returns: StorageFileApi object
  public func from(_ id: String) -> StorageFileApi {
    StorageFileApi(bucketId: id, configuration: configuration)
  }
}
