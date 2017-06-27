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

    /// Returns the String with the subsitutions applied.
    ///
    /// - Parameters:
    ///   - pattern: Regular Expression to match.
    ///   - sustitution: Substitution to apply.
    /// - Returns: String with the Regular Expression subsitution applied.
    public func applyingRegularExpression(pattern: String, sustitution: String) -> String {
        let range = NSMakeRange(0, self.characters.count)
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: sustitution) ?? self
    }

    /// True if the string has some Regular Expression match.
    ///
    /// - Parameters:
    ///   - pattern: Regular Expression to match.
    /// - Returns: A boolean indicating if there is some match.
    public func matchesRegularExpression(pattern: String) -> Bool {
        let range = NSMakeRange(0, self.characters.count)

        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        return !(regex?.matches(in: self, options: [], range: range) ?? []).isEmpty
    }

    /// Resulting matches of a Regular Expression applied to the String.
    ///
    /// - Parameters:
    ///   - pattern: Regular Expression to match.
    /// - Returns: The resulting matches.
    public func matchesForRegularExpression(pattern: String) -> [NSTextCheckingResult] {
        let range = NSMakeRange(0, self.characters.count)

        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        return regex?.matches(in: self, options: [], range: range) ?? []
    }
}
#endif
