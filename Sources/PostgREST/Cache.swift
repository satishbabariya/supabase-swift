//
//  Cache.swift
//  Supabase
//
//  Created by Guilherme Souza on 01/10/24.
//

import Helpers
import ConcurrencyExtras
import Foundation

extension PostgrestClient {
  public static func cache(
    configuration: Configuration
  ) -> PostgrestClient {
    let cache = Cache(originalFetch: configuration.fetch, logger: configuration.logger)
    var configuration = configuration
    configuration.fetch = { try await cache.fetchWithCache($0) }
    return PostgrestClient(configuration: configuration)
  }

  actor Cache {
    let originalFetch: FetchHandler
    let logger: (any SupabaseLogger)?

    init(originalFetch: @escaping FetchHandler, logger: (any SupabaseLogger)?) {
      self.originalFetch = originalFetch
      self.logger = logger
    }

    typealias Table = String
    typealias Query = String

    var storage: [
      Table: [
        Query: (Data, URLResponse)
      ]
    ] = [:]

    func fetchWithCache(_ request: URLRequest) async throws -> (Data, URLResponse) {
      let table = request.url?.lastPathComponent ?? ""

      if request.httpMethod == "GET" {
        let query = request.url?.query ?? ""

        if let cachedTable = storage[table],
           let cachedValue = cachedTable[query]
        {
          logger?.verbose("cache hit: \(table) \(query)")
          return cachedValue
        }

        logger?.verbose("cache miss: \(table) \(query)")
        let value = try await originalFetch(request)
        storage[table, default: [:]][query] = value

        return value
      } else if request.httpMethod == "POST" || request.httpMethod == "PUT" || request.httpMethod == "PATCH" || request.httpMethod == "DELETE" {
        let value = try await originalFetch(request)
        // if success, invalidate local cache for table
        logger?.verbose("cache invalidation: \(table)")
        storage[table] = nil
        return value
      } else {
        return try await originalFetch(request)
      }
    }
  }
}
