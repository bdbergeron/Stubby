// Created by Brad Bergeron on 9/21/23.

import Foundation
import Stubby

// MARK: - CatchallResponseProvider

struct CatchallResponseProvider: StubbyResponseProvider {
  static func respondsTo(request _: URLRequest) -> Bool {
    true
  }

  static func response(for _: URLRequest) throws -> Result<StubbyResponse, Error> {
    .failure(URLError(.unsupportedURL))
  }
}

// MARK: - GithubResponseProvider

struct GithubResponseProvider: StubbyResponseProvider {
  enum StubbedURL: URL, CaseIterable {
    case githubURL = "https://github.com"
    case repoURL = "https://github.com/bdbergeron/Stubby"
  }

  static func respondsTo(request: URLRequest) -> Bool {
    request.url.map(StubbedURL.contains(url:)) ?? false
  }

  static func response(for request: URLRequest) throws -> Result<StubbyResponse, Error> {
    switch StubbedURL(rawValue: request.url!) {
    case .repoURL:
      try .success(.init(
        data: "Hello, world!".data(using: .utf8)!,
        for: StubbedURL.repoURL.rawValue
      ))

    case .githubURL:
      try .success(.init(
        data: "Github".data(using: .utf8)!,
        for: StubbedURL.githubURL.rawValue
      ))

    default:
      .failure(URLError(.unsupportedURL))
    }
  }
}

// MARK: - AppleResponseProvider

struct AppleResponseProvider: StubbyResponseProvider {
  enum StubbedURL: URL, CaseIterable {
    case developers = "https://developers.apple.com"
  }

  static func respondsTo(request: URLRequest) -> Bool {
    request.url.map(StubbedURL.contains(url:)) ?? false
  }

  static func response(for request: URLRequest) throws -> Result<StubbyResponse, Error> {
    switch StubbedURL(rawValue: request.url!) {
    case .developers:
      try .success(.init(
        data: "Apple Developer".data(using: .utf8)!,
        for: StubbedURL.developers.rawValue
      ))

    default:
      .failure(URLError(.unsupportedURL))
    }
  }
}
