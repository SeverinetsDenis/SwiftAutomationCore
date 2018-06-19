//
//  OxaRandom.swift
//
//  Copyright © 2017 Oxagile. All rights reserved.
//

import Foundation

class OxaRandom {
    
    static func getString (length : Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(UInt32(letters.length))
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    static func getEmail (length : Int) -> String {
        return "\(OxaRandom.getString(length: length))@test.com"
    }
    
    static func getNumber(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    static func getNumber(min: Double = 0, max: Double = 1) -> Double {
        return (Double(arc4random()) / Double(UInt32.max)) * (max - min) + min
    }
    
    static func randomBool() -> Bool {
        return arc4random_uniform(2) == 0
    }
    
    static func getRandomValueFromList(list: Array<String>) -> String {
        let index = arc4random_uniform(UInt32(list.count - 1))
        return list[Int(index)]
    }
}
