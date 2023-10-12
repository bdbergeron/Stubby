import Stubby
import XCTest

// MARK: - StubbyTests

final class StubbyTests: XCTestCase {
  func test_createStubbedURLSession() throws {
    let urlSession = URLSession.stubbed(responseProvider: TestResponseProvider.self)
    let protocolClasses = try XCTUnwrap(urlSession.configuration.protocolClasses)
    XCTAssertTrue(protocolClasses.count == 1)
  }

  func test_createStubbedURLSession_maintainExistingProtocolClasses() throws {
    let urlSession = URLSession.stubbed(
      responseProvider: TestResponseProvider.self,
      maintainExistingProtocolClasses: true)
    let protocolClasses = try XCTUnwrap(urlSession.configuration.protocolClasses)
    XCTAssertTrue(protocolClasses.count > 1)
  }

  func test_stubbyResponse_failsWithUnsupportedURLError() async {
    let urlSession = URLSession.stubbed(url: .githubURL) { _ in
      .failure(URLError(.unsupportedURL))
    }
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

  func test_stubbyResponse_succeeds() async {
    let urlSession = URLSession.stubbed(url: .repoURL) { request in
      try .success(StubbyResponse(
        data: XCTUnwrap("Hello, world!".data(using: .utf8)),
        for: XCTUnwrap(request.url)))
    }
    let request = URLRequest(url: .repoURL)
    do {
      let (data, _) = try await urlSession.data(for: request)
      let string = String(data: data, encoding: .utf8)
      XCTAssertEqual(string, "Hello, world!")
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func test_stubbyResponse_multipleStubs() async throws {
    let githubExpectation = expectation(description: "github")
    let repoExpectation = expectation(description: "repo")
    let urlSession = URLSession.stubbed([
      Stub(url: .githubURL) { request in
        defer { githubExpectation.fulfill() }
        return try .success(StubbyResponse(
          data: XCTUnwrap("Github".data(using: .utf8)),
          for: XCTUnwrap(request.url)))
      },
      Stub(url: .repoURL) { request in
        defer { repoExpectation.fulfill() }
        return try .success(StubbyResponse(
          data: XCTUnwrap("Hello, world!".data(using: .utf8)),
          for: XCTUnwrap(request.url)))
      },
    ])
    async let requests = [
      urlSession.data(from: .githubURL),
      urlSession.data(from: .repoURL),
    ]
    let responses = try await requests
    await fulfillment(of: [githubExpectation, repoExpectation], timeout: 1.0)
    XCTAssertEqual(responses.count, 2)
    let (githubData, _) = responses[0]
    let (repoData, _) = responses[1]
    XCTAssertEqual(String(data: githubData, encoding: .utf8), "Github")
    XCTAssertEqual(String(data: repoData, encoding: .utf8), "Hello, world!")
    do {
      _ = try await urlSession.data(from: URL(string: "https://bradbergeron.com")!)
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

// MARK: - URL

extension URL {
  static let repoURL = URL(string: "https://bdbergeron.github.io")!
  static let githubURL = URL(string: "https://github.com")!
}
