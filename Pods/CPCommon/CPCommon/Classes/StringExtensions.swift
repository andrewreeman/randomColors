//
//  StringExtensions.swift
//  CPCommon
//
//  Created by Andrew on 23/02/2017.
//  Copyright © 2017 ControlPointLLP. All rights reserved.
//

import Foundation

extension String {
    public var localized: String {
        let localizedString =  NSLocalizedString(self, comment: self)
        
        if localizedString == self {
            print("😡Untranslated string: \(self)😡")
        }
        
        return localizedString
    }
}

extension String {
    /// substring functions from: http://stackoverflow.com/a/39742687/1742518
    public func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.characters.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.characters.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return self[startIndex ..< endIndex]
    }
    
    public func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    /// Returns a string from the start up until the specified character index
    public func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    public func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return self.substring(from: from, to: end)
    }
    
    public func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.substring(from: start, to: to)
    }
}

extension String {
    public var digitList: [Int] {
        return self.characters.flatMap{ Int("\($0)") }
    }
    
    public var hasItems: Bool {
        return !self.isEmpty
    }
}
