//
//  DebugLog.swift
//  bluebox
//
//  Created by Andrew on 25/04/2017.
//  Copyright © 2017 Fusion Group. All rights reserved.
//

import Foundation
import SwiftyBeaver

@objc public class DebugLog : NSObject {
    private let m_log = SwiftyBeaver.self
    
    private static let DOCUMENT_DIR = FileManager.default.urls(
        for: .documentDirectory, in: .userDomainMask
        ).first!
    
    private static let LOGS_DIR = DOCUMENT_DIR.appendingPathComponent("Logs")
    private static let DEFAULT_LOG_FILE = LOGS_DIR.appendingPathComponent("default.log").createFileURL()!
    
    private var m_jobReference: String?
    @objc public var jobReference: String? {
        get {
            return m_jobReference
        }
        set {
            
            m_jobReference = newValue
        }
    }
    
    private var m_userReference: String?
    @objc public var userReference: String? {
        get {
            return m_userReference
        }
        set {
            m_userReference = newValue
        }
    }
    
    private var fileDestination: FileDestination? {
        return m_log.destinations.flatMap({$0 as? FileDestination}).first
    }
    
    @objc public var data: Data? {
        guard let currentUrl = fileDestination?.logFileURL else { return nil }
        return try? Data.init(contentsOf: currentUrl)
    }
    
    static private let m_debugLog = DebugLog()
    
    // this is silly as m_debugLog is a constant...
    @objc public static func instance() -> DebugLog {
        return m_debugLog
    }
    
    // initialisation methods
    
    private override init() {
        super.init()
        let console = ConsoleDestination.init()
        let file = FileDestination.init()
        file.asynchronously = true
        
        m_log.addDestination(console)
        m_log.addDestination(file)
        
        setup(LogDir: DebugLog.LOGS_DIR, LogDestination: DebugLog.DEFAULT_LOG_FILE)
    }
    
    private func setup(LogDir: URL, LogDestination: URL) {
        do {
            try create(dir: LogDir)
            setup(File: LogDestination)
            fileDestination?.logFileURL = LogDestination
        } catch let err {
            print(err)
        }
    }
    
    
    //MARK: public framework methods
    
    /// This will add a message to the debug log.
    /// In swift all we need is the message
    /// However objective-c cannot access Swift's default parameters
    /// so it must provide the file, function and line parameters.
    ///
    /// - Parameters:
    ///   - WithMessage: The message to log
    ///   - File: The file in which the event occurred
    ///   - Function: The function in which the event occurred
    ///   - Line: The line number at which the event occured
    public func debug(
        WithMessage Message: String,
        _ File:String = #file,
        _ Function:String = #function,
        _ Line:Int = #line
        )
    {
        m_log.debug(format(Message), File, Function, line: Line)
    }
    
    public func debug(
        _ Message: String,
        _ File:String = #file,
        _ Function:String = #function,
        _ Line:Int = #line
        )
    {
        m_log.debug(format(Message), File, Function, line: Line)
    }
    
    
    /// For usage with objective-c's const char pointer __FILE__ and __FUNCTION__
    ///
    /// - Parameters:
    ///   - Message: The message to log
    ///   - File: The file the event occurred. Use the __FILE__ constant.
    ///   - Function: The function the event occurred. Use the __FUNCTION__ constant.
    ///   - Line: The line the event occurred.
    @objc public func debug(
        WithMessage Message: String,
        File: UnsafePointer<CChar>,
        Function: UnsafePointer<CChar>,
        Line: Int
        )
    {
        let file = String.init(cString: File)
        let function = String.init(cString: Function)
        
        debug(WithMessage: Message, file, function, Line)
    }
    
    public func error(
        WithMessage Message: String,
        _ File:String = #file,
        _ Function:String = #function,
        _ Line:Int = #line
        )
    {
        m_log.error(format(Message), File, Function, line: Line)
    }
    
    public func error(
        _ Message: String,
        _ File:String = #file,
        _ Function:String = #function,
        _ Line:Int = #line
        )
    {
        m_log.error(format(Message), File, Function, line: Line)
    }
    
    /// For usage with objective-c's const char pointer __FILE__ and __FUNCTION__
    ///
    /// - Parameters:
    ///   - Message: The message to log
    ///   - File: The file the event occurred. Use the __FILE__ constant.
    ///   - Function: The function the event occurred. Use the __FUNCTION__ constant.
    ///   - Line: The line the event occurred.
    @objc public func error(
        WithMessage Message: String,
        File: UnsafePointer<CChar>,
        Function: UnsafePointer<CChar>,
        Line: Int
        )
    {
        let file = String.init(cString: File)
        let function = String.init(cString: Function)
        
        error(WithMessage: Message, file, function, Line)
    }
    
    public func warning(
        WithMessage Message: String,
        _ File:String = #file,
        _ Function:String = #function,
        _ Line:Int = #line
        )
    {
        m_log.warning(format(Message), File, Function, line: Line)
    }
    
    public func warning(
        _ Message: String,
        _ File:String = #file,
        _ Function:String = #function,
        _ Line:Int = #line
        )
    {
        m_log.warning(format(Message), File, Function, line: Line)
    }
    
    /// For usage with objective-c's const char pointer __FILE__ and __FUNCTION__
    ///
    /// - Parameters:
    ///   - Message: The message to log
    ///   - File: The file the event occurred. Use the __FILE__ constant.
    ///   - Function: The function the event occurred. Use the __FUNCTION__ constant.
    ///   - Line: The line the event occurred.
    @objc public func warning(
        WithMessage Message: String,
        File: UnsafePointer<CChar>,
        Function: UnsafePointer<CChar>,
        Line: Int
        )
    {
        let file = String.init(cString: File)
        let function = String.init(cString: Function)
        
        warning(WithMessage: Message, file, function, Line)
    }
    
    @objc public func move(To newFile : URL) {
        let logData = self.data
        let fileManager = FileManager.default
        
        fileManager.createFile(
            atPath: newFile.path,
            contents: logData,
            attributes: nil
        )
        
        clear()
    }
    
    @objc public func clear() {
        let logCleared = fileDestination?.deleteLogFile()
        print("Log cleared: \(logCleared ?? false)")
    }
    
    
    // MARK: internal methods
    private func format( _ Message: String) -> String {
        let ref = m_jobReference ?? ""
        let user = m_userReference ?? ""
        
        return "[User: \(user)] [JobRef: \(ref)] - \(Message)"
    }
    
    private func create(dir: URL) throws {
        let fileManager = FileManager.default
        
        try fileManager.createDirectory(
            at: dir,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }
    
    private func setup(File: URL) {
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: File.path) {
            fileManager.createFile(
                atPath: File.path,
                contents: nil,
                attributes: nil
            )
        }
    }
}
