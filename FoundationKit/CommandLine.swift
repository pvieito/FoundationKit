//
//  CommandLine.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 17/2/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension CommandLine {
    /// Sets the output at start of the line. This does not work in the Xcode console.
    public static func clearTTYLine() {
        Swift.print("\r", terminator: "")
    }

    /// Clear the TTY output.
    public static func clearTTYScreen() {
        Swift.print("\u{001B}[2J", terminator: "")
    }
    
    /// True if both the stdout and stderr are TTYs.
    public static var isTTY: Bool {
        return FileHandle.standardOutput.isTTY && FileHandle.standardError.isTTY
    }
}
