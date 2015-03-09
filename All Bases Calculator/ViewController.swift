//
//  ViewController.swift
//  All Bases Calculator
//
//  Created by Hunter on 3/4/15.
//  Copyright (c) 2015 SRAM. All rights reserved.
//

import UIKit

// stackoverflow knows everything
extension String{
    public func indexOf(char: Character) -> Int{
        if let index = find(self, char){
            return distance(self.startIndex, index)
        }else{
            return -1
        }
    }
}

class ViewController: UIViewController {

    // Label is the only form of output in calculator apps
    @IBOutlet weak var outputValue: UILabel!
    @IBOutlet weak var operationValue: UILabel!
    
    // typing: whether or not its a new number or existing number
    // overTwoNumbers: if first number is made, i.e. 3(3:1)+3(3:2) vs 3+3(6:1)+3(3:2)
    var typing = false
    var firstNumber: Float = 0.0
    var secondNumber: Float = 0.0
    var overTwoNumbers = false
    var result: Float = 0.0
    var operation = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Resets everythang
    @IBAction func allClear(sender: UIButton) {
        outputValue.text = "0"
        firstNumber = 0
        secondNumber = 0
        typing = false
        overTwoNumbers = false
        operationValue.text = ""
    }
    
    // -/+ is pressed
    // Makes positive negative and negative positive
    // Can't just convert to number and make negative as it's not in Base 10 (A, B, etc. won't process)
    @IBAction func negatize(sender: UIButton) {
        typing = true
        if outputValue.text!.hasPrefix("-") {
            outputValue.text = outputValue.text!.substringFromIndex(advance(outputValue.text!.startIndex, 1))
        }else{
            outputValue.text = "-" + outputValue.text!
        }
    }

    // . is pressed
    // adds . to output label
    // if a 0 was there it'll remain there
    @IBAction func pointPressed(sender: UIButton) {
        var index = outputValue.text!.indexOf(".")
        println("\(index)")
        if outputValue.text!.indexOf(".") == -1 {
                outputValue.text = outputValue.text! + "."
        }else{
            if !typing {
                outputValue.text = "0."
            }
        }
        typing = true
    }
    
    // 0-B is pressed
    // adds that button's text to output label
    // if new number sets label to only that button's text and defines number as existing
    @IBAction func number(sender: AnyObject) {
        var number = sender.currentTitle!
        
        if typing && outputValue.text!.hasPrefix("-0"){
            outputValue.text = "-" + number!
        }else if typing {
            outputValue.text = outputValue.text! + number!
        }else{
            if number != "0"{
                typing = true
            }
            outputValue.text = number
        }
    }

    // +,-,/,x is pressed
    // stores first number as output label if no previous first number
    // otherwise preforms operation with this number and previous first
    // number and stores that as new first number
    @IBAction func operation(sender: UIButton) {
        typing = false
        
        if firstNumber != 0{
            overTwoNumbers = true
        }else{
            overTwoNumbers = false
        }
        
        
        // println("first: \(firstNumber)")
        if overTwoNumbers {
            process()
            
        }
        firstNumber = inputToDecimal(outputValue.text!)
        println("first: \(firstNumber)")
        
        operation = sender.currentTitle!
        operationValue.text = operation
        // outputValue.text = operation + "0"
    }
    
    // = is pressed
    // runs operation
    // resets firstNumber to 0 and number in output to new number
    @IBAction func equals(sender: UIButton) {
        typing = false
        process()
        firstNumber = 0
        operationValue.text = ""
        
    }
    
    // Runs with equals(=) or operation(+-/x) if overTwoNumbers is true
    // should've done a case statement
    func process(){
        secondNumber = inputToDecimal(outputValue.text!)
        println("second: \(secondNumber)")
        if operation == "+"{
            result = firstNumber + secondNumber
        }else if operation == "-"{
            result = firstNumber - secondNumber
        }else if operation == "/"{
            result = firstNumber/secondNumber
        }else if operation == "X"{
            result = firstNumber * secondNumber
        }else{
            result = secondNumber
        }
        outputValue.text = decimalToDuo(result)
        secondNumber = 0
        
    }
    
    // converts base 10 to base 12
    func decimalToDuo(number: Float) -> String{
        var numberText: NSString = number.description
        var duo: String = ""
        
        if number % 1 != 0{
            var numberAsString: String = numberText
            var decimalLocation = numberAsString.indexOf(".")
            var power = -(numberText.length - decimalLocation - 1)
            
            var numberInts: Int = numberText.substringToIndex(decimalLocation).toInt()!
            var leftoverText: NSString = numberText.substringFromIndex(decimalLocation)
            var leftover: Float = leftoverText.floatValue
            
            var intValue = String(numberInts, radix: 12).uppercaseString
            var decimalValue: String = "."
            var i: Int = 0
            
            do{
                var digit: Int = Int(leftover * 12)
                leftover = (leftover * 12) - Float(digit)
                var digitString = String(digit)
                if digit == 10 {
                    digitString = "A"
                }else if digit == 11{
                    digitString = "B"
                }
                
                decimalValue = decimalValue + digitString
                i++
                println("digit int: \(digit) leftover: \(leftover)")
            } while i <= 4 && leftover > 0.0001
            
            duo = intValue + decimalValue
            println("duo: \(duo)")
            // println("intvalues: \(intValues) pointvalues: \(pointValues)")
            // println("number: \(number) power: \(power)")
        }else{
            var numberInt = Int(number)
            duo = String(numberInt, radix: 12).uppercaseString
        }
        
        return duo
    }
    
    // converts input values to base 10
    // all processing is in base 10 and then converted back
    // otherwise would've had to redo all math functions (not happening)
    
    // My pride and joy...   of this week
    
    // used NSString instead of string because apple is stupid
    func inputToDecimal(input: NSString) -> Float{
        var number = input
        var sum: Float = 0.0
        var digit = ""
        var power = 0
        var negative = false
        
        // negative numbers
        if number.hasPrefix("-") {
            number = number.substringFromIndex(1)
            negative = true
            println("is negative")
        }
        
        // non-integers
        if number.containsString("."){
            var numberAsString: String = number
            var decimalLocation = numberAsString.indexOf(".")
            power = -(number.length - decimalLocation - 1)
            
            var intValues = number.substringToIndex(decimalLocation)
            var pointValues = number.substringFromIndex(decimalLocation + 1)
            number = intValues + pointValues
            
            // println("intvalues: \(intValues) pointvalues: \(pointValues)")
            // println("number: \(number) power: \(power)")
        }
        
        while(number.length > 0){
            digit = number.substringFromIndex(number.length - 1)
            
            if digit == "A"{
                digit = "10"
            }else if digit == "B"{
                digit = "11"
            }
            
            sum = sum + (Float(digit.toInt()!) * Float(pow(Double(12), Double(power))))
            
            number = number.substringToIndex(number.length - 1)
            power++
            // println("sum: \(sum) number: \(number) digit: \(digit)")
        }
        
        if negative  {
            sum = -sum
        }
        return sum
    }
}

