//
//  parserCalculation.swift
//  speechRegocnitionCalculator
//
//  Created by Emir haktan Ozturk on 27/07/2017.
//  Copyright © 2017 emirhaktan. All rights reserved.
//

import Foundation
//
//  Parser.swift
//  speechRegocnitionCalculator
//
//  Created by Emir haktan Ozturk on 25/07/2017.
//  Copyright © 2017 emirhaktan. All rights reserved.
//

class Stack {
    
    var selfvalue: [String] = []
    var peek: String {
        get {
            if selfvalue.count != 0 {
                return selfvalue[selfvalue.count-1]
            } else {
                return ""
            }
        }
    }
    var empty: Bool {
        get {
            return selfvalue.count == 0
        }
    }
    
    func push(value: String) {
        selfvalue.append(value)
    }
    
    func pop() -> String {
        var temp = String()
        if selfvalue.count != 0 {
            temp = selfvalue[selfvalue.count-1]
            selfvalue.remove(at: selfvalue.count-1)
        } else if selfvalue.count == 0 {
            temp = ""
        }
        return temp
    }
    
}

extension String {
    
    var precedence: Int {
        get {
            switch self {
            case "+":
                return 1
            case "-":
                return 1
            case "×":
                return 0
            case "÷":
                return 0
            default:
                return 100
            }
        }
    }
    
    var isOperator: Bool {
        get {
            return ("+-×÷" as NSString).contains(self)
        }
    }
    
    var isNumber: Bool {
        get {
            return !isOperator && self != "(" && self != ")"
        }
    }
    
}

class infixparser {
    
    func bracketEngine(expression: String) -> String {
        
        //PARSE, THEN SOLVE.
        
        func bracketParsing(exp: String) -> [String] {
            var finalStrings = [""]
            for (_, tok) in exp.characters.enumerated() {
                let tokAsString = "\(tok)"
                if tokAsString == "(" {
                    finalStrings.append(tokAsString)
                } else if !finalStrings[finalStrings.count-1].characters.contains(")") && finalStrings[finalStrings.count-1].characters.contains("(") {
                    finalStrings[finalStrings.count-1] += tokAsString
                }
            }
            finalStrings.remove(at: 0)
            return finalStrings
        }
        
        func bracketSolving(brackets: [String]) -> String {
            var finalString = expression
            for i in brackets {
                let result = solve(expression: i.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: ""))
                finalString = finalString.replacingOccurrences(of: i, with: "\(result)")
            }
            return finalString
        }
        
        return bracketSolving(brackets: bracketParsing(exp: expression))
        
    }
    
    func solve( expression: String) -> Double? {
        
        var expression = expression
        expression = expression.characters.contains("(") ? bracketEngine(expression: expression) : expression
        let operatorStack = Stack()
        let operandStack = Stack()
        let tokens = expression.components(separatedBy: " ")
        
        for (index, token) in tokens.enumerated() {
            
            _ = "\(token) at \(index)"
            
            if token.isNumber {
                operandStack.push(value: token)
            }
            
            if token.isOperator {
                while operatorStack.peek.precedence <= token.precedence {
                    if !operatorStack.empty {
                        var res : Double = 0
                        switch operatorStack.peek {
                        case "+":
                            res = Double(operandStack.pop())! + Double(operandStack.pop())!
                        case "-":
                            res = Double(operandStack.selfvalue[operandStack.selfvalue.count-2])! - Double(operandStack.pop())!
                            _ = operandStack.pop()
                        case "×":
                            res = Double(operandStack.pop())! * Double(operandStack.pop())!
                        case "÷":
                            res = Double(Double(operandStack.selfvalue[operandStack.selfvalue.count-2])! / Double(operandStack.pop())!)
                            _ = operandStack.pop()
                        default:
                            res = 0
                        }
                        _ = "\(res) at \(index)"
                        _ = operatorStack.pop()
                        operandStack.push(value: "\(res)")
                    }
                }
                operatorStack.push(value: token)
            }
        }
        
        if operatorStack.empty{
            return nil
        }
        
        while !operatorStack.empty {
            var res : Double = 0
            switch operatorStack.peek {
            case "+":
                res = Double(operandStack.pop())! + Double(operandStack.pop())!
            case "-":
                res = Double(operandStack.selfvalue[operandStack.selfvalue.count-2])! - Double(operandStack.pop())!
                _ = operandStack.pop()
            case "×":
                res = Double(operandStack.pop())! * Double(operandStack.pop())!
            case "÷":
                res = Double(Double(operandStack.selfvalue[operandStack.selfvalue.count-2])! / Double(operandStack.pop())!)
                _ = operandStack.pop()
            default:
                res = 0
            }
            _ = operatorStack.pop()
            operandStack.push(value: "\(res)")
        }
        
        
        return Double(operandStack.pop())!
        
    }
    
}
