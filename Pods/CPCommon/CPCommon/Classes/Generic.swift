//
//  Generic.swift
//  BDI_iOS
//
//  Created by ControlPoint on 23/05/2016.
//  Copyright © 2016 ControlPointLLP. All rights reserved.
//

import Foundation

// these are to be used only by the most laziest of developers...
extension Int {
    public func min(_ lowerBound: Int) -> Int {
        return Swift.min(self, lowerBound)
    }
}

extension Double {
    public func min(_ lowerBound: Double) -> Double {
        return Swift.min(self, lowerBound)
    }
}


/// If not optional then return self
/// If cannot be unwrapped then return nil
/// If can be unwrapped then return unwrapped value
/// This could certainly have better documentation...
public func unwrap<T: Any>(any: T) -> T? {
    let mirror = Mirror(reflecting: any)
    guard mirror.displayStyle == .optional else { return any }
    guard let child = mirror.children.first else { return nil }
    return unwrap(any: child.value) as? T
}

// extensions
extension Int {
    public func times(_ f: () -> ()) {
        if self > 0 {
            for _ in 0..<self {
                f()
            }
        }
    }        
    
    public func times(_ f: (Int) -> ()) {
        for i: Int in 0..<self {
            f(i)
        }
    }

    
    // This is a (very swifty) useful function for creating a list N items.
    // Can use like: 5.map{return "I am string number \($0)"}
    // This will create an array of 5 strings!
    public func map<T>(_ f: (Int) -> T) -> [T]{
        var collection = [T]()
        
        self.times { (i: Int) in
            let mapped: T = f(i)
            collection.append(mapped)
        }
        return collection
    }

}


extension Int {
    public var digitList: [Int] {
        return "\(self)".digitList
    }
}

extension UIColor {
    public class func createColorFromRGBValues(red: Float, green: Float, blue: Float) -> UIColor {
        return UIColor.init(red: CGFloat(red/256.0), green: CGFloat(green/256.0), blue: CGFloat(blue/256.0), alpha: 1)
    }
    
    public func darkerColor() -> UIColor {
        var hue = CGFloat(0.0)
        var saturation = CGFloat(0.0)
        var brightness = CGFloat(0.0)
        var alpha = CGFloat(0.0)
        
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness * 0.75, alpha: alpha)
        }
        return self
    }
    
    public func lighterColor() -> UIColor {
        var hue = CGFloat(0.0)
        var saturation = CGFloat(0.0)
        var brightness = CGFloat(0.0)
        var alpha = CGFloat(0.0)
        
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness * 1.3, alpha: alpha)
        }
        return self
    }
}


public extension DispatchTime {
    public static func from(seconds: Int) -> DispatchTime {        
        return DispatchTime.from(seconds: Int64(seconds))
    }
    
    public static func from(seconds: Int64) -> DispatchTime {
        return DispatchTime.now() + Double(seconds * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
    }
}

// appending to a file http://stackoverflow.com/a/32787535/1742518
extension String {
    public func appendLineToURL(fileURL: URL) throws {
        try self.appending("\n").appendToURL(fileURL: fileURL)
    }
    
    public func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.appendToURL(fileURL: fileURL)
    }
}

extension Data {
    public func appendToURL(fileURL: URL) throws {
        if let fileHandle = try? FileHandle.init(forWritingTo: fileURL) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write( to: fileURL, options: .atomicWrite )
        }
    }
}

extension TimeInterval {
    public static var dayLengthInSeconds: TimeInterval {
        return 60 * 60 * 24
    }
}

extension Date {
    public func nextDay() -> Date {
        if let nextCalendarDay = Calendar.current.date(byAdding: .day, value: 1, to: self) {
            return nextCalendarDay
        }
        else {
            return self.addingTimeInterval( TimeInterval.dayLengthInSeconds )
        }
        
    }
}



public enum UUIDHelperError: Error {
    case incorrectLength
    case nsuuidParseError
}

extension UUID {
    public var removedDashes: String {
        let uuidString = self.uuidString
        return uuidString.replacingOccurrences(of: "-", with: "")
    }
    
    public static func fromString(_ stringUUID: String) throws -> UUID {
        
        var startIndex = stringUUID.startIndex
        var endIndex = stringUUID.index(startIndex, offsetBy: 8)
        var range = startIndex..<endIndex
        let slice1 = stringUUID[range]
        
        startIndex = endIndex
        endIndex = stringUUID.index(endIndex, offsetBy: 4)
        range = startIndex..<endIndex
        let slice2 = stringUUID[range]
        
        startIndex = endIndex
        endIndex = stringUUID.index(endIndex, offsetBy: 4)
        range = startIndex..<endIndex
        let slice3 = stringUUID[range]
        
        startIndex = endIndex
        endIndex = stringUUID.index(endIndex, offsetBy: 4)
        range = startIndex..<endIndex
        let slice4 = stringUUID[range]
        
        startIndex = endIndex
        endIndex = stringUUID.endIndex
        range = startIndex..<endIndex
        let slice5 = stringUUID[range]
        
        let outputString = "\(slice1)-\(slice2)-\(slice3)-\(slice4)-\(slice5)"
        
        guard let uuid = UUID.init(uuidString: outputString) else {
            throw UUIDHelperError.nsuuidParseError
        }
        return uuid
    }
}

extension URL {
    public func createFileURL() -> URL? {
        guard var sourceURLComponents = URLComponents.init(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        sourceURLComponents.scheme = "file"
        return sourceURLComponents.url
    }
}


public struct AnyObjectHelper {
    public static func forceToArray<T>(_ thing: Any?) -> [T] {
        switch thing {
        case let correctThing as T:
            return [correctThing]
        case let correctThingArray as [T]:
            return correctThingArray
        default:
            return [T]()
        }
    }
}



