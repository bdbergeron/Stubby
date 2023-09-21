// Created by Brad Bergeron on 9/17/23.

import Foundation

extension URLSession {
  /// Create a `URLSession` with stubbed request handlers.
  /// - Parameter responseProvider: The type of ``StubbyResponseProvider`` to use for handling requests.
  /// - Parameter configuration: An `URLSessionConfiguration` object to be used by the created `URLSession`.
  ///   Defaults to `URLSessionConfiguration.ephemeral`.
  /// - Parameter maintainExistingProtocolClasses: By default, the created `URLSession` will utilize _only_ the underlying
  ///   `StubbyURLProtocol` protocol class. To maintain any existing protocol classes specified by `URLSessionConfiguration.protocolClasses`,
  ///   set this to `true`.
  /// - Returns: A new ``URLSession`` instance.
  public static func stubbed<ResponseProvider: StubbyResponseProvider>(
    responseProvider: ResponseProvider.Type,
    configuration: URLSessionConfiguration = .ephemeral,
    maintainExistingProtocolClasses: Bool = true)
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
}
