//
//  Contants.swift
//
//
//  Created by Guilherme Souza on 22/05/24.
//

import Foundation
import HTTPTypes

let EXPIRY_MARGIN: TimeInterval = 30
let STORAGE_KEY = "supabase.auth.token"

let API_VERSION_HEADER_NAME = "X-Supabase-Api-Version"

extension HTTPField.Name {
  static let apiVersionHeaderName = HTTPField.Name(API_VERSION_HEADER_NAME)!
}

let API_VERSIONS: [APIVersion.Name: APIVersion] = [
  ._20240101: ._20240101,
]

struct APIVersion {
  let timestamp: Date
  let name: Name

  enum Name: String {
    case _20240101 = "2024-01-01"
  }

  static func date(for name: Name) -> Date {
    let formattar = ISO8601DateFormatter()
    formattar.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formattar.date(from: "\(name.rawValue)T00:00:00.0Z")!
  }
}

extension APIVersion {
  static let _20240101 = APIVersion(
    timestamp: APIVersion.date(for: ._20240101),
    name: ._20240101
  )
}
