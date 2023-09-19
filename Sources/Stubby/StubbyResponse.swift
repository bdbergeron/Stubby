// Created by Brad Bergeron on 9/17/23.

import Foundation
import XCTest

// MARK: - StubbyResponse

public struct StubbyResponse {

  // MARK: Lifecycle

  public init(
    urlResponse: URLResponse,
    data: Data,
    cacheStoragePolicy: URLCache.StoragePolicy = .notAllowed)
  {
    self.urlResponse = urlResponse
    self.data = data
    self.cacheStoragePolicy = cacheStoragePolicy
  }

  // MARK: Internal

  let urlResponse: URLResponse
  let data: Data
  let cacheStoragePolicy: URLCache.StoragePolicy

}

extension StubbyResponse {
  public init(
    data: Data,
    for url: URL,
    statusCode: Int = 200,
    httpVersion: String? = "HTTP/1.1",
    headerFields: [String : String]? = nil,
    cacheStoragePolicy: URLCache.StoragePolicy = .notAllowed)
    throws
  {
    let urlResponse = HTTPURLResponse(
      url: url,
      statusCode: statusCode,
      httpVersion: httpVersion,
      headerFields: headerFields)
    self.init(
      urlResponse: try XCTUnwrap(urlResponse),
      data: data,
      cacheStoragePolicy: cacheStoragePolicy)
  }
}
