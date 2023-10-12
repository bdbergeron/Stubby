// Created by Brad Bergeron on 9/17/23.

import Foundation

extension URLSession {
  /// Create a `URLSession` with stubbed request handlers.
  /// - Parameters:
  ///   - responseProvider: The type of ``StubbyResponseProvider`` to use for handling requests.
  ///   - configuration: An `URLSessionConfiguration` object to be used by the created `URLSession`.
  ///     Defaults to `URLSessionConfiguration.ephemeral`.
  ///   - maintainExistingProtocolClasses: By default, the created `URLSession` will utilize _only_ the underlying `StubbyURLProtocol`
  ///     protocol class. To maintain any existing protocol classes specified by `URLSessionConfiguration.protocolClasses`, set this to `true`.
  /// - Returns: A new ``URLSession`` instance.
  public static func stubbed<ResponseProvider: StubbyResponseProvider>(
    responseProvider: ResponseProvider.Type,
    configuration: URLSessionConfiguration = .ephemeral,
    maintainExistingProtocolClasses: Bool = false)
    -> URLSession
  {
    URLProtocol.registerClass(StubbyURLProtocol<ResponseProvider>.self)
    if
      maintainExistingProtocolClasses,
      var protocolClasses = configuration.protocolClasses
    {
      protocolClasses.append(StubbyURLProtocol<ResponseProvider>.self)
      configuration.protocolClasses = protocolClasses
    } else {
      configuration.protocolClasses = [StubbyURLProtocol<ResponseProvider>.self]
    }
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
    _ stubs: [Stub])
    -> URLSession
  {
    for stub in stubs {
      ResponseProvider.registerStub(stub)
    }
    return stubbed(
      responseProvider: ResponseProvider.self,
      configuration: configuration,
      maintainExistingProtocolClasses: maintainExistingProtocolClasses)
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
    response: @escaping (URLRequest) throws -> Result<StubbyResponse, Error>)
    -> URLSession
  {
    stubbed(
      configuration: configuration,
      maintainExistingProtocolClasses: maintainExistingProtocolClasses,
      [
        .init(url: url, response: response),
      ])
  }
}

// MARK: - Stub

public struct Stub {

  // MARK: Lifecycle

  public init(
    url: URL,
    response: @escaping (URLRequest) throws -> Result<StubbyResponse, Error>)
  {
    self.url = url
    self.response = response
  }

  // MARK: Public

  public let url: URL
  public let response: (URLRequest) throws -> Result<StubbyResponse, Error>

}

// MARK: - ResponseProvider

private struct ResponseProvider: StubbyResponseProvider {

  // MARK: Internal

  static func registerStub(_ stub: Stub) {
    stubs[stub.url] = stub
  }

  static func respondsTo(request: URLRequest) -> Bool {
    true
  }

  static func response(for request: URLRequest) throws -> Result<StubbyResponse, Error> {
    guard let url = request.url else {
      throw URLError(.badURL)
    }
    guard let stub = stubs[url] else {
      throw URLError(.unsupportedURL)
    }
    return try stub.response(request)
  }

  // MARK: Private

  private static var stubs = [URL: Stub]()

}
