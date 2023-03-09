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
        let error = (self as NSError)
        var userInfo = error.userInfo
        userInfo[NSLocalizedFailureReasonErrorKey] = self.localizedDescription
        userInfo[NSLocalizedDescriptionKey] = self.localizedDescription
        return NSError(domain: error.domain, code: error.code, userInfo: userInfo)
    }
    
    public var localizedError: LocalizedError {
        return self.cocoaError
    }
    
    public var localizedRecoverySuggestion: String? {
        return (self as NSError).userInfo[NSLocalizedRecoverySuggestionErrorKey] as? String
    }
}

extension Error {
    public var fullDescription: String {
        var errorDescription = self.localizedDescription
        if let localizedRecoverySuggestion = self.localizedRecoverySuggestion {
            errorDescription += "\n\n" + localizedRecoverySuggestion
        }
        return errorDescription
    }
    
    public var fullDescriptionInOneLine: String {
        return self.fullDescription
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter(\.hasContent)
            .joinedWithSpaces()
    }
}

extension Error {
    public func encode() throws -> Data {
        return try self.cocoaError.encode()
    }
}

extension NSError {
    private struct CodableError: Codable {
        let domain: String
        let code: Int
        let userInfo: [String: String]?
    }
    
    public func encode() throws -> Data {
        var encodableUserInfo: [String: String] = [:]
        for (key, value) in self.userInfo {
            if let value = value as? String {
                encodableUserInfo[key] = value
            }
        }
        let codableError = NSError.CodableError(domain: self.domain, code: self.code, userInfo: encodableUserInfo)
        return try JSONEncoder().encode(codableError)
    }
    
    public convenience init(encodedData: Data) throws {
        let codableError = try JSONDecoder().decode(CodableError.self, from: encodedData)
        self.init(domain: codableError.domain, code: codableError.code, userInfo: codableError.userInfo)
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

extension NSError: LocalizedError {
    public var errorDescription: String? {
        self.localizedDescription
    }
    
    public var failureReason: String? {
        self.localizedFailureReason
    }

    public var recoverySuggestion: String? {
        self.localizedRecoverySuggestion
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
