//
//  String.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 17/2/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension String {
    public static let empty = ""
    public static let spaceCharacter = " "
    public static let ellipsisCharacter = "…"
    public static let newLineCharacter = "\n"
    public static let slashCharacter = "/"
    public static let dashCharacter = "-"
    
    /// Returns an array of components of the string with a maximum length each.
    ///
    /// - Parameter length: Maximum length of each component.
    /// - Returns: Array of string components.
    public func components(of length: Int) -> [String] {
        guard length > 0 else {
            return []
        }
        
        if self.isEmpty {
            return [Self.empty]
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
            return Self.empty
        }
        
        let components = self.components(of: length - 1)
        let ellipsis = Self.ellipsisCharacter
        
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
        var outputString: String = Self.empty
        
        if let firstUnicodeScalar = self.unicodeScalars.first,
           CharacterSet.uppercaseLetters.contains(firstUnicodeScalar),
           let firstCharacter = self.first {
            inputString.remove(at: inputString.startIndex)
            inputString.insert(contentsOf: String(firstCharacter).lowercased(), at: inputString.startIndex)
        }
        
        let upperCase = CharacterSet.uppercaseLetters
        for scalar in inputString.unicodeScalars {
            if upperCase.contains(scalar) {
                outputString.append(Self.spaceCharacter)
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
        self.nonEmptyCollection
    }
    
    public func trimmingWhitespacesAndNewlines() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension String {
    public var characters: Array<Character> {
        return Array<Character>(self)
    }
}

extension String {
    public var utf8Data: Data {
        return Data(self.utf8)
    }
}

extension String {
    public static func spaces(count: Int) -> String {
        return Array(repeating: Self.spaceCharacter, count: count).joined()
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
    public var fullRange: NSRange {
        return NSRange(self.startIndex..<self.endIndex, in: self)
    }
    
    /// Returns the String with the substitutions applied.
    ///
    /// - Parameters:
    ///   - pattern: Regular Expression to match.
    ///   - substitution: Substitution to apply.
    /// - Returns: String with the Regular Expression substitution applied.
    public func applyingRegularExpression(pattern: String, substitution: String) -> String {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        return regex?.stringByReplacingMatches(in: self, options: [], range: self.fullRange, withTemplate: substitution) ?? self
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

extension String {
    // [offset]
    public subscript(offset offset: Int) -> Character {
        let index = self.index(offset: offset)
        return self[index]
    }

    // [offset.lowerBound..<offset.upperBound]
    public subscript(offset offset: Range<Int>) -> String {
        let i = self.index(offset: offset.lowerBound)
        let j = self.index(offset: offset.upperBound)
        return String(self[i..<j])
    }

    // [offset.lowerBound...offset.upperBound]
    public subscript(offset offset: ClosedRange<Int>) -> String {
        let i = self.index(offset: offset.lowerBound)
        let j = self.index(offset: offset.upperBound)
        return String(self[i...j])
    }

    // [..<offset.upperBound]
    public subscript(offset offset: PartialRangeUpTo<Int>) -> String {
        let i = self.index(offset: offset.upperBound)
        return String(self[..<i])
    }

    // [...offset.upperBound]
    public subscript(offset offset: PartialRangeThrough<Int>) -> String {
        let i = self.index(offset: offset.upperBound)
        return String(self[...i])
    }

    // [offset.lowerBound...]
    public subscript(offset offset: PartialRangeFrom<Int>) -> String {
        let i = self.index(offset: offset.lowerBound)
        return String(self[i...])
    }
}

extension String {
    private func index(offset: Int) -> String.Index {
        if offset >= 0 {
            return self.index(self.startIndex, offsetBy: offset)
        }
        else {
            return self.index(self.endIndex, offsetBy: offset)
        }
    }
}

extension String {
    private static var quotationDelimiters: (String, String) {
        guard
            let quotationBeginDelimiter = Locale.current.quotationBeginDelimiter,
            let quotationEndDelimiter = Locale.current.quotationEndDelimiter
            else { return ("\"", "\"") }
        return (quotationBeginDelimiter, quotationEndDelimiter)
    }

    /// Returns a quoted string.
    public var quoted: String {
        return Self.quotationDelimiters.0 + self + Self.quotationDelimiters.1
    }
}

extension String {
    public static func starsRating(value: Int, padding: Bool = true, maximum: Int = 5) -> String {
        var starsRating = String(repeating: "★", count: value)
        if padding {
            starsRating += String(repeating: "☆", count: (maximum - value))
        }
        return starsRating
    }
}

extension Optional where Wrapped == String {
    /// Returns a valid string with the content of Optional or a dash.
    public var optional: String {
        return self ?? String.dashCharacter
    }
    
    /// Returns a valid quoted string with the content of Optional or a dash.
    public var quotedOptional: String {
        return self?.quoted ?? String.dashCharacter
    }
}

extension Collection where Element == String {
    /// Returns array of file URLs initialized from the strings.
    public var pathURLs: [URL] {
        return self.map { $0.pathURL }
    }
    
    /// Returns array of generic URLs initialized from the strings, removing invalid entries.
    public var genericURLs: [URL] {
        return self.compactMap { $0.genericURL }
    }
    
    /// Returns array of resource URLs initialized from the strings, removing invalid entries.
    public var resourceURLs: [URL] {
        return self.compactMap { $0.resourceURL }
    }

    @available(*, deprecated, renamed: "resourceURLs")
    public var validURLs: [URL] {
        return self.resourceURLs
    }
}

extension Collection where Element: StringProtocol {
    public func joiningLines() -> String {
        return self.joined(separator: .newLineCharacter)
    }
    
    public func joinedWithSpaces() -> String {
        return self.joined(separator: .spaceCharacter)
    }
}

#if canImport(Darwin)
@available(macOS 10.15, *)
@available(iOS 13.0, *)
@available(tvOS 13.0, *)
@available(watchOS 6.0, *)
extension Collection where Element == String {
    public var listDescription: String {
        return ListFormatter.localizedString(byJoining: self.map({ $0 }))
    }
    
    public var quotedListDescription: String {
        return ListFormatter.localizedString(byJoining: self.map({ "“\($0)”" }))
    }
}

@available(macOS 10.15, *)
@available(iOS 13.0, *)
@available(tvOS 13.0, *)
@available(watchOS 6.0, *)
extension Collection where Element: CustomStringConvertible {
    public var listDescription: String {
        return self.map(\.description).listDescription
    }
    
    public var quotedListDescription: String {
        return self.map(\.description).quotedListDescription
    }
}
#endif
