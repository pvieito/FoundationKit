//
//  Error.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 14/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Error {
    /// NSError with localized description from a Swift native LocalizedError.
    public var cocoaError: NSError {
        let userInfo = [
            NSLocalizedFailureReasonErrorKey: self.localizedDescription,
            NSLocalizedDescriptionKey: self.localizedDescription
        ]
        return NSError(domain: NSCocoaErrorDomain, code: -1, userInfo: userInfo)
    }
    
    public var localizedRecoverySuggestion: String? {
        return (self as NSError).userInfo[NSLocalizedRecoverySuggestionErrorKey] as? String
    }
}

extension NSError {
    public convenience init(description: String, recoverySuggestion: String? = nil, code: Int = -1) {
        var userInfo = [NSLocalizedDescriptionKey: description]
        if let recoverySuggestion = recoverySuggestion {
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion
        }
        self.init(domain: NSCocoaErrorDomain, code: code, userInfo: userInfo)
    }
}

#if canImport(Darwin)
extension OSStatus {
    public func enforce() throws {
        guard self == noErr else {
            var description: String
            if #available(watchOS 4.3, iOS 11.3, tvOS 11.3, *),
                let securityDescription = SecCopyErrorMessageString(self, nil) {
                    description = securityDescription as String
            }
            else {
                description = "Operation could not be completed (OSError \(self))."
            }
            
            throw NSError(description: description, code: Int(self))
        }
    }
}
#endif

public func printError(_ items: CustomStringConvertible...) {
    let errorString = items.map({ $0.description }).joined(separator: " ") + "\n"
    FileHandle.standardError.write(errorString.data(using: .utf8)!)
}
