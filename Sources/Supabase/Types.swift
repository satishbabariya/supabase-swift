import Auth
import Foundation

public struct SupabaseClientOptions: Sendable {
  public let db: DatabaseOptions
  public let auth: AuthOptions
  public let global: GlobalOptions

  public struct DatabaseOptions: Sendable {
    /// The Postgres schema which your tables belong to. Must be on the list of exposed schemas in
    /// Supabase.
    public let schema: String?

    /// The JSONEncoder to use when encoding database request objects.
    public let encoder: JSONEncoder?

    /// The JSONDecoder to use when decoding database response objects.
    public let decoder: JSONDecoder?

    public init(
      schema: String? = nil,
      encoder: JSONEncoder? = nil,
      decoder: JSONDecoder? = nil
    ) {
      self.schema = schema
      self.encoder = encoder
      self.decoder = decoder
    }
  }

  public struct AuthOptions: Sendable {
    /// A storage provider. Used to store the logged-in session.
    public let storage: AuthLocalStorage?

    /// OAuth flow to use - defaults to PKCE flow. PKCE is recommended for mobile and server-side
    /// applications.
    public let flowType: AuthFlowType

    /// The JSONEncoder to use when encoding database request objects.
    public let encoder: JSONEncoder?

    /// The JSONDecoder to use when decoding database response objects.
    public let decoder: JSONDecoder?

    public init(
      storage: AuthLocalStorage? = nil,
      flowType: AuthFlowType = .pkce,
      encoder: JSONEncoder? = nil,
      decoder: JSONDecoder? = nil
    ) {
      self.storage = storage
      self.flowType = flowType
      self.encoder = encoder
      self.decoder = decoder
    }
  }

  public struct GlobalOptions: Sendable {
    /// Optional headers for initializing the client, it will be passed down to all sub-clients.
    public let headers: [String: String]

    /// A session to use for making requests, defaults to `URLSession.shared`.
    public let session: URLSession

    public init(headers: [String: String] = [:], session: URLSession = .shared) {
      self.headers = headers
      self.session = session
    }
  }

  public init(
    db: DatabaseOptions = .init(),
    auth: AuthOptions = .init(),
    global: GlobalOptions = .init()
  ) {
    self.db = db
    self.auth = auth
    self.global = global
  }
}
