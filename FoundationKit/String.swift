//
//  String.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 17/2/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension String {
    /// Returns an array of components of the string with a maximum length each.
    ///
    /// - Parameter length: Maximum length of each component.
    /// - Returns: Array of string components.
    public func components(of length: Int) -> [String] {
        guard length > 0 else {
            return []
        }
        
        if self.isEmpty {
            return [""]
        }
        else {
            return stride(from: 0, to: self.count, by: length).map { i -> String in
                let startIndex = self.index(self.startIndex, offsetBy: i)
                let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
                return String(self[startIndex..<endIndex])
            }
        }
    }

    /// Returns the string abbreviated with a maximum length.
    ///
    /// - Parameter length: Maximum length of the returned string.
    /// - Returns: Abbreviated string.
    public func abbreviated(to length: Int) -> String {
        guard self.count > length else {
            return self
        }
        
        guard length > 0 else {
            return ""
        }
        
        let components = self.components(of: length - 1)
        let ellipsis = "…"
        
        guard let abbreviatedString = components.first else {
            return ellipsis
        }
        return abbreviatedString.trimmingCharacters(in: .whitespacesAndNewlines).appending(ellipsis)
    }

    /// Returns the string with a lossy conversion to ASCII.
    public var asciiString: String? {
        if let lossyAsciiData = self.data(using: .ascii, allowLossyConversion: true), let asciiString = String(data: lossyAsciiData, encoding: .ascii) {
            return asciiString
        }
        return nil
    }
    
    /// True if all string characters are ASCII.
    public var isASCII: Bool {
        return self.allSatisfy { $0.isASCII }
    }

    /// Returns a Camel Case string converted to Title Case.
    ///
    /// For example it will be "Camel Case" for "camelCase".
    public var decamelized: String {
        var inputString: String = self
        var outputString: String = ""

        if let firstUnicodeScalar = self.unicodeScalars.first,
            CharacterSet.uppercaseLetters.contains(firstUnicodeScalar),
            let firstCharacter = self.first {
            inputString.remove(at: inputString.startIndex)
            inputString.insert(contentsOf: String(firstCharacter).lowercased(), at: inputString.startIndex)
        }

        let upperCase = CharacterSet.uppercaseLetters
        for scalar in inputString.unicodeScalars {
            if upperCase.contains(scalar) {
                outputString.append(" ")
            }

            let character = Character(scalar)
            outputString.append(character)
        }

        if let firstUnicodeScalar = outputString.unicodeScalars.first,
            CharacterSet.lowercaseLetters.contains(firstUnicodeScalar),
            let firstCharacter = outputString.first {
            outputString.remove(at: outputString.startIndex)
            outputString.insert(contentsOf: String(firstCharacter).uppercased(), at: inputString.startIndex)
        }

        return outputString
    }
    
    /// Returns same string if not empty, else nil.
    public var nonEmptyString: String? {
        guard !self.isEmpty else {
            return nil
        }
        return self
    }
}

extension String {
    /// Returns a file URL with the string as the path.
    public var pathURL: URL {
        return URL(fileURLWithPath: self)
    }
    
    /// Returns a generic URL composed from the string.
    public var genericURL: URL? {
        return URL(string: self)
    }
    
    /// Returns a file URL if a file exists at the path or a generic URL otherwise.
    public var resourceURL: URL? {
        return FileManager.default.fileExists(atPath: self) ? self.pathURL : self.genericURL
    }
}

extension String {
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
