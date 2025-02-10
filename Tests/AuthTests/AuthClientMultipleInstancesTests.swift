//
//  AuthClientMultipleInstancesTests.swift
//
//
//  Created by Guilherme Souza on 05/07/24.
//

import TestHelpers
import XCTest

@testable import Auth

final class AuthClientMultipleInstancesTests: XCTestCase {
  func testMultipleAuthClientInstances() {
    let url = URL(string: "http://localhost:54321/auth")!

    let client1Storage = InMemoryLocalStorage()
    let client2Storage = InMemoryLocalStorage()

    let client1 = AuthClient(
      configuration: AuthClient.Configuration(
        url: url,
        localStorage: client1Storage,
        logger: nil
      )
    )

    let client2 = AuthClient(
      configuration: AuthClient.Configuration(
        url: url,
        localStorage: client2Storage,
        logger: nil
      )
    )

    XCTAssertIdentical(
      client1.configuration.localStorage as? InMemoryLocalStorage,
      client1Storage
    )
    XCTAssertIdentical(
      client2.configuration.localStorage as? InMemoryLocalStorage,
      client2Storage
    )
  }
}
