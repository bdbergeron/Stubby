// Created by Brad Bergeron on 9/17/23.

import Foundation

// MARK: - StubbyResponse

/// A stubbed response.
public struct StubbyResponse {

  // MARK: Lifecycle

  /// Initialize a new `StubbyResponse` instance.
  /// - Parameters:
  ///   - urlResponse: The stubbed `URLResponse`.
  ///   - data: The stubbed `Data` returned by the response.
  ///   - cacheStoragePolicy: Control over whether or not this stubbed response can be cached.
  ///     Defaults to `URLCache.StoragePolicy.notAllowed`.
  public init(
    urlResponse: URLResponse,
    data: Data,
    cacheStoragePolicy: URLCache.StoragePolicy = .notAllowed,
  ) {
    self.urlResponse = urlResponse
    self.data = data
    self.cacheStoragePolicy = cacheStoragePolicy
  }

  // MARK: Internal

  enum Error: Swift.Error {
    case invalidHTTPURLResponse
  }

  let urlResponse: URLResponse
  let data: Data
  let cacheStoragePolicy: URLCache.StoragePolicy

}

extension StubbyResponse {
  /// Initialize a new `StubbyResponse` with an `HTTPURLResponse` instance.
  /// - Parameters:
  ///   - data: The stubbed `Data` returned by the response.
  ///   - url: The `URL` corresponding to the stubbed response.
  ///   - statusCode: HTTP status code for the stubbed response. Default is `200` (OK).
  ///   - httpVersion: HTTP version for the stubbed response. Default is "HTTP/1.1".
  ///   - headerFields: Optional response header fields.
  ///   - cacheStoragePolicy: Control over whether or not this stubbed response can be cached.
  ///     Defaults to `URLCache.StoragePolicy.notAllowed`.
  public init(
    data: Data,
    for url: URL,
    statusCode: Int = 200,
    httpVersion: String? = "HTTP/1.1",
    headerFields: [String : String]? = nil,
    cacheStoragePolicy: URLCache.StoragePolicy = .notAllowed,
  ) throws {
    guard
      let urlResponse = HTTPURLResponse(
        url: url,
        statusCode: statusCode,
        httpVersion: httpVersion,
        headerFields: headerFields,
      )
    else {
      throw Error.invalidHTTPURLResponse
    }
    self.init(
      urlResponse: urlResponse,
      data: data,
      cacheStoragePolicy: cacheStoragePolicy,
    )
  }
}

// MARK: - StubbyResponse.Error + CustomNSError

extension StubbyResponse.Error: LocalizedError, CustomNSError {
  var errorDescription: String? {
    switch self {
    case .invalidHTTPURLResponse:
      return "Failed to initialize an `HTTPURLResponse`."
    }
  }

  var errorUserInfo: [String : Any] {
    [
      NSLocalizedDescriptionKey: errorDescription as Any,
    ]
  }
}
