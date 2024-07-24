//
//  SchemaMetadata.swift
//
//
//  Created by Guilherme Souza on 21/06/24.
//

import Foundation

public struct _AnyPropertyMetadata: @unchecked Sendable /* AnyKeyPath */ {
  let name: String
  let keyPath: AnyKeyPath
}

extension _AnyPropertyMetadata {
  public init(codingKey: any CodingKey, keyPath: AnyKeyPath) {
    self.init(name: codingKey.stringValue, keyPath: keyPath)
  }
}

public struct _PropertyMetadata<Model, Value>: @unchecked Sendable /* AnyKeyPath */ {
  let name: String
  let keyPath: KeyPath<Model, Value>
}

extension _PropertyMetadata {
  public init(codingKey: any CodingKey, keyPath: KeyPath<Model, Value>) {
    self.init(name: codingKey.stringValue, keyPath: keyPath)
  }
}

public protocol PostgrestType: Sendable {
  var _propertiesMetadata: [_AnyPropertyMetadata] { get }
}
