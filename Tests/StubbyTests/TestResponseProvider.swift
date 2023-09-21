// Created by Brad Bergeron on 9/21/23.

import Foundation
import Stubby
import XCTest

// MARK: - TestResponseProvider

struct TestResponseProvider: StubbyResponseProvider {
  static func respondsTo(request: URLRequest) -> Bool {
    true
  }

  static func response(for request: URLRequest) throws -> Result<StubbyResponse, Error> {
    switch try XCTUnwrap(request.url) {
    case .repoURL:
      return try .success(.init(data: try XCTUnwrap("Hello, world!".data(using: .utf8)), for: .repoURL))
    default:
      return .failure(URLError(.unsupportedURL))
    }
  }
}
