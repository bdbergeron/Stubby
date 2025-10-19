// Created by Brad Bergeron on 9/22/23.

import Foundation
import Stubby


/*
 #Stub("https://github.com/bdbergeron/Stubby") { request in
 try .success(StubbyResponse(data: XCTUnwrap("Hello, world!".data(using: .utf8)), for: XCTUnwrap(request.url)))
 }

 #Stub("https://github.com") { _ in
 .failure(URLError(.unsupportedURL))
 }
 */

@freestanding(declaration)
public macro Stub(
  _ urlString: StaticString,
  response: (URLRequest) throws -> Result<StubbyResponse, Error>)
  = #externalMacro(module: "StubbyMacrosPlugin", type: "StubMacro")
