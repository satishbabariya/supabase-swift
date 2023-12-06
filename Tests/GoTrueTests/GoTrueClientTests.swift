//
//  GoTrueClientTests.swift
//
//
//  Created by Guilherme Souza on 23/10/23.
//

import XCTest
@_spi(Internal) import _Helpers
import ConcurrencyExtras

@testable import GoTrue

final class GoTrueClientTests: XCTestCase {
  func testAuthStateChanges() async throws {
    let session = Session.validSession
    let sut = makeSUT()

    let events = ActorIsolated([AuthChangeEvent]())
    let expectation = expectation(description: "onAuthStateChangeEnd")

    await withDependencies {
      $0.eventEmitter = .live
      $0.sessionManager.session = { @Sendable _ in session }
    } operation: {
      let authStateStream = await sut.authStateChanges

      let streamTask = Task {
        for await (event, _) in authStateStream {
          await events.withValue {
            $0.append(event)
          }

          expectation.fulfill()
        }
      }

      await fulfillment(of: [expectation])

      let events = await events.value
      XCTAssertEqual(events, [.initialSession])

      streamTask.cancel()
    }
  }

  func testSignOut() async throws {
    let sut = makeSUT()

    let events = LockIsolated([AuthChangeEvent]())

    try await withDependencies {
      $0.api.execute = { _ in .stub() }
      $0.eventEmitter = .mock
      $0.eventEmitter.emit = { @Sendable event, _, _ in
        events.withValue {
          $0.append(event)
        }
      }
      $0.sessionManager = .live
      $0.sessionStorage = .inMemory
      try $0.sessionStorage.storeSession(StoredSession(session: .validSession))
    } operation: {
      try await sut.signOut()

      do {
        _ = try await sut.session
      } catch GoTrueError.sessionNotFound {
      } catch {
        XCTFail("Unexpected error.")
      }

      XCTAssertEqual(events.value, [.signedOut])
    }
  }

  func testSignOutWithOthersScopeShouldNotRemoveLocalSession() async throws {
    let sut = makeSUT()

    try await withDependencies {
      $0.api.execute = { _ in .stub() }
      $0.sessionManager = .live
      $0.sessionStorage = .inMemory
      try $0.sessionStorage.storeSession(StoredSession(session: .validSession))
    } operation: {
      try await sut.signOut(scope: .others)

      // Session should still be valid.
      _ = try await sut.session
    }
  }

  func testSignOutShouldRemoveSessionIfUserIsNotFound() async throws {
    let sut = makeSUT()

    try await withDependencies {
      $0.api.execute = { _ in throw GoTrueError.api(GoTrueError.APIError(code: 404)) }
      $0.sessionManager = .live
      $0.sessionStorage = .inMemory
      try $0.sessionStorage.storeSession(StoredSession(session: .validSession))
    } operation: {
      do {
        try await sut.signOut()
      } catch GoTrueError.api {
      } catch {
        XCTFail("Unexpected error: \(error)")
      }

      // should still have a session
      _ = try await sut.session
    }
  }

  func testSignOutShouldRemoveSessionIfJWTIsInvalid() async throws {
    let sut = makeSUT()

    try await withDependencies {
      $0.api.execute = { _ in throw GoTrueError.api(GoTrueError.APIError(code: 401)) }
      $0.sessionManager = .live
      $0.sessionStorage = .inMemory
      try $0.sessionStorage.storeSession(StoredSession(session: .validSession))
    } operation: {
      do {
        try await sut.signOut()
      } catch GoTrueError.api {
      } catch {
        XCTFail("Unexpected error: \(error)")
      }

      // should still have a session
      _ = try await sut.session
    }
  }

  private func makeSUT() -> GoTrueClient {
    let configuration = GoTrueClient.Configuration(
      url: clientURL,
      headers: ["apikey": "dummy.api.key"]
    )

    let sut = GoTrueClient(
      configuration: configuration,
      sessionManager: .mock,
      codeVerifierStorage: .mock,
      api: .mock,
      eventEmitter: .mock,
      sessionStorage: .mock
    )

    addTeardownBlock { [weak sut] in
      XCTAssertNil(sut, "sut should be deallocated.")
    }

    return sut
  }
}

extension Response {
  static func stub(_ body: String = "", code: Int = 200) -> Response {
    Response(
      data: body.data(using: .utf8)!,
      response: HTTPURLResponse(
        url: clientURL,
        statusCode: code,
        httpVersion: nil,
        headerFields: nil
      )!
    )
  }
}
