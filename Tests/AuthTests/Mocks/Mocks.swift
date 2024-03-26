//
//  Mocks.swift
//
//
//  Created by Guilherme Souza on 27/10/23.
//

import ConcurrencyExtras
import Foundation
import XCTestDynamicOverlay
@_spi(Internal) import _Helpers

@testable import Auth

let clientURL = URL(string: "http://localhost:54321/auth/v1")!

extension CodeVerifierStorage {
  static let mock = Self(
    getCodeVerifier: unimplemented("CodeVerifierStorage.getCodeVerifier"),
    storeCodeVerifier: unimplemented("CodeVerifierStorage.storeCodeVerifier"),
    deleteCodeVerifier: unimplemented("CodeVerifierStorage.deleteCodeVerifier")
  )
}

extension SessionStorage {
  static let mock = Self(
    getSession: unimplemented("SessionStorage.getSession"),
    storeSession: unimplemented("SessionStorage.storeSession"),
    deleteSession: unimplemented("SessionStorage.deleteSession")
  )

  static var inMemory: Self {
    let session = LockIsolated(StoredSession?.none)

    return Self(
      getSession: { session.value },
      storeSession: { session.setValue($0) },
      deleteSession: { session.setValue(nil) }
    )
  }
}

extension SessionRefresher {
  static let mock = Self(refreshSession: unimplemented("SessionRefresher.refreshSession"))
}

struct InsecureMockLocalStorage: AuthLocalStorage {
  private let defaults: UserDefaults

  init(service: String, accessGroup _: String?) {
    guard let defaults = UserDefaults(suiteName: service) else {
      fatalError("Unable to create defautls for service: \(service)")
    }

    self.defaults = defaults
  }

  func store(key: String, value: Data) throws {
    print("[WARN] YOU ARE YOU WRITING TO INSECURE LOCAL STORAGE")
    defaults.set(value, forKey: key)
  }

  func retrieve(key: String) throws -> Data? {
    print("[WARN] YOU ARE READING FROM INSECURE LOCAL STORAGE")
    return defaults.data(forKey: key)
  }

  func remove(key: String) throws {
    print("[WARN] YOU ARE REMOVING A KEY FROM INSECURE LOCAL STORAGE")
    defaults.removeObject(forKey: key)
  }
}

extension Dependencies {
  static let localStorage: some AuthLocalStorage = {
    #if !os(Linux) && !os(Windows)
      KeychainLocalStorage(service: "supabase.gotrue.swift", accessGroup: nil)
    #elseif os(Windows)
      WinCredLocalStorage(service: "supabase.gotrue.swift")
    #else
      // Only use an insecure mock when needed for testing
      InsecureMockLocalStorage(service: "supabase.gotrue.swift", accessGroup: nil)
    #endif
  }()

  static let mock = Dependencies(
    configuration: AuthClient.Configuration(
      url: clientURL,
      localStorage: Self.localStorage,
      logger: nil
    ),
    sessionManager: .mock,
    api: .mock,
    eventEmitter: .mock,
    sessionStorage: .mock,
    sessionRefresher: .mock,
    codeVerifierStorage: .mock,
    logger: nil
  )
}

extension Session {
  static let validSession = Session(
    accessToken: "accesstoken",
    tokenType: "bearer",
    expiresIn: 120,
    expiresAt: Date().addingTimeInterval(120).timeIntervalSince1970,
    refreshToken: "refreshtoken",
    user: User(fromMockNamed: "user")
  )

  static let expiredSession = Session(
    accessToken: "accesstoken",
    tokenType: "bearer",
    expiresIn: 60,
    expiresAt: Date().addingTimeInterval(60).timeIntervalSince1970,
    refreshToken: "refreshtoken",
    user: User(fromMockNamed: "user")
  )
}

final class InMemoryLocalStorage: AuthLocalStorage, @unchecked Sendable {
  let storage = LockIsolated([String: Data]())

  func store(key: String, value: Data) throws {
    storage.withValue {
      $0[key] = value
    }
  }

  func retrieve(key: String) throws -> Data? {
    storage.value[key]
  }

  func remove(key: String) throws {
    storage.withValue {
      $0[key] = nil
    }
  }
}
