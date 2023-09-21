import XCTest

@testable import Stubby

final class StubbyTests: XCTestCase {
  func test_createStubbedURLSession() throws {
    let urlSession = URLSession.stubbed(responseProvider: TestStubbyResponseProvider.self)
    let protocolClasses = try XCTUnwrap(urlSession.configuration.protocolClasses)
    XCTAssertTrue(protocolClasses.count > 1)
  }

  func test_createStubbedURLSession_overrideProtocolClasses() throws {
    let urlSession = URLSession.stubbed(
      responseProvider: TestStubbyResponseProvider.self,
      maintainExistingProtocolClasses: false)
    let protocolClasses = try XCTUnwrap(urlSession.configuration.protocolClasses)
    XCTAssertTrue(protocolClasses.count == 1)
  }

  func test_stubbyResponse_failsWithNoStubResponseError() async {
    let urlSession = URLSession.stubbed(
      responseProvider: TestStubbyResponseProvider.self,
      maintainExistingProtocolClasses: false)
    let request = URLRequest(url: "https://www.example.com")
    do {
      _ = try await urlSession.data(for: request)
      XCTFail("Should fail.")
    } catch let error as NSError {
      XCTAssertEqual(error.domain, TestStubbyResponseProvider.Error.errorDomain)
      let expectedError = TestStubbyResponseProvider.Error.noStubbedResponse(request)
      XCTAssertEqual(error.code, expectedError.errorCode)
      XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func test_stubbyResponse_succeeds() async {
    let urlSession = URLSession.stubbed(
      responseProvider: TestStubbyResponseProvider.self,
      maintainExistingProtocolClasses: false)
    let request = URLRequest(url: "https://bdbergeron.github.io")
    do {
      let (data, _) = try await urlSession.data(for: request)
      let string = String(data: data, encoding: .utf8)
      XCTAssertEqual(string, "Hello, world!")
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
}
