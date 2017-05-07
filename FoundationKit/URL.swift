//
//  URL.swift
//  CommonKit
//
//  Created by Pedro José Pereira Vieito on 5/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension URL {

    #if os(macOS)
    /// AppleScript style path of the URL.
    public var appleScriptPath: String? {

        let appleScript = NSAppleScript(source: "set pathString to \"\(self.path)\"\nset pathURL to POSIX file pathString\nreturn pathURL as string")
        let response = appleScript?.executeAndReturnError(nil)

        return response?.stringValue
    }
    #endif
}
