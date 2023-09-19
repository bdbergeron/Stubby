// Created by Brad Bergeron on 9/17/23.

import Foundation
import XCTest

// MARK: - StubbyResponseProvider

public protocol StubbyResponseProvider {
  static func respondsTo(request: URLRequest) -> Bool
  static func response(for request: URLRequest) throws -> Result<StubbyResponse, Error>
}

// MARK: - StubbyURLProtocol

final class StubbyURLProtocol<ResponseProvider: StubbyResponseProvider>: URLProtocol {

  // MARK: Internal

  override class func canInit(with request: URLRequest) -> Bool {
    ResponseProvider.respondsTo(request: request)
  }

  override class func canInit(with task: URLSessionTask) -> Bool {
    guard let request = task.currentRequest else { return false }
    return ResponseProvider.respondsTo(request: request)
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
        client.urlProtocol(self, didFailWithError: error)
      }
    } catch {
      client.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() { }

}
