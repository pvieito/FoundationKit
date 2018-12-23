//
//  UUID.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 25/10/2018.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

#if canImport(Cocoa)
import Foundation

extension NSAppleScript {
    public func execute() throws {
        var errorReferenceDictionary: NSDictionary?
        self.executeAndReturnError(&errorReferenceDictionary)
        guard let errorDictionary = errorReferenceDictionary as? [String : Any] else {
            return
        }
        
        let errorCode = errorDictionary["NSAppleScriptErrorNumber"] as? Int ?? CocoaError.Code.coderInvalidValue.rawValue
        let errorMessage = errorDictionary["NSAppleScriptErrorMessage"] ?? "Unknown AppleScript error."
        throw NSError(
            domain: "com.apple.AppleScript",
            code: errorCode,
            userInfo: [NSLocalizedDescriptionKey: errorMessage]
        )
    }
}
#endif
