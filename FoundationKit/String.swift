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
    /// - Parameter withMaximumLength: Maximum length of each component.
    /// - Returns: Array of string components.
    public func components(withMaximumLength: Int) -> [String] {
        if self.characters.count == 0 {
            return [self]
        }
        else {
            return stride(from: 0, to: self.characters.count, by: withMaximumLength).map { i -> String in
                let startIndex = self.index(self.startIndex, offsetBy: i)
                let endIndex = self.index(startIndex, offsetBy: withMaximumLength, limitedBy: self.endIndex) ?? self.endIndex
                return String(self[startIndex..<endIndex])
            }
        }
    }

    /// Returns the string abbreviated with a maximum length.
    ///
    /// - Parameter withMaximumLength: Maximum length of the returned string.
    /// - Returns: Abbreviated string.
    public func abbreviated(withMaximumLength: Int) -> String {
        let stringComponents = self.components(withMaximumLength: withMaximumLength)

        return (stringComponents.count > 1 ? stringComponents.first?.appending("…") : stringComponents.first) ?? self
    }

    /// Returns the string with a lossy conversion to ASCII.
    public var asciiString: String? {
        if let lossyAsciiData = self.data(using: .ascii, allowLossyConversion: true), let asciiString = String(data: lossyAsciiData, encoding: .ascii) {
            return asciiString
        }
        return nil
    }

    /// Returns the a Camel Case string converted to Title Case.
    ///
    /// For example it will be "Camel Case" for "camelCase".
    public var decamelizedString: String {
        var inputString: String = self

        var outputString: String = ""

        if let firstUnicodeScalar = self.unicodeScalars.first,
            CharacterSet.uppercaseLetters.contains(firstUnicodeScalar),
            let firstCharacter = self.characters.first {
            inputString.remove(at: inputString.startIndex)
            inputString.insert(contentsOf: String(firstCharacter).lowercased().characters, at: inputString.startIndex)
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
            let firstCharacter = outputString.characters.first {
            outputString.remove(at: outputString.startIndex)
            outputString.insert(contentsOf: String(firstCharacter).uppercased().characters, at: inputString.startIndex)
        }

        return outputString
    }

    /// Returns URL with String as the path.
    public var pathURL: URL {
        return URL(fileURLWithPath: self)
    }
}
