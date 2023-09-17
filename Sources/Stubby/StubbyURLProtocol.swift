// Created by Brad Bergeron on 9/17/23.

import Foundation
import XCTest

// MARK: - StubbyResponder

public protocol StubbyResponder {
  static func response(for request: URLRequest) throws -> Result<StubbyResponse, Error>
}

// MARK: - StubbyURLProtocol

final class StubbyURLProtocol<Responder: StubbyResponder>: URLProtocol {

  // MARK: Internal

  override class func canInit(with _: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    guard let client else { return }
    defer { client.urlProtocolDidFinishLoading(self) }
    do {
      let response = try Responder.response(for: request)
      switch response {
      case .success(let response):
        client.urlProtocol(self, didReceive: response.urlResponse, cacheStoragePolicy: response.cacheStoragePolicy)
        client.urlProtocol(self, didLoad: response.data)
      case .failure(let error):
        client.urlProtocol(self, didFailWithError: error)
      }
    } catch {
      client.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() { }

}
