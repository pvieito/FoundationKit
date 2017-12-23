//
//  String+RegularExpressions.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 31/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

#if !os(Linux)
public extension String {
    
    /// NSRange of the full string.
    private var fullRange: NSRange {
        return NSRange(self.startIndex..<self.endIndex, in: self)
    }

    /// Returns the String with the subsitutions applied.
    ///
    /// - Parameters:
    ///   - pattern: Regular Expression to match.
    ///   - sustitution: Substitution to apply.
    /// - Returns: String with the Regular Expression subsitution applied.
    public func applyingRegularExpression(pattern: String, sustitution: String) -> String {
        
        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        return regex?.stringByReplacingMatches(in: self, options: [], range: self.fullRange, withTemplate: sustitution) ?? self
    }

    /// True if the string has some Regular Expression match.
    ///
    /// - Parameters:
    ///   - pattern: Regular Expression to match.
    /// - Returns: A boolean indicating if there is some match.
    public func matchesRegularExpression(pattern: String) -> Bool {

        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        return !(regex?.matches(in: self, options: [], range: self.fullRange) ?? []).isEmpty
    }

    /// Resulting matches of a Regular Expression applied to the String.
    ///
    /// - Parameters:
    ///   - pattern: Regular Expression to match.
    /// - Returns: The resulting matches.
    public func matchesForRegularExpression(pattern: String) -> [NSTextCheckingResult] {

        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        return regex?.matches(in: self, options: [], range: self.fullRange) ?? []
    }
}
#endif
