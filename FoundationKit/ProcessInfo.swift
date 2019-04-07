//
//  ProcessInfo.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 08/04/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension ProcessInfo {
    #if os(Windows)
    fileprivate static let dotCharacters = CharacterSet(charactersIn: ".")
    fileprivate static let pathSeparator: Character = ";"
    fileprivate static let defaultExecutableExtensions = ["COM", "EXE", "BAT", "CMD"]
    #else
    fileprivate static let pathSeparator: Character = ":"
    fileprivate static let defaultExecutableExtensions = [""]
    #endif
    
    private var uppercasedEnvironment: [String : String] {
        var uppercasedEnvironment: [String : String] = [:]
        for (key, value) in self.environment {
            uppercasedEnvironment[key.uppercased()] = value
        }
        return uppercasedEnvironment
    }
    
    private var environmentPaths: [String] {
        guard let path = self.uppercasedEnvironment["PATH"] else {
            return []
        }
        
        return path.paths
    }
    
    var executableDirectories: [URL] {
        return self.environmentPaths.pathURLs
    }
    
    var executableExtensions: [String] {
        #if os(Windows)
        guard let pathext = self.uppercasedEnvironment["PATHEXT"] else {
            return ProcessInfo.defaultExecutableExtensions.map { $0.lowercased() }
        }
        
        return pathext.paths.map { $0.trimmingCharacters(in: ProcessInfo.dotCharacters).lowercased() }
        #else
        return ProcessInfo.defaultExecutableExtensions
        #endif
    }
}

fileprivate extension String {
    var paths: [String] {
        return self.split(separator: ProcessInfo.pathSeparator).map(String.init)
    }
}
