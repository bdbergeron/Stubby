// Created by Brad Bergeron on 9/17/23.

import Foundation

extension URLSession {
  /// Create a ``URLSession`` that leverages ``StubbyResponder`` for stubbing request handlers.
  /// - Parameter configuration: An ``URLSessionConfiguration`` object to be used by the created ``URLSession``.
  /// - Parameter responder: The type of ``StubbyResponder`` to use for handling requests.
  /// - Returns: A new ``URLSession`` instance.
  public static func stubbed<Responder: StubbyResponder>(
    configuration: URLSessionConfiguration = .ephemeral,
    responder: Responder.Type)
    -> URLSession
  {
    configuration.protocolClasses = (configuration.protocolClasses ?? []) + [StubbyURLProtocol<Responder>.self]
    let urlSession = URLSession(configuration: configuration)
    URLProtocol.registerClass(StubbyURLProtocol<Responder>.self)
    return urlSession
  }
}
