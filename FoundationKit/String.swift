//
//  String.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 17/2/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

public extension String {

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

    /// Returns URL with String as the path.
    public var pathURL: URL {
        return URL(fileURLWithPath: self)
    }
    
    /// Returns same string if not empty, else nil.
    public var nonEmptyString: String? {
        guard !self.isEmpty else {
            return nil
        }
        
        return self
    }
}
