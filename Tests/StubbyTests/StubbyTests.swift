import Stubby
import XCTest

// MARK: - StubbyTests

final class StubbyTests: XCTestCase {
  func test_createStubbedURLSession() throws {
    let urlSession = URLSession.stubbed(responseProvider: GithubResponseProvider.self)
    let protocolClasses = try XCTUnwrap(urlSession.configuration.protocolClasses)
    XCTAssertTrue(protocolClasses.count == 1)
  }

  func test_createStubbedURLSession_maintainExistingProtocolClasses() throws {
    let urlSession = URLSession.stubbed(
      maintainExistingProtocolClasses: true,
      responseProvider: GithubResponseProvider.self)
    let protocolClasses = try XCTUnwrap(urlSession.configuration.protocolClasses)
    XCTAssertTrue(protocolClasses.count > 1)
  }

  func test_createStubbedURLSession_multipleResponseProviders() throws {
    let urlSession = URLSession.stubbed(responseProviders: GithubResponseProvider(), AppleResponseProvider())
    let protocolClasses = try XCTUnwrap(urlSession.configuration.protocolClasses)
    XCTAssertTrue(protocolClasses.count == 2)
  }

  func test_singleResponseProvider_response_failsWithUnsupportedURLError() async {
    let urlSession = URLSession.stubbed(responseProvider: CatchallResponseProvider.self)
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

  func test_singleResponseProvider_response_succeeds() async {
    let urlSession = URLSession.stubbed(responseProvider: GithubResponseProvider.self)
    let request = URLRequest(url: .repoURL)
    do {
      let (data, _) = try await urlSession.data(for: request)
      let string = String(data: data, encoding: .utf8)
      XCTAssertEqual(string, "Hello, world!")
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func test_multipleResponseProviders_response_succeeds() async throws {
    let urlSession = URLSession.stubbed(responseProviders: GithubResponseProvider(), AppleResponseProvider())
    let request = URLRequest(url: .appleDevelopersURL)
    let (data, _) = try await urlSession.data(for: request)
    let string = String(data: data, encoding: .utf8)
    XCTAssertEqual(string, "Apple Developer")
  }
}

// MARK: - URL

extension URL {
  static let repoURL: URL = "https://github.com/bdbergeron/Stubby"
  static let githubURL: URL = "https://github.com"
  static let appleDevelopersURL: URL = "https://developers.apple.com"
}
