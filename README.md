# 🥸 Stubby
A little URLSession response stubbing library.

![build](https://github.com/bdbergeron/stubby/actions/workflows/build-and-test.yml/badge.svg)
[![codecov](https://codecov.io/gh/bdbergeron/Stubby/graph/badge.svg?token=vIOaloNoGB)](https://codecov.io/gh/bdbergeron/Stubby)

## Getting Started

Add Stubby to your project via Swift Package Manager:

```swift
.package(url: "https://github.com/bdbergeron/Stubby", from: "1.0.0"),
```

In your Tests folder, create an object that conforms to `StubbyResponseProvider`:

```swift
import Foundation
import Stubby
import XCTest

extension URL {
  static let repoURL = URL(string: "https://bdbergeron.github.io")!
  static let githubURL = URL(string: "https://github.com")!
}

struct SomeResponseProvider: StubbyResponseProvider {
  static func respondsTo(request: URLRequest) -> Bool {
    true
  }

  static func response(for request: URLRequest) throws -> Result<StubbyResponse, Error> {
    switch try XCTUnwrap(request.url) {
    case .repoURL:
      return try .success(.init(data: try XCTUnwrap("Hello, world!".data(using: .utf8)), for: .repoURL))
    default:
      return .failure(URLError(.unsupportedURL))
    }
  }
}
```

And now you can use your response provider in your tests:

```swift
import Stubby
import XCTest

final class StubbyTests: XCTestCase {
  func test_stubbedResponse_succeeds() async {
    let urlSession = URLSession.stubbed(responseProvider: SomeResponseProvider.self)
    let request = URLRequest(url: .repoURL)
    do {
      let (data, _) = try await urlSession.data(for: request)
      let string = String(data: data, encoding: .utf8)
      XCTAssertEqual(string, "Hello, world!")
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func test_stubbyResponse_failsWithUnsupportedURLError() async {
    let urlSession = URLSession.stubbed(responseProvider: SomeResponseProvider.self)
    let request = URLRequest(url: .githubURL)
    do {
      _ = try await urlSession.data(for: request)
      XCTFail("Should fail.")
    } catch let error as NSError {
      XCTAssertEqual(error.domain, URLError.errorDomain)
      let expectedError = URLError(.unsupportedURL)
      XCTAssertEqual(error.code, expectedError.errorCode)
      XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
}
```
