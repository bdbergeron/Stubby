// Created by Brad Bergeron on 9/22/23.

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - StubMacro

public struct StubMacro: DeclarationMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard
      let stubbedURLString = node.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue,
      URL(string: stubbedURLString) != nil
    else {
      context.addDiagnostics(from: StubDiagnostic.invalidURL, node: node.arguments)
      return []
    }

    guard let response = node.trailingClosure else {
      context.addDiagnostics(from: StubDiagnostic.missingResponse, node: node)
      return []
    }

    let classDecl = StructDeclSyntax(
      name: context.makeUniqueName("StubResponse"),
      inheritanceClause: InheritanceClauseSyntax {
        InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("StubbyResponseProvider")))
      },
      memberBlock: MemberBlockSyntax {
        "static let url = URL(string: \"\(raw: stubbedURLString)\")!"

        FunctionDeclSyntax(
          modifiers: DeclModifierListSyntax {
            DeclModifierSyntax(name: .keyword(.static))
          },
          name: .identifier("respondsTo"),
          signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax {
              FunctionParameterSyntax(
                firstName: .identifier("request"),
                type: IdentifierTypeSyntax(name: .identifier("URLRequest"))
              )
            },
            returnClause: ReturnClauseSyntax(type: IdentifierTypeSyntax(name: .identifier("Bool")))
          )
        ) {
          InfixOperatorExprSyntax(
            leftOperand: MemberAccessExprSyntax(
              base: DeclReferenceExprSyntax(baseName: .identifier("request")),
              name: .identifier("url")
            ),
            operator: BinaryOperatorExprSyntax(operator: .binaryOperator("==")),
            rightOperand: DeclReferenceExprSyntax(baseName: .identifier("url"))
          )
        }

        FunctionDeclSyntax(
          modifiers: DeclModifierListSyntax {
            DeclModifierSyntax(name: .keyword(.static))
          },
          name: .identifier("response"),
          signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax {
              FunctionParameterSyntax(
                firstName: .identifier("for"),
                secondName: .identifier("request"),
                type: IdentifierTypeSyntax(name: .identifier("URLRequest"))
              )
            },
            effectSpecifiers: FunctionEffectSpecifiersSyntax(throwsSpecifier: .keyword(.throws)),
            returnClause: ReturnClauseSyntax(
              type: IdentifierTypeSyntax(
                name: .identifier("Result"),
                genericArgumentClause: GenericArgumentClauseSyntax(
                  arguments: GenericArgumentListSyntax {
                    GenericArgumentSyntax(argument: IdentifierTypeSyntax(name: .identifier("StubbyResponse")))
                    GenericArgumentSyntax(argument: IdentifierTypeSyntax(name: .identifier("Error")))
                  }
                )
              )
            )
          )
        ) {
          response.statements
        }
      }
    )

    return [
      "#if DEBUG",
      DeclSyntax(classDecl),
      "\n#endif",
    ]
  }
}

// MARK: - StubDiagnostic

enum StubDiagnostic: String, Error, DiagnosticMessage {
  case invalidURL
  case missingResponse

  var message: String {
    switch self {
    case .invalidURL:
      "#Stub requires a valid URL."
    case .missingResponse:
      "#Stub requires a valid response of type `Result<StubbyResponse, Error>`."
    }
  }

  var diagnosticID: MessageID {
    MessageID(domain: "StubMacro", id: rawValue)
  }

  var severity: DiagnosticSeverity {
    .error
  }
}
