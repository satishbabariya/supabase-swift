import Foundation
import HTTPTypes
import Helpers

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Storage Bucket API
public class StorageBucketApi: StorageApi, @unchecked Sendable {
  /// Retrieves the details of all Storage buckets within an existing project.
  public func listBuckets() async throws -> [Bucket] {
    let (data, _) = try await execute(
      for: HTTPRequest(
        method: .get,
        url: configuration.url.appendingPathComponent("bucket")
      ),
      from: nil
    )

    return try configuration.decoder.decode([Bucket].self, from: data)
  }

  /// Retrieves the details of an existing Storage bucket.
  /// - Parameters:
  ///   - id: The unique identifier of the bucket you would like to retrieve.
  public func getBucket(_ id: String) async throws -> Bucket {
    let (data, _) = try await execute(
      for: HTTPRequest(
        method: .get,
        url: configuration.url.appendingPathComponent("bucket/\(id)")
      ),
      from: nil
    )

    return try configuration.decoder.decode(Bucket.self, from: data)
  }

  struct BucketParameters: Encodable {
    var id: String
    var name: String
    var `public`: Bool
    var fileSizeLimit: String?
    var allowedMimeTypes: [String]?
  }

  /// Creates a new Storage bucket.
  /// - Parameters:
  ///   - id: A unique identifier for the bucket you are creating.
  ///   - options: Options for creating the bucket.
  public func createBucket(_ id: String, options: BucketOptions = .init()) async throws {
    try await execute(
      for: HTTPRequest(
        method: .post,
        url: configuration.url.appendingPathComponent("bucket")
      ),
      from: configuration.encoder.encode(
        BucketParameters(
          id: id,
          name: id,
          public: options.public,
          fileSizeLimit: options.fileSizeLimit,
          allowedMimeTypes: options.allowedMimeTypes
        )
      )
    )
  }

  /// Updates a Storage bucket.
  /// - Parameters:
  ///   - id: A unique identifier for the bucket you are updating.
  ///   - options: Options for updating the bucket.
  public func updateBucket(_ id: String, options: BucketOptions) async throws {
    try await execute(
      for: HTTPRequest(
        method: .put,
        url: configuration.url.appendingPathComponent("bucket/\(id)")
      ),
      from: configuration.encoder.encode(
        BucketParameters(
          id: id,
          name: id,
          public: options.public,
          fileSizeLimit: options.fileSizeLimit,
          allowedMimeTypes: options.allowedMimeTypes
        )
      )
    )
  }

  /// Removes all objects inside a single bucket.
  /// - Parameters:
  ///   - id: The unique identifier of the bucket you would like to empty.
  public func emptyBucket(_ id: String) async throws {
    try await execute(
      for: HTTPRequest(
        method: .post,
        url: configuration.url.appendingPathComponent("bucket/\(id)/empty")
      ),
      from: nil
    )
  }

  /// Deletes an existing bucket. A bucket can't be deleted with existing objects inside it.
  /// You must first `empty()` the bucket.
  /// - Parameters:
  ///   - id: The unique identifier of the bucket you would like to delete.
  public func deleteBucket(_ id: String) async throws {
    try await execute(
      for: HTTPRequest(
        method: .delete,
        url: configuration.url.appendingPathComponent("bucket/\(id)")
      ),
      from: nil
    )
  }
}
