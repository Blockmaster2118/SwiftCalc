//
//  Calculator.swift
//  calc
//
//  Created by Rohan Gupta 
//

import Foundation

class Calculator {
    // Method to calculate the result from the input
    func calculate(args: [String]) -> Any {
        let tokenizer = Tokenizer()
        let parser = Parser()
        let evaluator = Evaluator()
        
        let tokens = tokenizer.tokenize(args) // Tokenize the input into individual valid components (numbers, operators)
        let postfix = parser.shuntingYard(tokens)  // Convert the infix tokens to postfix notation
        let result = evaluator.evaluate(postfix) // Evaluate the postfix expression and return the result
        
        return result
    }
}

class Tokenizer {
    
    private let operators = "+-x/%"  // String containing all valid operators (Note: This exists for input testing, operator precedence is handled when parsing)
    private let pattern = "^(?:[+-]?[0-9]+|[+\\-x/%])$"  // Regex pattern to match valid inputs
    
    // Method to error test input
    func tokenize(_ equ: [String]) -> [String] {
        let token = equ
        var i = 0
        while i < token.count {
            if let _ = formErrorTest(token[i]) { //Validate each token
                i += 1
            }
        }
        return validEquTest(token) // Ensure the overall equation is valid
    }
    
    // Method to ensure the input is a valid equation
    private func validEquTest(_ equ: [String]) -> [String] {
        if let first = equ.first, let last = equ.last,
           let _ = Int(first), let _ = Int(last) {
            
            for i in 0..<equ.count - 1 {
                // Check for consecutive numbers without operators in between
                if let _ = Int(equ[i]), let _ = Int(equ[i + 1]) {
                    print("Invaid: Missing operator between numbers \(equ[i]) and \(equ[i + 1]).")
                    exit(1)
                }
                
                // Check for consecutive operators
                if operators.contains(equ[i]) && operators.contains(equ[i + 1]) {
                    print("Invaid: Two consecutive operators between \(equ[i]) and \(equ[i + 1]).")
                    exit(1)
                }
            }
            return equ
        } else {
            print("Invalid: Equation incomplete")
            exit(1)
        }
    }

    // Method to ensure that each element in the equation is valid
    private func formErrorTest(_ equ: String) -> String? {
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: equ.utf16.count)
        
        if regex.firstMatch(in: equ, options: [], range: range) != nil {
            return equ
        } else if equ.contains(" ") {
            print("Invalid: Input contains spaces.")
            exit(1)
        } else if !equ.allSatisfy({ $0.isNumber || operators.contains($0) }) {
            print("Invalid: Contains unsupported characters.")
            exit(1)
        } else if operators.contains(equ.last!) {
            print("Invalid: '\(equ.last!)' cannot be at the end of a number.")
            exit(1)
        } else if operators.contains(equ.first!) {
            print("Invalid: '\(equ.first!)' cannot be at the start of a number.")
            exit(1)
        } else {
            print("Invalid: Does not match any allowed format.")
            exit(1)
        }
    }
}

class Parser {
    
    // Method that defines and returns the precedence of each operator
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

    // Method that parses the inputed equation from infix notation to postfix notation using the Shunting Yard algorithm, which handles operator precedence
    func shuntingYard(_ equ: [String]) -> [String] {
        let infix = equ
        var post: [String] = [] // Postfix notation will be stored here
        var op: [String] = [] // Operator stack used during the conversion process
        var i = 0
        while i < infix.count {
            let token = infix[i]
            
            if let _ = Int(token) { // If the token is a number, add it directly to the postfix equation
                post.append(token)
            } else { // If it's an operator, process it based on precedence
                while let last = op.last, precedence(last) >= precedence(token) {
                    post.append(op.popLast()!) // Pop operators with higher or equal precedence
                }
                op.append(token) // Add the current operator to the stack
            }
            
            i += 1
        }
        
        // Append any remaining operators in the stack to the postfix equation
        while let last = op.popLast() {
            post.append(last)
        }
        
        return post
    }
}

class Evaluator {
    
    // Method that evaluates the postfix equation
    func evaluate(_ equ: [String]) -> Any {
        var eval: [Int] = [] // Stack used for evaluation
        var temp = 0
        var i = 0
        while i < equ.count {
            if let number = Int(equ[i]) { // If the token is a number, push it to the stack
                eval.append(number)
            } else {
                switch equ[i] { // If it's an operator, pop the necessary operands and apply the operation
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
                        exit(2)  // Handle division by zero
                    }
                    temp = eval[eval.count - 2] / eval[eval.count - 1]
                    eval.removeLast(2)
                    eval.append(temp)
                case "%":
                    if eval[eval.count - 1] == 0 {
                        print("Error: Division by zero.")
                        exit(2)  // Handle modulo by zero
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

        return eval.last! // Return the final result
    }
}
