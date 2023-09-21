// Created by Brad Bergeron on 9/21/23.

import Foundation

// MARK: - URL + ExpressibleByStringLiteral

extension URL: ExpressibleByStringLiteral {
  public init(stringLiteral string: StringLiteralType) {
    guard let url = URL(string: string) else {
      preconditionFailure("Cannot construct a URL from an invalid string.")
    }
    self = url
  }
}
