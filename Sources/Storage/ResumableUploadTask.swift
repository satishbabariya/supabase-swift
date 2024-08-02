//
//  ResumableUploadTask.swift
//  Supabase
//
//  Created by Guilherme Souza on 30/07/24.
//

import Foundation
import ConcurrencyExtras

@available(macOS 14.0, iOS 17.0, *)
public final class ResumableUploadTask: Sendable {

  enum State {
    case idle
    case inProgress(URLSession, URLSessionUploadTask)
    case paused(URLSession, resumeData: Data)
  }

  let config: StorageClientConfiguration
  let bucket: String
  let path: String
  let file: Data
  let state = LockIsolated(State.idle)

  init(
    config: StorageClientConfiguration,
    bucket: String,
    path: String,
    file: Data
  ) {
    self.config = config
    self.bucket = bucket
    self.path = path
    self.file = file
  }

  public func startOrResume() async {
    switch state.value {
    case .idle: await start()
    case .paused(let session, let resumeData): await resume(session: session, resumeData: resumeData)
    case .inProgress: break
    }
  }

  private func start() async {
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)

    var request = URLRequest(url: self.config.url.appendingPathComponent("upload/resumable"))
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = self.config.headers

    await withTaskCancellationHandler {
      await withCheckedContinuation { continuation in
        let task = session.uploadTask(with: request, from: file) { [weak self] data, response, error in
          self?.handleUploadTaskResult(data, response, error, session)
          continuation.resume()
        }

        task.resume()
        state.withValue {
          $0 = .inProgress(session, task)
        }
      }

    } onCancel: {
      state.withValue {
        if case let .inProgress(_, task) = $0 {
          task.cancel()
        }
      }
    }



  }

  public func pause() async {
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      state.withValue { state in
        guard case let .inProgress(session, task) = state else { return }

        task.cancel { [weak self] resumeData in
          defer { continuation.resume() }

          guard let self else { return }
          guard let resumeData else {
            self.state.setValue(.idle)
            return
          }

          self.state.setValue(.paused(session, resumeData: resumeData))
        }
      }
    }
  }

  private func resume(session: URLSession, resumeData: Data) async {
    await withCheckedContinuation { continuation in
      state.withValue { state in
        let newUploadTask = session.uploadTask(withResumeData: resumeData) { [weak self] data, response, error in
          self?.handleUploadTaskResult(data, response, error, session)
          continuation.resume()
        }

        state = .inProgress(session, newUploadTask)
      }
    }
  }

  private func handleUploadTaskResult(
    _ data: Data?,
    _ response: URLResponse?,
    _ error: (any Error)?,
    _ session: URLSession
  ) {
    if let urlError = error as? URLError, let resumeData = urlError.uploadTaskResumeData {
      state.setValue(.paused(session, resumeData: resumeData))
    } else {
      state.setValue(.idle)
    }
  }
}

extension StorageFileApi {
  @available(macOS 14.0, iOS 17.0, *)
  public func resumableUpload(
    path: String,
    file: Data,
    options: FileOptions = FileOptions()
  ) -> ResumableUploadTask {
    ResumableUploadTask(
      config: configuration,
      bucket: bucketId, path: path, file: file)
  }
}
