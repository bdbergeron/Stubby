// Created by Brad Bergeron on 9/21/23.

import Foundation
import XCTest

@testable import Stubby

// MARK: - TestStubbyResponseProvider

struct TestStubbyResponseProvider: StubbyResponseProvider {
  enum Error: Swift.Error {
    case noStubbedResponse(_ request: URLRequest)
  }

  static func respondsTo(request: URLRequest) -> Bool {
    true
  }

  static func response(for request: URLRequest) throws -> Result<StubbyResponse, Swift.Error> {
    switch try XCTUnwrap(request.url) {
    case "https://bdbergeron.github.io":
      return try .success(
        .init(
          data: try XCTUnwrap("Hello, world!".data(using: .utf8)),
          for: "https://bdbergeron.github.io"))
    default:
      return .failure(Error.noStubbedResponse(request))
    }
  }
}

// MARK: - TestStubbyResponseProvider.Error + CustomNSError

extension TestStubbyResponseProvider.Error: LocalizedError, CustomNSError {
  var errorDescription: String? {
    switch self {
    case .noStubbedResponse(let request):
      return "No stubbed response for request: \(request)"
    }
  }
}
