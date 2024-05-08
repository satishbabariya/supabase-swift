//
//  StorageFileIntegrationTests.swift
//
//
//  Created by Guilherme Souza on 07/05/24.
//

import InlineSnapshotTesting
import Storage
import XCTest

final class StorageFileIntegrationTests: XCTestCase {
  let storage = SupabaseStorageClient(
    configuration: StorageClientConfiguration(
      url: URL(string: "\(DotEnv.SUPABASE_URL)/storage/v1")!,
      headers: [
        "Authorization": "Bearer \(DotEnv.SUPABASE_SERVICE_ROLE_KEY)",
      ],
      logger: nil
    )
  )

  var bucketName = ""
  var file = Data()
  var uploadPath = ""

  override func setUp() async throws {
    try await super.setUp()

    bucketName = try await newBucket()
    file = try Data(contentsOf: uploadFileURL("sadcat.jpg"))
    uploadPath = "testpath/file-\(UUID().uuidString).jpg"
  }

  override func tearDown() async throws {
    try? await storage.emptyBucket(bucketName)
    try? await storage.deleteBucket(bucketName)

    try await super.tearDown()
  }

  func testGetPublicURL() throws {
    let publicURL = try storage.from(bucketName).getPublicURL(path: uploadPath)
    XCTAssertEqual(
      publicURL.absoluteString,
      "\(DotEnv.SUPABASE_URL)/storage/v1/object/public/\(bucketName)/\(uploadPath)"
    )
  }

  func testGetPublicURLWithDownloadQueryString() throws {
    let publicURL = try storage.from(bucketName).getPublicURL(path: uploadPath, download: true)
    XCTAssertEqual(
      publicURL.absoluteString,
      "\(DotEnv.SUPABASE_URL)/storage/v1/object/public/\(bucketName)/\(uploadPath)?download="
    )
  }

  func testGetPublicURLWithCustomDownload() throws {
    let publicURL = try storage.from(bucketName).getPublicURL(path: uploadPath, download: "test.jpg")
    XCTAssertEqual(
      publicURL.absoluteString,
      "\(DotEnv.SUPABASE_URL)/storage/v1/object/public/\(bucketName)/\(uploadPath)?download=test.jpg"
    )
  }

  func testSignURL() async throws {
    _ = try await storage.from(bucketName).upload(path: uploadPath, file: file)

    let url = try await storage.from(bucketName).createSignedURL(path: uploadPath, expiresIn: 2000)
    XCTAssertTrue(
      url.absoluteString.contains("\(DotEnv.SUPABASE_URL)/storage/v1/object/sign/\(bucketName)/\(uploadPath)")
    )
  }

  func testSignURL_withDownloadQueryString() async throws {
    _ = try await storage.from(bucketName).upload(path: uploadPath, file: file)

    let url = try await storage.from(bucketName).createSignedURL(path: uploadPath, expiresIn: 2000, download: true)
    XCTAssertTrue(
      url.absoluteString.contains("\(DotEnv.SUPABASE_URL)/storage/v1/object/sign/\(bucketName)/\(uploadPath)")
    )
    XCTAssertTrue(url.absoluteString.contains("&download="))
  }

  func testSignURL_withCustomFilenameForDownload() async throws {
    _ = try await storage.from(bucketName).upload(path: uploadPath, file: file)

    let url = try await storage.from(bucketName).createSignedURL(path: uploadPath, expiresIn: 2000, download: "test.jpg")
    XCTAssertTrue(
      url.absoluteString.contains("\(DotEnv.SUPABASE_URL)/storage/v1/object/sign/\(bucketName)/\(uploadPath)")
    )
    XCTAssertTrue(url.absoluteString.contains("&download=test.jpg"))
  }

  func testUploadAndUpdateFile() async throws {
    let file2 = try Data(contentsOf: uploadFileURL("file-2.txt"))

    try await storage.from(bucketName).upload(path: uploadPath, file: file)

    let res = try await storage.from(bucketName).update(path: uploadPath, file: file2)
    XCTAssertEqual(res.path, uploadPath)
  }

  func testUploadFileWithinFileSizeLimit() async throws {
    bucketName = try await newBucket(prefix: "with-limit", options: BucketOptions(public: true, fileSizeLimit: "1mb"))

    try await storage.from(bucketName).upload(path: uploadPath, file: file)
  }

