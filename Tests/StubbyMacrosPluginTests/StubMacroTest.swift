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

  func test_expansion_successResponse() {
    assertMacro {
      """
      #Stub(url: "https://github.com/bdbergeron/Stubby") { request in
        try .success(StubbyResponse(
          data: XCTUnwrap("Hello, world!".data(using: .utf8)),
          for: XCTUnwrap(request.url)
        ))
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
            for: XCTUnwrap(request.url)
          ))
        }
      }
      #endif
      """
    }
  }

  func test_expansion_failureResponse() {
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

  func test_expansion_multipleStubs() {
    assertMacro {
      """
      #Stub(url: "https://github.com/bdbergeron/Stubby") { request in
        try .success(StubbyResponse(
          data: XCTUnwrap("Hello, world!".data(using: .utf8)),
          for: XCTUnwrap(request.url)
        ))
      }

      #Stub(url: "https://github.com") { _ in
        .failure(URLError(.unsupportedURL))
      }

      #Stub(url: "https://apple.com") { _ in
        try .success(StubbyResponse(
          data: XCTUnwrap("Think different!".data(using: .utf8)),
          for: XCTUnwrap(request.url)
        ))
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
            for: XCTUnwrap(request.url)
          ))
        }
      }
      #endif

      #if DEBUG
      struct __macro_local_12StubResponsefMu0_: StubbyResponseProvider {
        static let url = URL(string: "https://github.com")!
        static func respondsTo(request: URLRequest) -> Bool {
          request.url == url
        }
        static func response(for request: URLRequest) throws -> Result<StubbyResponse, Error> {
          .failure(URLError(.unsupportedURL))
        }
      }
      #endif

      #if DEBUG
      struct __macro_local_12StubResponsefMu1_: StubbyResponseProvider {
        static let url = URL(string: "https://apple.com")!
        static func respondsTo(request: URLRequest) -> Bool {
          request.url == url
        }
        static func response(for request: URLRequest) throws -> Result<StubbyResponse, Error> {
          try .success(StubbyResponse(
            data: XCTUnwrap("Think different!".data(using: .utf8)),
            for: XCTUnwrap(request.url)
          ))
        }
      }
      #endif
      """
    }
  }

  func test_expansionFailsWithInvalidURL() {
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
