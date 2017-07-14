//
//  RandomGeneratable.swift
//  CPCommon
//
//  Created by Andrew on 09/06/2017.
//  Copyright © 2017 ControlPointLLP. All rights reserved.
//

import Foundation


/**
 This file contains classes that will mainly be used for random data generation for testing.
 At the moment the random generation is not good enough for creating actualy usable sample data as it is too noisy. It is useful for testing though
 */

public protocol RandomGeneratable {
    static func random() -> Self
    func random() -> Self
}


// This is a nice way of saying we want an array of N elements with random data
// Note that it uses the 'map' extension on Int defined in the Common.swift file
public extension RandomGeneratable {
    static func random(ForCount: Int) -> [Self] {
        return Self.random().random(ForCount: ForCount)
    }
    
    func random(ForCount: Int) -> [Self] {
        return ForCount.map{(_) in self.random()}
    }
}

/* Interesting note about this is that you can do...
 let twiceAsRandom = Double.random().random()
 */
extension Double: RandomGeneratable {
    
    // Returns a random double
    public static func random() -> Double {
        return Double(arc4random())
    }
    
    // Returns a random double that is less than 'self'
    public func random() -> Double {
        /**
         The reason for the complexity of this is that we were getting overflows when double was higher than UInt32 max or min
         */
        let uintValue: UInt32
        
        switch self {
        case let x where x > Double(UInt32.max):
            uintValue = UInt32.max
        case let x where x < Double(UInt32.min):
            uintValue = UInt32.min
        default:
            uintValue = UInt32(self)
        }
        
        let random = arc4random_uniform(uintValue)
        return Double(random)
    }
}

// Returns random ints
extension Int: RandomGeneratable {
    public static func random() -> Int {
        return Int.max.random()
    }
    
    public func random() -> Int {
        return Int(Double(self).random())
    }
}


extension Date: RandomGeneratable {
    public static func random() -> Date {
        return Date.distantFuture.random()
    }
    
    public func random() -> Date {
        return Date.init(timeIntervalSinceReferenceDate: self.timeIntervalSinceReferenceDate.random())
    }
}

extension String: RandomGeneratable {
    public static func random() -> String {
        return UUID.init().uuidString
    }
    
    public func random() -> String {
        return String.random().substring(to: self.characters.count)
    }
    
    
    public func scramble() -> String {
        return self.shuffle()
    }
    
    
    // mixes up the characters in a string
    public func shuffle() -> String {
        return String.init( Array(self.characters).shuffle() )
    }
}

extension Array {
    
    /** Sometimes we prefer the word scramble! */
    public func scramble() -> [Element] {
        return self.shuffle()
    }
    
    // Mixes up the elements in an array
    public func shuffle() -> [Element] {
        var shuffledArray = [Element]()
        
        var originalColors = self
        
        originalColors.count.times {
            let i = self.index(originalColors.startIndex, offsetBy: originalColors.count.random())
            let item = originalColors.remove(at: i)
            shuffledArray.append( item )
        }
        
        return shuffledArray
    }
}


    

