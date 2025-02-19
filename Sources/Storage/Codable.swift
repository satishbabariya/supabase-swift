//
//  Codable.swift
//
//
//  Created by Guilherme Souza on 18/10/23.
//

import ConcurrencyExtras
import Foundation

extension JSONEncoder {
  static let storageEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
  }()

  static let unconfiguredStorageEncoder: JSONEncoder = .init()
}

extension JSONDecoder {
  static var storageDecoder: JSONDecoder {
    .default
  }
}
