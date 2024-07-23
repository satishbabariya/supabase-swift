//
//  Dependencies.swift
//  SlackClone
//
//  Created by Guilherme Souza on 04/01/24.
//

import Foundation
import Supabase

class Dependencies {
  static let shared = Dependencies()

  let channel = ChannelStore.shared
  let users = UserStore.shared
  let messages = MessageStore.shared
}

struct User: Codable, Identifiable, Hashable {
  var id: UUID
  var username: String
}

struct AddChannel: Encodable {
  var slug: String
  var createdBy: UUID
}

struct Channel: Identifiable, Hashable, PostgrestModel {
  var id: Int
  var slug: String
  var insertedAt: Date

  struct Insert: PostgrestType, PostgrestEncodable {
    var id: Int?
    var slug: String
    var createdBy: UUID
    var insertedAt: Date?

    var propertiesMetadata: [AnyPropertyMetadata] {
      [
        id == nil ? nil : AnyPropertyMetadata(codingKey: CodingKeys.id, keyPath: \Insert.id),
        AnyPropertyMetadata(codingKey: CodingKeys.slug, keyPath: \Self.slug),
        AnyPropertyMetadata(codingKey: CodingKeys.createdBy, keyPath: \Self.createdBy),
        insertedAt == nil ? nil : AnyPropertyMetadata(codingKey: CodingKeys.insertedAt, keyPath: \Self.insertedAt),
      ].compactMap { $0 }
    }
  }

  struct Update: PostgrestType, PostgrestEncodable {
    var id: Int?
    var slug: String?
    var insertedAt: Date?

    var propertiesMetadata: [AnyPropertyMetadata] {
      [
        id == nil ? nil : AnyPropertyMetadata(codingKey: CodingKeys.id, keyPath: \Insert.id),
        slug == nil ? nil : AnyPropertyMetadata(codingKey: CodingKeys.slug, keyPath: \Self.slug),
        insertedAt == nil ? nil : AnyPropertyMetadata(codingKey: CodingKeys.insertedAt, keyPath: \Self.insertedAt),
      ].compactMap { $0 }
    }
  }

  enum Metadata: SchemaMetadata {
    static let tableName: String = "channels"

    struct Attributes {
      let id = AnyPropertyMetadata(codingKey: CodingKeys.id, keyPath: \Channel.id)
      let slug = AnyPropertyMetadata(codingKey: CodingKeys.slug, keyPath: \Channel.slug)
      let insertedAt = AnyPropertyMetadata(codingKey: CodingKeys.insertedAt, keyPath: \Channel.insertedAt)
    }
    static let attributes = Attributes()

    struct TypedAttributes {
      let id = PropertyMetadata(codingKey: CodingKeys.id, keyPath: \Channel.id)
      let slug = PropertyMetadata(codingKey: CodingKeys.slug, keyPath: \Channel.slug)
      let insertedAt = PropertyMetadata(codingKey: CodingKeys.insertedAt, keyPath: \Channel.insertedAt)
    }
    static let typedAttributes = TypedAttributes()
  }
}

struct Message: Identifiable, Decodable, Hashable {
  var id: Int
  var insertedAt: Date
  var message: String
  var user: User
  var channel: Channel
}

struct NewMessage: Codable {
  var message: String
  var userId: UUID
  let channelId: Int
}

struct UserPresence: Codable, Hashable {
  var userId: UUID
  var onlineAt: Date
}
