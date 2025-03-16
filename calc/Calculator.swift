//
//  Calculator.swift
//  calc
//
//  Created by Jacktator on 31/3/20.
//  Copyright © 2020 UTS. All rights reserved.
//

import Foundation

class Calculator {
    func calculate(args: [String]) -> Any {
        let tokenizer = Tokenizer()
        let parser = Parser()
        let evaluator = Evaluator()
        
        let tokens = tokenizer.tokenize(args)
        let postfix = parser.shuntingYard(tokens)
        let result = evaluator.evaluate(postfix)
        
        return result
    }
}

class Tokenizer {
    
    private let pattern = "^(?:[+-]?[0-9]+|[+\\-x/%])$"
    
    func tokenize(_ equ: [String]) -> [String] {
        var token = validEquTest(equ)
        var i = 0
        while i < token.count {
            if let _ = formErrorTest(token[i]) {
                i += 1
            }
        }
        return token
    }
    
    private func validEquTest(_ equ: [String]) -> [String] {
        if let first = equ.first, let last = equ.last,
           let _ = Int(first), let _ = Int(last) {
            return equ
        } else {
            print("Invalid: Equation incomplete")
            exit(1)
        }
    }

    private func formErrorTest(_ equ: String) -> String? {
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: equ.utf16.count)
        
        if regex.firstMatch(in: equ, options: [], range: range) != nil {
            return equ
        } else if equ.contains(" ") {
            print("Invalid: Input contains spaces.")
            exit(1)
        } else if !equ.allSatisfy({ $0.isNumber || "+-x/%".contains($0) }) {
            print("Invalid: Contains unsupported characters.")
            exit(1)
        } else if "+/%".contains(equ.first!) {
            print("Invalid: '\(equ.first!)' cannot be at the start.")
            exit(1)
        } else if equ.filter({ $0 == "-" }).count > 1 && !equ.hasPrefix("-") {
            print("Invalid: Misplaced '-' detected.")
            exit(1)
        } else {
            print("Invalid: Does not match any allowed format.")
            exit(1)
        }
    }
}

class Parser {
    
    private let pattern = "^(?:[+-]?[0-9]+|[+\\-x/%])$"
    
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

    func shuntingYard(_ equ: [String]) -> [String] {
        let infix = equ
        var post: [String] = []
        var op: [String] = []
        var i = 0
        while i < infix.count {
            let token = infix[i]
            
            if let _ = Int(token) {
                post.append(token)
            } else {
                while let last = op.last, precedence(last) >= precedence(token) {
                    post.append(op.popLast()!)
                }
                op.append(token)
            }
            
            i += 1
        }
        
        while let last = op.popLast() {
            post.append(last)
        }
        
        return post
    }
}

class Evaluator {
    
    func evaluate(_ equ: [String]) -> Any {
        var eval: [Int] = []
        var temp = 0
        var i = 0
        while i < equ.count {
            if let number = Int(equ[i]) {
                eval.append(number)
            } else {
                switch equ[i] {
                case "+":
                    temp = eval[eval.count - 2] + eval[eval.count - 1]
                    eval.removeLast(2)
                    eval.append(temp)
                case "-":
                    temp = eval[eval.count - 2] - eval[eval.count - 1]
                    eval.removeLast(2)
                    eval.append(temp)
                case "x":
                    temp = eval[eval.count - 2] * eval[eval.count - 1]
                    eval.removeLast(2)
                    eval.append(temp)
                case "/":
                    if eval[eval.count - 1] == 0 {
                        print("Error: Division by zero.")
                        exit(2)  
                    }
                    temp = eval[eval.count - 2] / eval[eval.count - 1]
                    eval.removeLast(2)
                    eval.append(temp)
                case "%":
                    if eval[eval.count - 1] == 0 {
                        print("Error: Division by zero.")
                        exit(2)  
                    }
                    temp = eval[eval.count - 2] % eval[eval.count - 1]
                    eval.removeLast(2)
                    eval.append(temp)
                default:
                    break
                }
            }
            i += 1
        }

        return eval.last!
    }
}