public struct SearchOptions: Encodable {
  public let prefix: String

  /// The number of files you want to be returned.
  public var limit: Int?

  /// The starting position.
  public var offset: Int?

  /// The column to sort by. Can be any column inside a ``FileObject``.
  public var sortBy: SortBy?

  /// The search string to filter files by.
  public var search: String?

  public init(
    prefix: String = "", limit: Int? = nil, offset: Int? = nil, sortBy: SortBy? = nil,
    search: String? = nil
  ) {
    self.prefix = prefix
    self.limit = limit
    self.offset = offset
    self.sortBy = sortBy
    self.search = search
  }
}
