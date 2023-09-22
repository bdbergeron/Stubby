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
    let urlSession = URLSession.stubbed(responseProvider: TestResponseProvider.self)
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
    let urlSession = URLSession.stubbed(responseProvider: TestResponseProvider.self)
    let request = URLRequest(url: .repoURL)
    do {
      let (data, _) = try await urlSession.data(for: request)
      let string = String(data: data, encoding: .utf8)
      XCTAssertEqual(string, "Hello, world!")
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