  func testUploadFileThatExceedFileSizeLimit() async throws {
    bucketName = try await newBucket(prefix: "with-limit", options: BucketOptions(public: true, fileSizeLimit: "1kb"))

    do {
      try await storage.from(bucketName).upload(path: uploadPath, file: file)
      XCTFail("Unexpected success")
    } catch {
      assertInlineSnapshot(of: error, as: .dump) {
        """
        ▿ StorageError
          ▿ error: Optional<String>
            - some: "Payload too large"
          - message: "The object exceeded the maximum allowed size"
          ▿ statusCode: Optional<String>
            - some: "413"

        """
      }
    }
  }

  func testUploadFileWithValidMimeType() async throws {
    bucketName = try await newBucket(prefix: "with-mimetype", options: BucketOptions(public: true, allowedMimeTypes: ["image/jpeg"]))

    try await storage.from(bucketName).upload(
      path: uploadPath,
      file: file,
      options: FileOptions(
        contentType: "image/jpeg"
      )
    )
  }

  func testUploadFileWithInvalidMimeType() async throws {
    bucketName = try await newBucket(prefix: "with-mimetype", options: BucketOptions(public: true, allowedMimeTypes: ["image/png"]))

    do {
      try await storage.from(bucketName).upload(
        path: uploadPath,
        file: file,
        options: FileOptions(
          contentType: "image/jpeg"
        )
      )
      XCTFail("Unexpected success")
    } catch {
      assertInlineSnapshot(of: error, as: .dump) {
        """
        ▿ StorageError
          ▿ error: Optional<String>
            - some: "invalid_mime_type"
          - message: "mime type image/jpeg is not supported"
          ▿ statusCode: Optional<String>
            - some: "415"

        """
      }
    }
  }

  func testSignedURLForUpload() async throws {
    let res = try await storage.from(bucketName).createSignedUploadURL(path: uploadPath)
    XCTAssertEqual(res.path, uploadPath)
    XCTAssertTrue(
      res.signedURL.absoluteString.contains("\(DotEnv.SUPABASE_URL)/storage/v1/object/upload/sign/\(bucketName)/\(uploadPath)")
    )
  }

  func testCanUploadWithSignedURLForUpload() async throws {
    let res = try await storage.from(bucketName).createSignedUploadURL(path: uploadPath)

    let uploadRes = try await storage.from(bucketName).uploadToSignedURL(path: res.path, token: res.token, file: file)
    XCTAssertEqual(uploadRes.path, uploadPath)
  }

  func testCanUploadOverwritingFilesWithSignedURL() async throws {
    try await storage.from(bucketName).upload(path: uploadPath, file: file)

    let res = try await storage.from(bucketName).createSignedUploadURL(path: uploadPath, options: CreateSignedUploadURLOptions(upsert: true))
    let uploadRes = try await storage.from(bucketName).uploadToSignedURL(path: res.path, token: res.token, file: file)
    XCTAssertEqual(uploadRes.path, uploadPath)
  }

  func testCannotUploadToSignedURLTwice() async throws {
    let res = try await storage.from(bucketName).createSignedUploadURL(path: uploadPath)

    try await storage.from(bucketName).uploadToSignedURL(path: res.path, token: res.token, file: file)

    do {
      try await storage.from(bucketName).uploadToSignedURL(path: res.path, token: res.token, file: file)
      XCTFail("Unexpected success")
    } catch {
      assertInlineSnapshot(of: error, as: .dump) {
        """
        ▿ StorageError
          ▿ error: Optional<String>
            - some: "Duplicate"
          - message: "The resource already exists"
          ▿ statusCode: Optional<String>
            - some: "409"

        """
      }
    }
  }

  private func newBucket(prefix: String = "", options: BucketOptions = BucketOptions(public: true)) async throws -> String {
    let bucketName = "\(!prefix.isEmpty ? prefix + "-" : "")bucket-\(UUID().uuidString)"
    return try await findOrCreateBucket(name: bucketName, options: options)
  }

  private func findOrCreateBucket(name: String, options: BucketOptions = BucketOptions(public: true)) async throws -> String {
    do {
      _ = try await storage.getBucket(name)
    } catch {
      try await storage.createBucket(name, options: options)
    }

    return name
  }

  private func uploadFileURL(_ fileName: String) -> URL {
    URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .appendingPathComponent("Fixtures/Upload")
      .appendingPathComponent(fileName)
  }
}
