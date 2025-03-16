//
//  Calculator.swift
//  calc
//
//  Created by Jacktator on 31/3/20.
//  Copyright © 2020 UTS. All rights reserved.
//

import Foundation

class Calculator {
    var currentResult = 0
    private let tokenizer = Tokenizer()
    private let parser = Parser()
    private let evaluator = Evaluator()
    
    func calculate(args: [String]) -> Int {
        do {
            let tokens = try tokenizer.tokenize(args)
            let postfix = parser.shuntingYard(tokens)
            return evaluator.evaluate(postfix)
        } catch let error as CalculationError {
            print("Error: \(error.message)")
            exit(error.exitCode)
        } catch {
            print("Unexpected error occurred.")
            exit(1)
        }
    }
}

enum CalculationError: Error {
    case invalidEquation(reason: String, exitCode: Int)
    
    var message: String {
        switch self {
        case .invalidEquation(let reason, _):
            return reason
        }
    }
    
    var exitCode: Int {
        switch self {
        case .invalidEquation(_, let exitCode):
            return exitCode
        }
    }
}

class Tokenizer {
    private let pattern = "^(?:[-+]?[0-9]+|[+\-x/%])$"
    
    func tokenize(_ equ: [String]) throws -> [String] {
        let validEquation = try validateEquation(equ)
        return validEquation.filter { isValidToken($0) }
    }
    
    private func isValidToken(_ equ: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: equ.utf16.count)
        return regex.firstMatch(in: equ, options: [], range: range) != nil
    }
    
    private func validateEquation(_ equ: [String]) throws -> [String] {
        if equ.isEmpty {
            throw CalculationError.invalidEquation(reason: "Equation cannot be empty.", exitCode: 2)
        }
        if let first = equ.first, let last = equ.last,
           let _ = Int(first.replacingOccurrences(of: "+", with: "")), 
           let _ = Int(last.replacingOccurrences(of: "+", with: "")) {
            return equ
        } else {
            throw CalculationError.invalidEquation(reason: "Equation incomplete or malformed.", exitCode: 3)
        }
    }
}

class Parser {
    func shuntingYard(_ equ: [String]) -> [String] {
        let precedence: [String: Int] = ["+": 1, "-": 1, "x": 2, "/": 2, "%": 2]
        var post: [String] = []
        var op: [String] = []
        
        for token in equ {
            if let _ = Int(token.replacingOccurrences(of: "+", with: "")) {
                post.append(token)
            } else {
                while let last = op.last, precedence[last] ?? 0 >= precedence[token] ?? 0 {
                    post.append(op.popLast()!)
                }
                op.append(token)
            }
        }
        
        while let last = op.popLast() {
            post.append(last)
        }
        
        return post
    }
}

class Evaluator {
    func evaluate(_ equ: [String]) -> Int {
        var eval: [Int] = []
        
        for token in equ {
            let processedToken = token.replacingOccurrences(of: "+", with: "")
            if let number = Int(processedToken) {
                eval.append(number)
            } else if eval.count >= 2 {
                let b = eval.removeLast()
                let a = eval.removeLast()
                
                switch token {
                case "+": eval.append(a + b)
                case "-": eval.append(a - b)
                case "x": eval.append(a * b)
                case "/": 
                    if b == 0 {
                        print("Error: Division by zero is not allowed.")
                        exit(4)
                    }
                    eval.append(a / b)
                case "%": 
                    if b == 0 {
                        print("Error: Modulo by zero is not allowed.")
                        exit(5)
                    }
                    eval.append(a % b)
                default: 
                    print("Error: Unknown operator '\(token)'.")
                    exit(6)
                }
            } else {
                print("Error: Insufficient operands for operator '\(token)'.")
                exit(7)
            }
        }
        
        return eval.last!
    }
}