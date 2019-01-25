//
//  Data.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 20/10/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Data {
    public func readingPipe() -> Pipe {
        let pipe = Pipe()
        pipe.fileHandleForWriting.write(self)
        return pipe
    }
}

#if canImport(Darwin) || swift(>=4.2)
extension Data {
    @available(*, deprecated, message: "Use Data.random(count:)")
    public init(randomBytesCount count: Int) {
        self = Data.random(count: count)
    }
    
    /// Returns a Data struct with the specified number of random bytes.
    ///
    /// - Parameter count: Number of random bytes.
    public static func random(count: Int) -> Data {
        let bytes = [UInt8](repeating: 0, count: count).map { _ -> UInt8 in
            #if swift(>=4.2)
            return UInt8.random(in: .min ... .max)
            #else
            return UInt8(arc4random() & 0xFF)
            #endif
        }
        return Data(bytes: bytes)
    }
}
#endif

fileprivate let hexadecimalConversionArray: [[UInt8]] = [
    [48, 48], [48, 49], [48, 50], [48, 51], [48, 52], [48, 53],
    [48, 54], [48, 55], [48, 56], [48, 57], [48, 97], [48, 98],
    [48, 99], [48, 100], [48, 101], [48, 102], [49, 48], [49, 49],
    [49, 50], [49, 51], [49, 52], [49, 53], [49, 54], [49, 55],
    [49, 56], [49, 57], [49, 97], [49, 98], [49, 99], [49, 100],
    [49, 101], [49, 102], [50, 48], [50, 49], [50, 50], [50, 51],
    [50, 52], [50, 53], [50, 54], [50, 55], [50, 56], [50, 57],
    [50, 97], [50, 98], [50, 99], [50, 100], [50, 101], [50, 102],
    [51, 48], [51, 49], [51, 50], [51, 51], [51, 52], [51, 53],
    [51, 54], [51, 55], [51, 56], [51, 57], [51, 97], [51, 98],
    [51, 99], [51, 100], [51, 101], [51, 102], [52, 48], [52, 49],
    [52, 50], [52, 51], [52, 52], [52, 53], [52, 54], [52, 55],
    [52, 56], [52, 57], [52, 97], [52, 98], [52, 99], [52, 100],
    [52, 101], [52, 102], [53, 48], [53, 49], [53, 50], [53, 51],
    [53, 52], [53, 53], [53, 54], [53, 55], [53, 56], [53, 57],
    [53, 97], [53, 98], [53, 99], [53, 100], [53, 101], [53, 102],
    [54, 48], [54, 49], [54, 50], [54, 51], [54, 52], [54, 53],
    [54, 54], [54, 55], [54, 56], [54, 57], [54, 97], [54, 98],
    [54, 99], [54, 100], [54, 101], [54, 102], [55, 48], [55, 49],
    [55, 50], [55, 51], [55, 52], [55, 53], [55, 54], [55, 55],
    [55, 56], [55, 57], [55, 97], [55, 98], [55, 99], [55, 100],
    [55, 101], [55, 102], [56, 48], [56, 49], [56, 50], [56, 51],
    [56, 52], [56, 53], [56, 54], [56, 55], [56, 56], [56, 57],
    [56, 97], [56, 98], [56, 99], [56, 100], [56, 101], [56, 102],
    [57, 48], [57, 49], [57, 50], [57, 51], [57, 52], [57, 53],
    [57, 54], [57, 55], [57, 56], [57, 57], [57, 97], [57, 98],
    [57, 99], [57, 100], [57, 101], [57, 102], [97, 48], [97, 49],
    [97, 50], [97, 51], [97, 52], [97, 53], [97, 54], [97, 55],
    [97, 56], [97, 57], [97, 97], [97, 98], [97, 99], [97, 100],
    [97, 101], [97, 102], [98, 48], [98, 49], [98, 50], [98, 51],
    [98, 52], [98, 53], [98, 54], [98, 55], [98, 56], [98, 57],
    [98, 97], [98, 98], [98, 99], [98, 100], [98, 101], [98, 102],
    [99, 48], [99, 49], [99, 50], [99, 51], [99, 52], [99, 53],
    [99, 54], [99, 55], [99, 56], [99, 57], [99, 97], [99, 98],
    [99, 99], [99, 100], [99, 101], [99, 102], [100, 48], [100, 49],
    [100, 50], [100, 51], [100, 52], [100, 53], [100, 54], [100, 55],
    [100, 56], [100, 57], [100, 97], [100, 98], [100, 99], [100, 100],
    [100, 101], [100, 102], [101, 48], [101, 49], [101, 50], [101, 51],
    [101, 52], [101, 53], [101, 54], [101, 55], [101, 56], [101, 57],
    [101, 97], [101, 98], [101, 99], [101, 100], [101, 101], [101, 102],
    [102, 48], [102, 49], [102, 50], [102, 51], [102, 52], [102, 53],
    [102, 54], [102, 55], [102, 56], [102, 57], [102, 97], [102, 98],
    [102, 99], [102, 100], [102, 101], [102, 102]
]

extension Data {
    /// Hexadecimal representation of the Data as a String.
    public var hexString: String {
        
        guard !self.isEmpty else {
            return ""
        }
        
        return "0x" + String(data: self.hexData, encoding: .ascii)!.uppercased()
    }
    
    /// Hexadecimal representation of the Data as Data encoded in ASCII.
    public var hexData: Data {
        
        return self.reduce(Data()) { (hexData, byte) -> Data in
            return hexData + hexadecimalConversionArray[Int(byte)]
        }
    }
    
    /// Initializes a Data struct with a hexadecimal string.
    ///
    /// - Note: The hexadecimal string must have an even number of characters and can start with the optional prefix `0x`.
    ///
    /// - Parameter hexString: Hexadecimal string.
    public init?(hexString: String) {
        var hexString = hexString
        guard !hexString.isEmpty else {
            return nil
        }
        if hexString.hasPrefix("0x") {
            hexString = String(hexString.dropFirst(2))
        }
        if hexString.utf16.count % 2 != 0 {
            hexString = "0" + hexString
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
            }
            else if (0x61...0x66).contains(i) {
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
}
