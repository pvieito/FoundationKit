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

    public convenience init?(executableName: String) {
        guard let executableURL = Process.getExecutableURL(name: executableName) else {
            return nil
        }
        
        self.init()
        self.launchPath = executableURL.path
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
    
    #if os(macOS)
    public static func killProcess(name: String) {
        guard let killallProcess = Process(executableName: "killall") else {
            return
        }
        
        killallProcess.arguments = [name]
        killallProcess.launch()
        killallProcess.waitUntilExit()
    }
    #endif
}
#endif
