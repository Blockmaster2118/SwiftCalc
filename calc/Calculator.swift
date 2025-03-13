//
//  Calculator.swift
//  calc
//
//  Created by Jacktator on 31/3/20.
//  Copyright © 2020 UTS. All rights reserved.
//

import Foundation

class Calculator {
    
    /// For multi-step calculation, it's helpful to persist existing result
    var currentResult = 0;
    
    /// Perform Addition
    ///
    /// - Author: Jacktator
    /// - Parameters:
    ///   - no1: First number
    ///   - no2: Second number
    /// - Returns: The addition result
    ///
    /// - Warning: The result may yield Int overflow.
    /// - SeeAlso: https://developer.apple.com/documentation/swift/int/2884663-addingreportingoverflow
    func add(no1: Int, no2: Int) -> Int {
        return no1 + no2;
    }
    
    func calculate(args: [String]) -> String {
        let result = String((evaluate(args)));
        return(result)
    }
    
    let pattern = "^(?:-?[0-9]+|\\[-?[0-9]+|-?[0-9]+\\]|[+\\-x/%])$"

    func precedence(_ op: String) -> Int {
        switch op {
        case "+", "-":
            return 1
        case "x", "/", "%":
            return 2
        default:
            return 0
        }
    }

    func formErrorTest(_ equ: String) -> String? {
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: equ.utf16.count)
        
        if regex.firstMatch(in: equ, options: [], range: range) != nil {
            return equ
        } else if equ.contains(" ") {
            print("Invalid: Input contains spaces.")
            exit(0)
        } else if !equ.allSatisfy({ $0.isNumber || "+-x/%[]".contains($0) }) {
            print("Invalid: Contains unsupported characters.")
            exit(0)
        } else if equ.hasPrefix("[") && equ.hasSuffix("]") {
            print("Invalid: Cannot have both '[' and ']' at the same time.")
            exit(0)
        } else if equ.dropFirst().contains(where: { "+-x/%".contains($0) }) && equ.contains(where: { $0.isNumber }) {
            print("Invalid: Cannot mix numbers and operators.")
            exit(0)
        } else if "+/%".contains(equ.first!) {
            print("Invalid: '\(equ.first!)' cannot be at the start.")
            exit(0)
        } else if equ.filter({ $0 == "-" }).count > 1 && !equ.hasPrefix("[-") && !equ.hasPrefix("-") {
            print("Invalid: Misplaced '-' detected.")
            exit(0)
        } else {
            print("Invalid: Does not match any allowed format.")
            exit(0)
        }
    }

    func validEquTest(_ equ: [String]) -> [String] {
        if let first = equ.first, let last = equ.last,
        let _ = Double(first), let _ = Double(last) {
            return equ
        } else {
            print("Invalid: Equation incomplete")
            exit(0)
        }
    }

    func tokenize(_ equ: [String]) -> [String] {
        var token = validEquTest(equ)
        var i = 0
        while i < token.count {
            if let test = formErrorTest(token[i]) {
                if test.hasPrefix("[") && !test.hasSuffix("]") {
                    token[i] = String(test.dropFirst())
                    token.insert("[", at: i)
                    i += 1
                } else if test.hasSuffix("]") && !test.hasPrefix("[") {
                    token[i] = String(test.dropLast())
                    token.insert("]", at: i + 1)
                    i += 2
                } else {
                    i += 1
                }
            }
        }
        return token
    }

    func shuntingYard(_ equ: [String]) -> [String] {
        var equ = tokenize(equ)
        var infix = equ
        print("infix: " + infix.joined() + "\n")
        var post: [String] = []
        var op: [String] = []
        var i = 0
        while i < infix.count {
            let token = infix[i]
            
            if let _ = Double(token) {
                post.append(token)
            } else if token == "[" {
                op.append(token)
            } else if token == "]" {
                while let last = op.last, last != "[" {
                    post.append(op.popLast()!)
                }
                op.popLast()
            } else {
                while let last = op.last, last != "[" && precedence(last) >= precedence(token) {
                    post.append(op.popLast()!)
                }
                op.append(token)
            }
            
            i += 1
            print(" output: " + post.joined())
            print(" stack: " + op.joined() + "\n")
        }
        
        while let last = op.popLast() {
            post.append(last)
        }

        print("postfix: " + post.joined() + "\n")
        
        return post
    }

    func evaluate(_ equ: [String]) -> Any {
        let equ = shuntingYard(equ)
        var eval: [Double] = []
        var temp = 0.0
        var i = 0
        while i < equ.count {
            if let number = Double(equ[i]) {
                eval.append(number)
            } else {
                switch equ[i] {
                case "+":
                    temp = eval.removeLast(2).reduce(0, +)
                    eval.append(temp)
                case "-":
                    temp = eval.removeLast(2).reduce(-)
                    eval.append(temp)
                case "x":
                    temp = eval.removeLast(2).reduce(*)
                    eval.append(temp)
                case "/":
                    temp = eval.removeLast(2).reduce(/)
                    eval.append(temp)
                case "%":
                    temp = eval.removeLast(2).reduce(%)
                    eval.append(temp)
                default:
                    break
                }
            }
            i += 1
        }

        let result = eval.last!
        if result.isInteger {
            return Int(result)
        } else {
            return result
        }
    }
}
