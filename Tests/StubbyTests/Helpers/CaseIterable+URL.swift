// Created by Brad Bergeron on 9/21/23.

import Foundation

// MARK: - CaseIterable + URL

extension CaseIterable where Self: RawRepresentable, RawValue == URL {
  static var allURLs: [URL] { allCases.map(\.rawValue) }

  static func contains(url: URL) -> Bool {
    allURLs.contains(url)
  }
}
