//
//  main.swift
//  calc
//
//  Created by Jesse Clark on 12/3/18.
//  Copyright © 2018 UTS. All rights reserved.
//
import Foundation

var args = ProcessInfo.processInfo.arguments
args.removeFirst() 

if args.isEmpty {
    print("Error: No expression provided.")
    exit(1)  
}

let calculator = Calculator()

let result = calculator.calculate(args: args)
print(result)

