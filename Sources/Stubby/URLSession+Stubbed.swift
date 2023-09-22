// Created by Brad Bergeron on 9/17/23.

import Foundation

extension URLSession {
  /// Create a `URLSession` with stubbed request handlers.
  /// - Parameters:
  ///   - configuration: An `URLSessionConfiguration` object to be used by the created `URLSession`.
  ///     Defaults to `URLSessionConfiguration.ephemeral`.
  ///   - maintainExistingProtocolClasses: By default, the created `URLSession` will utilize _only_ the underlying `StubbyURLProtocol`
  ///     protocol class. To maintain any existing protocol classes specified by `URLSessionConfiguration.protocolClasses`, set this to `true`.
  ///   - responseProvider: The type of ``StubbyResponseProvider`` to use for handling requests.
  /// - Returns: A new ``URLSession`` instance.
  @available(*, deprecated, message: "Prefer stubbed(configuration:maintainExistingProtocolClasses:responseProviders:).")
  public static func stubbed<ResponseProvider: StubbyResponseProvider>(
    configuration: URLSessionConfiguration = .ephemeral,
    maintainExistingProtocolClasses: Bool = false,
    responseProvider: ResponseProvider.Type)
    -> URLSession
  {
    configuration.registerProtocolClass(
      StubbyURLProtocol<ResponseProvider>.self,
      maintainExistingProtocolClasses: maintainExistingProtocolClasses)
    return URLSession(configuration: configuration)
  }
  
  /// Create a `URLSession` with stubbed request handlers.
  /// - Parameters:
  ///   - configuration: An `URLSessionConfiguration` object to be used by the created `URLSession`.
  ///     Defaults to `URLSessionConfiguration.ephemeral`.
  ///   - maintainExistingProtocolClasses: By default, the created `URLSession` will utilize _only_ the underlying `StubbyURLProtocol`
  ///     protocol class. To maintain any existing protocol classes specified by `URLSessionConfiguration.protocolClasses`, set this to `true`.
  ///   - responseProviders: A list of ``StubbyResponseProvider`` classes  to use for handling requests.
  /// - Returns: A new ``URLSession`` instance.
  public static func stubbed<each ResponseProvider: StubbyResponseProvider>(
    configuration: URLSessionConfiguration = .ephemeral,
    maintainExistingProtocolClasses: Bool = false,
    responseProviders: repeat each ResponseProvider)
    -> URLSession
  {
    if !maintainExistingProtocolClasses {
      configuration.protocolClasses = []
    }
    repeat configuration.registerProtocolClass(
      StubbyURLProtocol<each ResponseProvider>.self,
      maintainExistingProtocolClasses: true)
    return URLSession(configuration: configuration)
  }
}

extension URLSessionConfiguration {
  fileprivate func registerProtocolClass(
    _ protocolClass: AnyClass,
    maintainExistingProtocolClasses: Bool)
  {
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
