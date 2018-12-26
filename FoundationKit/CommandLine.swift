//
//  CommandLine.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 17/2/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension CommandLine {
    /// Print a usage help text in the Command Line.
    ///
    /// - Parameters:
    ///   - usage: String with the example usage of the tool.
    ///   - author: Author of the tool.
    ///   - year: Year of creation of the tool. It will show as part of the copyright with the author.
    ///   - description: Description of the tool.
    @available(*, deprecated)
    public static func print(usage: String, author: String, year: Int, description: String) {
        guard !arguments.isEmpty else {
            return
        }
        
        let name = URL(fileURLWithPath: arguments[0]).lastPathComponent
        Swift.print("\(name) - \(author) © \(year)")
        Swift.print("    \(description)\n")
        Swift.print("    Usage: \(name) \(usage)")
    }

    /// Prints an empty line.
    @available(*, deprecated)
    public static func printEmptyLine() {
        Swift.print()
    }

    /// Sets the Command Line output at start of the line. This does not work in the Xcode console.
    @available(*, deprecated)
    public static func printReturnLine() {
        Swift.print("\r", terminator: "")
    }
}
