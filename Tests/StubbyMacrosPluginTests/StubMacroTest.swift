// Created by Brad Bergeron on 10/12/23.

import MacroTesting
import XCTest

@testable import StubbyMacrosPlugin

final class StubMacroTest: XCTestCase {
  override func invokeTest() {
    withMacroTesting(macros: [StubMacro.self]) {
      super.invokeTest()
    }
  }

  func test_expansion_successResponse() throws {
    assertMacro {
      """
      #Stub(url: "https://github.com/bdbergeron/Stubby") { request in
        try .success(StubbyResponse(
          data: XCTUnwrap("Hello, world!".data(using: .utf8)),
          for: XCTUnwrap(request.url)))
      }
      """
    } expansion: {
      """
      #if DEBUG
      struct __macro_local_12StubResponsefMu_: StubbyResponseProvider {
        static let url = URL(string: "https://github.com/bdbergeron/Stubby")!
        static func respondsTo(request: URLRequest) -> Bool {
          request.url == url
        }
        static func response(for request: URLRequest) throws -> Result<StubbyResponse, Error> {
          try .success(StubbyResponse(
            data: XCTUnwrap("Hello, world!".data(using: .utf8)),
            for: XCTUnwrap(request.url)))
        }
      }
      #endif
      """
    }
  }

  func test_expansion_failureResponse() throws {
    assertMacro {
      """
      #Stub(url: "https://github.com/bdbergeron/Stubby") { _ in
        .failure(URLError(.unsupportedURL))
      }
      """
    } expansion: {
      """
      #if DEBUG
      struct __macro_local_12StubResponsefMu_: StubbyResponseProvider {
        static let url = URL(string: "https://github.com/bdbergeron/Stubby")!
        static func respondsTo(request: URLRequest) -> Bool {
          request.url == url
        }
        static func response(for request: URLRequest) throws -> Result<StubbyResponse, Error> {
          .failure(URLError(.unsupportedURL))
        }
      }
      #endif
      """
    }
  }

  func test_expansionFailsWithInvalidURL() throws {
    assertMacro {
      """
      #Stub("") { request in
        try .success(StubbyResponse(
          data: XCTUnwrap("Hello, world!".data(using: .utf8)),
          for: XCTUnwrap(request.url)))
      }
      """
    } diagnostics: {
      """
      #Stub("") { request in
            ┬─
            ╰─ 🛑 #Stub requires a valid URL.
        try .success(StubbyResponse(
          data: XCTUnwrap("Hello, world!".data(using: .utf8)),
          for: XCTUnwrap(request.url)))
      }
      """
    }
  }
}
