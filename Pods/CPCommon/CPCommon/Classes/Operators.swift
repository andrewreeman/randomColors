//
//  Operators.swift
//  CPCommon
//
//  Created by Andrew on 22/06/2017.
//  Copyright © 2017 ControlPointLLP. All rights reserved.
//

import Foundation


/** In english, the below overload will allow more expressive passing of results of one method to another method
 It will take a T on the left hand side and pass it as the argument of the function F on the right hand side.
 
 So instead of this, which will get the number of ticks an hour past the string date:
    let date: Date = dateFromString("12:34:13")
    let dateAddedByAnHour: Date = addAnHourToDate(date)
    let ticksSinceEpoch: Int = convertDateToTicks(dateAddedByAnHour)
    
 Or even worse this, which you have to read from inner to outer:
    convertDateToTicks(addAnHourToDate(dateFromString("12:34:13")))
 We can now do this:
    "12:34:13" >>- dateFromString >>- addAnHourToDate >>- convertDateToTicks
 Or break it up into separate lines:
    let ticksAnHourSinceTime = "12:34:13"
        >>- dateFromString 
        >>- addAnHourToDate 
        >>- convertDateToTicks
 
*/

// Taken from: https://github.com/thoughtbot/Runes
precedencegroup MonadicPrecedenceLeft {
    associativity: left
}

/**
 map a function over a value with context and flatten the result
 Expected function type: `m a -> (a -> m b) -> m b`
 Haskell `infixl 1`
 */
infix operator >>- : MonadicPrecedenceLeft

/**
 flatMap a function over an optional value (left associative)
 - If the value is `.none`, the function will not be evaluated and this will
 return `.none`
 - If the value is `.some`, the function will be applied to the unwrapped
 value
 - parameter f: A transformation function from type `T` to type `Optional<U>`
 - parameter a: A value of type `Optional<T>`
 - returns: A value of type `Optional<U>`
 */
@discardableResult public func >>- <T, U>(a: T?, f: (T) -> U?) -> U? {
    return a.flatMap(f)
}


// Non optionals will use this
@discardableResult public func >>- <T, U>(a: T, f: (T) -> U) -> U {
    return f(a)
}

public func >>- <T>(a: T?, f: (T) -> ()) {
    a.flatMap(f)
}

/**
 This will only map the function if the function is not nil. 
 It seems a bit pointless but allows syntax like the following:
 
 optionalView >>- optionalPresenterForView?.present
 
*/
@discardableResult public func >>- <T, U>(a: T?, f: ((T) -> U?)?) -> U? {
    if let unwrappedFunction = f {
        return a.flatMap( unwrappedFunction )
    }
    else { return nil }
}

/**
 Perform the mapping function over each element of an array
*/
@discardableResult public func >>- <T, U>(a: [T]?, f: (T) -> U?) -> [U] {
    return a?.flatMap(f) ?? [U]()
}

/**
 Only performs the mapping function on the non-nil elements of an optional array with optional elements
*/
@discardableResult public func >>- <T, U>(a: [T?]?, f: (T) -> U?) -> [U?] {
    return a?.flatMap( {$0.flatMap(f) } ) ?? [U]()
}


