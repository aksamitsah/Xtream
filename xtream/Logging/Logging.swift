//
//  Untitled.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import Foundation

enum Log {
    
    fileprivate enum LogLevel {
        
        case info
        case warning
        case error
        
        fileprivate var prefix: String {
            
            switch self {
            case .info:
                return    "INFO  ℹ️"
            case .warning:
                return "WARN  ⚠️"
            case .error:
                return   "ALERT ❌"
            }
            
        }
    }
    
    fileprivate struct Context {
        
        let file: String
        let function: String
        let line: Int
        
        var description: String {
            "\((file as NSString).lastPathComponent): \(line) \(function)"
        }
    }
    
    fileprivate static func handleLog(
        level: LogLevel,
        str: String,
        shouldLogContext: Bool,
        context: Context
    ) {
        
        let logComponents = ["[\(level.prefix)]", str]
        var fullString = logComponents.joined(separator: " ")
        if shouldLogContext {
            fullString += " ➡ \(context.description)"
        }
        
        #if DEBUG
        debugPrint(fullString)
        #endif
    }
    
    static func info(
        _ str: StaticString,
        shouldLogContext: Bool = true,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        
        let context = Context(file: file, function: function, line: line)
        Log.handleLog(level: .info, str: str.description, shouldLogContext: shouldLogContext, context: context)
    }
    
    static func warning(
        _ str: StaticString,
        shouldLogContext: Bool = true,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let context = Context(file: file, function: function, line: line)
        Log.handleLog(level: .warning, str: str.description, shouldLogContext: shouldLogContext, context: context)
    }
    
    static func error(
        _ str: StaticString,
        shouldLogContext: Bool = true,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let context = Context(file: file, function: function, line: line)
        Log.handleLog(level: .error, str: str.description, shouldLogContext: shouldLogContext, context: context)
    }
    
    static func error(
        _ str: String,
        shouldLogContext: Bool = true,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let context = Context(file: file, function: function, line: line)
        Log.handleLog(level: .error, str: str.description, shouldLogContext: shouldLogContext, context: context)
    }
    
    static func error(
        _ error: Error?,
        shouldLogContext: Bool = true,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let context = Context(file: file, function: function, line: line)
        Log.handleLog(
            level: .error,
            str: error?.localizedDescription ?? "nil",
            shouldLogContext: shouldLogContext,
            context: context
        )
        
    }
}
