// Created by Brad Bergeron on 9/17/23.

import Foundation
import os

extension URLSession {
  /// Create a `URLSession` with stubbed request handlers.
  /// - Parameters:
  ///   - responseProvider: The type of ``StubbyResponseProvider`` to use for handling requests.
  ///   - configuration: An `URLSessionConfiguration` object to be used by the created `URLSession`.
  ///     Defaults to `URLSessionConfiguration.ephemeral`.
  ///   - maintainExistingProtocolClasses: By default, the created `URLSession` will utilize _only_ the underlying `StubbyURLProtocol`
  ///     protocol class. To maintain any existing protocol classes specified by `URLSessionConfiguration.protocolClasses`, set this to `true`.
  /// - Returns: A new ``URLSession`` instance.
  @available(*, deprecated, message: "Use stubbed(configuration:maintainExistingProtocolClasses:_:)")
  public static func stubbed<ResponseProvider: StubbyResponseProvider>(
    responseProvider _: ResponseProvider.Type,
    configuration: URLSessionConfiguration = .ephemeral,
    maintainExistingProtocolClasses: Bool = false
  ) -> URLSession {
    configuration.registerProtocolClass(
      StubbyURLProtocol<ResponseProvider>.self,
      maintainExistingProtocolClasses: maintainExistingProtocolClasses
    )
    return URLSession(configuration: configuration)
  }

  /// Create a `URLSession` with stubbed request handlers.
  /// - Parameters:
  ///   - responseProviders: A list of ``StubbyResponseProvider`` classes  to use for handling requests.
  ///   - configuration: An `URLSessionConfiguration` object to be used by the created `URLSession`.
  ///     Defaults to `URLSessionConfiguration.ephemeral`.
  ///   - maintainExistingProtocolClasses: By default, the created `URLSession` will utilize _only_ the underlying `StubbyURLProtocol`
  ///     protocol class. To maintain any existing protocol classes specified by `URLSessionConfiguration.protocolClasses`, set this to `true`.
  /// - Returns: A new ``URLSession`` instance.
  public static func stubbed<each ResponseProvider: StubbyResponseProvider>(
    configuration: URLSessionConfiguration = .ephemeral,
    maintainExistingProtocolClasses: Bool = false,
    _: repeat each ResponseProvider
  ) -> URLSession {
    if !maintainExistingProtocolClasses {
      configuration.protocolClasses = []
    }
    repeat configuration.registerProtocolClass(
      StubbyURLProtocol<each ResponseProvider>.self,
      maintainExistingProtocolClasses: true
    )
    return URLSession(configuration: configuration)
  }

  /// Create a `URLSession` with stubbed request handlers.
  /// - Parameters:
  ///   - configuration: An `URLSessionConfiguration` object to be used by the created `URLSession`.
  ///     Defaults to `URLSessionConfiguration.ephemeral`.
  ///   - maintainExistingProtocolClasses: By default, the created `URLSession` will utilize _only_ the underlying `StubbyURLProtocol`
  ///     protocol class. To maintain any existing protocol classes specified by `URLSessionConfiguration.protocolClasses`, set this to `true`.
  ///   - stubs: A list of ``Stub``s to use.
  /// - Returns: A new ``URLSession`` instance.
  public static func stubbed(
    configuration: URLSessionConfiguration = .ephemeral,
    maintainExistingProtocolClasses: Bool = false,
    _ stubs: [Stub]
  ) -> URLSession {
    for stub in stubs {
      StubResponseProvider.registerStub(stub)
    }
    return stubbed(
      responseProvider: StubResponseProvider.self,
      configuration: configuration,
      maintainExistingProtocolClasses: maintainExistingProtocolClasses
    )
  }

  /// Create a `URLSession` with stubbed request handlers.
  /// - Parameters:
  ///   - configuration: An `URLSessionConfiguration` object to be used by the created `URLSession`.
  ///     Defaults to `URLSessionConfiguration.ephemeral`.
  ///   - maintainExistingProtocolClasses: By default, the created `URLSession` will utilize _only_ the underlying `StubbyURLProtocol`
  ///     protocol class. To maintain any existing protocol classes specified by `URLSessionConfiguration.protocolClasses`, set this to `true`.
  ///   - url: ``URL`` to stub.
  ///   - response: Response to stub.
  /// - Returns: A new ``URLSession`` instance.
  public static func stubbed(
    configuration: URLSessionConfiguration = .ephemeral,
    maintainExistingProtocolClasses: Bool = false,
    url: URL,
    response: @escaping @Sendable (URLRequest) throws -> Result<StubbyResponse, Error>
  ) -> URLSession {
    stubbed(
      configuration: configuration,
      maintainExistingProtocolClasses: maintainExistingProtocolClasses,
      [
        .init(url: url, response: response)
      ]
    )
  }
}

// MARK: - Stub

public struct Stub: Sendable {

  // MARK: Lifecycle

  public init(
    url: URL,
    response: @escaping @Sendable (URLRequest) throws -> Result<StubbyResponse, Error>
  ) {
    self.url = url
    self.response = response
  }

  // MARK: Public

  public let url: URL
  public let response: @Sendable (URLRequest) throws -> Result<StubbyResponse, Error>

}

// MARK: - ResponseProvider

private actor StubResponseProvider: StubbyResponseProvider {

  // MARK: Internal

  static func registerStub(_ stub: Stub) {
    stubs.withLock { $0[stub.url] = stub }
  }

  static func respondsTo(request _: URLRequest) -> Bool {
    true
  }

  static func response(for request: URLRequest) throws -> Result<StubbyResponse, Error> {
    guard let url = request.url else {
      throw URLError(.badURL)
    }
    guard let stub = stubs.withLock({ $0[url] }) else {
      throw URLError(.unsupportedURL)
    }
    return try stub.response(request)
  }

  // MARK: Private

  private static let stubs: OSAllocatedUnfairLock<[URL: Stub]> = .init(initialState: [:])

}

extension URLSessionConfiguration {
  fileprivate func registerProtocolClass(
    _ protocolClass: AnyClass,
    maintainExistingProtocolClasses: Bool
  ) {
    URLProtocol.registerClass(protocolClass)
    var protocolClasses = [AnyClass]()
    if
      maintainExistingProtocolClasses,
      let existingProtocolClasses = self.protocolClasses
    {
      protocolClasses = existingProtocolClasses
    }
    protocolClasses.insert(protocolClass, at: 0)
    self.protocolClasses = protocolClasses
  }
}
