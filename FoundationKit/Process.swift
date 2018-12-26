//
//  Process.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 2/4/18.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

#if !canImport(MobileCoreServices)
import Foundation

extension Process {
    enum Error: LocalizedError {
        case executableNotFound(String)
        case processFailure(Int32)
        case invalidOutputString

        var errorDescription: String? {
            switch self {
            case .executableNotFound(let executableName):
                return "Executable “\(executableName)” not found."
            case .processFailure(let errorCode):
                return "Process terminated with failure (termination status code: \(errorCode))."
            case .invalidOutputString:
                return "Process output is not a decodable string."
            }
        }
    }
    
    public convenience init(executableName: String, arguments: [String]? = nil) throws {
        guard let executableURL = Process.getExecutableURL(name: executableName) else {
            throw Error.executableNotFound(executableName)
        }
        
        self.init()
        self.launchPath = executableURL.path
        
        if let arguments = arguments {
            self.arguments = arguments
        }
    }
    
    public static func getExecutableURL(name: String) -> URL? {
        let whichProcess = Process()
        let outputPipe = Pipe()
        
        whichProcess.launchPath = "/usr/bin/which"
        whichProcess.arguments = [name]
        whichProcess.standardOutput = outputPipe
        whichProcess.launch()
        whichProcess.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let executablePath = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .newlines) else {
            return nil
        }
        
        guard !executablePath.isEmpty else {
            return nil
        }
        
        guard FileManager.default.isExecutableFile(atPath: executablePath) else {
            return nil
        }
        
        return URL(fileURLWithPath: executablePath)
    }
}

@available(macOS 10.13, *)
extension Process {
    public func runAndWaitUntilExit() throws {
        try self.run()
        self.waitUntilExit()
        
        guard self.terminationStatus == 0 else {
            throw Error.processFailure(self.terminationStatus)
        }
    }
    
    public func runAndGetOutputData() throws -> Data {
        let outputPipe = Pipe()
        self.standardOutput = outputPipe
        try self.runAndWaitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        return outputData
    }
    
    public func runAndGetOutputString(encoding: String.Encoding = .utf8) throws -> String {
        let outputData = try self.runAndGetOutputData()
        guard let outputString = String(data: outputData, encoding: encoding) else {
            throw Error.invalidOutputString
        }
        return outputString.trimmingCharacters(in: .newlines)
    }
    
    #if os(macOS)
    public static func killProcess(name: String) throws {
        let killallProcess = try Process(executableName: "killall")
        killallProcess.arguments = [name]
        try killallProcess.runAndWaitUntilExit()
    }
    #endif
}
#endif
