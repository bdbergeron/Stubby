// Created by Brad Bergeron on 9/22/23.

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct StubbyMacrosPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    StubMacro.self,
  ]
}
