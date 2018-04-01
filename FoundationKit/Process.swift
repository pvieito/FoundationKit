//
//  Process.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 2/4/18.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Process {
    
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
