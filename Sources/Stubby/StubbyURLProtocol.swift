// Created by Brad Bergeron on 9/17/23.

import Foundation

// MARK: - StubbyResponseProvider

/// A type that provides Stubby responses.
public protocol StubbyResponseProvider {
  /// Determine whether or not this response provider can respond to the incoming `URLRequest`.
  /// - Parameter request: The incoming `URLRequest`.
  /// - Returns: If this response provider can handle the incoming request, return `true`. Otherwise, return `false`.
  static func respondsTo(request: URLRequest) -> Bool
  
  /// Provide the response for the incoming `URLRequest`.
  /// - Parameter request: The incoming `URLRequest`.
  /// - Returns: A `Result` containing either a ``StubbyResponse`` or an `Error`.
  static func response(for request: URLRequest) throws -> Result<StubbyResponse, Error>
}

// MARK: - StubbyURLProtocol

final class StubbyURLProtocol<ResponseProvider: StubbyResponseProvider>: URLProtocol {

  // MARK: Internal

  override class func canInit(with request: URLRequest) -> Bool {
    ResponseProvider.respondsTo(request: request)
  }

  override class func canInit(with task: URLSessionTask) -> Bool {
    guard let request = task.originalRequest else { return false }
    return canInit(with: request)
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    guard let client else { return }
    defer { client.urlProtocolDidFinishLoading(self) }
    do {
      let response = try ResponseProvider.response(for: request)
      switch response {
      case .success(let response):
        client.urlProtocol(self, didReceive: response.urlResponse, cacheStoragePolicy: response.cacheStoragePolicy)
        client.urlProtocol(self, didLoad: response.data)
      case .failure(let error):
        throw error
      }
    } catch {
      client.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() { }

}
