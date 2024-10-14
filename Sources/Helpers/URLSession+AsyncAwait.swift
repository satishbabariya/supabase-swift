#if canImport(FoundationNetworking) && compiler(<6)
  import Foundation
  import FoundationNetworking

  /// A set of errors that can be returned from the
  /// polyfilled extensions on ``URLSession``
  public enum URLSessionPolyfillError: Error {
    /// Returned when no data and no error are provided.
    case noDataNoErrorReturned
  }

  /// A private helper which let's us manage the asynchronous cancellation
  /// of the returned URLSessionTasks from our polyfill implementation.
  ///
  /// This is a lightly modified version of https://github.com/swift-server/async-http-client/blob/16aed40d3e30e8453e226828d59ad2e2c5fd6355/Sources/AsyncHTTPClient/AsyncAwait/HTTPClient%2Bexecute.swift#L152-L156
  /// we use this for the same reasons as listed in the linked code in that there
  /// really isn't a good way to deal with cancellation in the 'with*Continuation' functions.
  private actor URLSessionTaskCancellationHelper {
    enum State {
      case initialized
      case registered(URLSessionTask)
      case cancelled
    }

    var state: State = .initialized

    init() {}

    nonisolated func register(_ task: URLSessionTask) {
      Task {
        await actuallyRegister(task)
      }
    }

    nonisolated func cancel() {
      Task {
        await actuallyCancel()
      }
    }

    private func actuallyRegister(_ task: URLSessionTask) {
      switch state {
      case .registered:
        preconditionFailure(
          "Attempting to register another task while the current helper already has a registered task!"
        )
      case .cancelled:
        // Run through any cancellation logic which should be a noop as we're already cancelled.
        actuallyCancel()
        // Cancel the passed in task since we're already in a cancelled state.
        task.cancel()
      case .initialized:
        state = .registered(task)
      }
    }

    private func actuallyCancel() {
      // Handle whatever needs to be done based on the current state
      switch state {
      case let .registered(task):
        task.cancel()
      case .cancelled:
        break
      case .initialized:
        break
      }

      // Set state into cancelled to short circuit subsequent cancellations or registrations.
      state = .cancelled
    }
  }

  extension URLSession {
    public func data(
      for request: URLRequest,
      delegate _: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (Data, URLResponse) {
      let helper = URLSessionTaskCancellationHelper()

      return try await withTaskCancellationHandler(operation: {
        try await withCheckedThrowingContinuation { continuation in
          let task = dataTask(with: request, completionHandler: { data, response, error in
            if let error {
              continuation.resume(throwing: error)
            } else if let data, let response {
              continuation.resume(returning: (data, response))
            } else {
              continuation.resume(throwing: URLSessionPolyfillError.noDataNoErrorReturned)
            }
          })

          helper.register(task)

          task.resume()
        }
      }, onCancel: {
        helper.cancel()
      })
    }

    public func upload(
      for request: URLRequest,
      from bodyData: Data,
      delegate _: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (Data, URLResponse) {
      let helper = URLSessionTaskCancellationHelper()

      return try await withTaskCancellationHandler(operation: {
        try await withCheckedThrowingContinuation { continuation in
          let task = uploadTask(
            with: request,
            from: bodyData,
            completionHandler: { data, response, error in
              if let error {
                continuation.resume(throwing: error)
              } else if let data, let response {
                continuation.resume(returning: (data, response))
              } else {
                continuation.resume(throwing: URLSessionPolyfillError.noDataNoErrorReturned)
              }
            }
          )

          helper.register(task)

          task.resume()
        }
      }, onCancel: {
        helper.cancel()
      })
    }
  }

#endif
