//
//  Process.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 2/4/18.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

#if !os(iOS) && !os(tvOS) && !os(watchOS)
import Foundation

extension Process {
    public static func getExecutableURL(name: String) -> URL? {
        for executableDirectory in ProcessInfo.processInfo.executableDirectories {
            for executableExtension in ProcessInfo.processInfo.executableExtensions {
                let executableURL = executableDirectory
                    .appendingPathComponent(name)
                    .appendingPathExtension(executableExtension)
                if FileManager.default.fileExists(at: executableURL) {
                    return executableURL
                }
            }
        }
        
        return nil
    }
}

extension Process {
    public convenience init(executableName: String, arguments: [String]? = nil) throws {
        guard let executableURL = Process.getExecutableURL(name: executableName) else {
            throw NSError(description: "Executable “\(executableName)” not found.")
        }
        
        self.init()
        
        if #available(macOS 10.13, *) {
            self.executableURL = executableURL
        } else {
            self.launchPath = executableURL.path
        }
        
        if let arguments = arguments {
            self.arguments = arguments
        }
    }
}

extension Process {
    public func runReplacingCurrentProcess() throws {
        var executableURL: URL?
        
        if #available(macOS 10.13, *) {
            executableURL = self.executableURL
        } else {
            executableURL = self.launchPath?.pathURL
        }
        
        guard let targetExecutableURL = executableURL else {
            throw NSError(description: "Error launching unspecified executable.")
        }
        
        var arguments = self.arguments ?? []
        arguments = [targetExecutableURL.path] + arguments
        let cArguments = arguments.map { strdup($0) } + [nil]
        
        if let environment = self.environment {
            for (key, value) in environment {
                setenv(key, value, 1)
            }
        }
        
        execv(targetExecutableURL.path, cArguments)
        
        throw NSError(description: "Error launching “\(targetExecutableURL.lastPathComponent)” executable.")
    }
    
    public func runAndWaitUntilExit() throws {
        if #available(macOS 10.13, *) {
            try self.run()
        } else {
            self.launch()
        }

        self.waitUntilExit()
        
        guard self.terminationStatus == 0 else {
            throw NSError(description: "Process terminated with failure (termination status code: \(self.terminationStatus))", code: Int(self.terminationStatus))
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
            throw NSError(description: "Process output is not a decodable string.")
        }
        return outputString.trimmingCharacters(in: .newlines)
    }
}

extension Process {
    public static func killProcess(name: String) throws {
        let killProcess = try Process(
            executableName: "killall", arguments: [name])
        try killProcess.runAndWaitUntilExit()
    }
}
#endif
