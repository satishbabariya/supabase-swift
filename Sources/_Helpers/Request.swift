import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

func stringfy(_ data: Data?) -> String {
  guard let data else {
    return "<none>"
  }

  do {
    let object = try JSONSerialization.jsonObject(with: data, options: [])
    let prettyData = try JSONSerialization.data(
      withJSONObject: object,
      options: [.prettyPrinted, .sortedKeys]
    )
    return String(data: prettyData, encoding: .utf8) ?? "<failed>"
  } catch {
    return String(data: data, encoding: .utf8) ?? "<failed>"
  }
}

extension CharacterSet {
  /// Creates a CharacterSet from RFC 3986 allowed characters.
  ///
  /// RFC 3986 states that the following characters are "reserved" characters.
  ///
  /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
  /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
  ///
  /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to
  /// allow
  /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?"
  /// and "/"
  /// should be percent-escaped in the query string.
  static let postgrestURLQueryAllowed: CharacterSet = {
    let generalDelimitersToEncode =
      ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimitersToEncode = "!$&'()*+,;="
    let encodableDelimiters =
      CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

    return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
  }()
}
