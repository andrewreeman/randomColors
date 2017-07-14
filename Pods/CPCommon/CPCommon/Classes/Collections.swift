//
//  Collections.swift
//  BDI_iOS
//
//  Created by development on 02/08/2016.
//  Copyright © 2016 ControlPointLLP. All rights reserved.
//

import Foundation


///
/// allows unique filtering on properties.
/// for insance: let uniqueGroups = uniqueFilter(profiles, UsingFilter: {return $0.Group})
/// will ensure that profiles has no profiles that share the same group
///
public func uniqueFilter<T, E: Comparable>(_ list: Array<T>, UsingFilter filter: (T) -> E?) -> [E] {
    return list.reduce([E]()) {
        (cumulative: [E], item: T) in
        guard let element = filter(item)
            , !cumulative.contains(where: {$0 == element})
            else {
                return cumulative
        }
        var uniqueCumulative = cumulative
        uniqueCumulative.append(element)
        return uniqueCumulative
    }
}

/// moves the found item to the end
public func moveToEnd<T>(_ list: Array<T>, UsingPredicate predicate: (T) -> Bool) -> [T] {
    var newList = list
    if let index = list.index(where: {predicate($0)}){
        let item = newList.remove(at: index)
        newList.append(item)
    }
    return newList
}

//HOWTO: safe array access: http://stackoverflow.com/a/30593673/1742518
extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    public subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
    
    public var hasItems: Bool {
        return !self.isEmpty
    }
}


extension Sequence where Iterator.Element == Int {
    public var sum: Int {
        return self.reduce(0, { return $0 + $1 })
    }
    
    public var joinToSingleInt: Int? {
        // this could fail if one item in the list is a negative number
        let selfAsString = self.reduce("", {"\($0)\($1)"})
        return Int(selfAsString)
    }
    
}

/// This creates a sequence of overlapping pairs
extension Sequence {
    public var pairs: [(Iterator.Element, Iterator.Element)] {
        
        // must construct arrays using this method instead of [Iterator.Element]()
        var pairs: [(Iterator.Element, Iterator.Element)] = []
        
        var first: Iterator.Element?
        self.forEach{
            if first == nil {
                first = $0
                return
            }
            else {
                let second = $0
                pairs.append((first!, second))
                first = nil
            }
        }
        
        return pairs
    }
    
    /**
     Iterate through every element along with it's neighbour
    */
    public func forEachWithNeighbour(_ f: (Iterator.Element, Iterator.Element) -> () ) {
        let nilPlaceHolder: Iterator.Element? = nil
        
        _ = self.reduce(nilPlaceHolder, {
            (previous: Iterator.Element?, current: Iterator.Element) in
            guard let previous = previous else { return current }
            
            f(previous, current)
            return current
        })
    }
}



// Mapping a dictionary: https://stackoverflow.com/a/24219069/1742518
extension Dictionary {
    public init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
}

extension Dictionary {
    public func mapPairs<OutKey: Hashable, OutValue>(
        transform: (Element) throws -> (OutKey, OutValue)
    ) rethrows -> [OutKey: OutValue] {
    
        return Dictionary<OutKey, OutValue>(try map(transform))
    
    }
}
