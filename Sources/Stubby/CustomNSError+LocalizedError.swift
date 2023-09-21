// Created by Brad Bergeron on 9/21/23.

import Foundation

extension CustomNSError where Self: LocalizedError {
  var errorUserInfo: [String : Any] {
    [
      NSLocalizedDescriptionKey: errorDescription as Any,
    ]
  }
}
