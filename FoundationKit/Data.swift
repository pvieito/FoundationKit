//
//  Data.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 7/6/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Data {

    /// Hexadecimal representation.
    public var hexString: String {
        return "0x" + self.flatMap { String(format: "%02X", $0) }
    }

    /// Initializes a Data struct with the hexadecimal string.
    ///
    /// - Note: The hexadecimal string must have an even number of characters and can start with the optional prefix `0x`.
    ///
    /// - Parameter hexString: Hexadecimal string.
    public init?(hexString: String) {

        guard !hexString.isEmpty else {
            return nil
        }

        guard hexString.utf16.count % 2 == 0 else {
            return nil
        }

        var hexString = hexString

        if hexString.hasPrefix("0x") {
            hexString = String(hexString.dropFirst(2))
        }

        self.init()

        var currentByte: UInt8 = 0
        var highBits = true

        for i in hexString.lowercased().utf16 {
            guard (0x30...0x39).contains(i) || (0x61...0x66).contains(i) else {
                return nil
            }
            if (0x30...0x39).contains(i) {
                if highBits {
                    currentByte = UInt8(i - 0x30) << 4
                    highBits = false
                } else {
                    currentByte += UInt8(i - 0x30)
                    highBits = true
                    self.append(currentByte)
                }
            } else if (0x61...0x66).contains(i) {
                if highBits {
                    currentByte = UInt8(i - 0x61 + 10) << 4
                    highBits = false
                } else {
                    currentByte += UInt8(i - 0x61 + 10)
                    highBits = true
                    self.append(currentByte)
                }
            }
        }
    }

    /// Initializes a Data struct with the specified number of random bytes.
    ///
    /// - Parameter count: Number of random bytes.
    public init(randomBytes count: Int) {
        let bytes = [UInt32](repeating: 0, count: count).map { _ in arc4random() }
        self.init(bytes: bytes, count: count)
    }
}
