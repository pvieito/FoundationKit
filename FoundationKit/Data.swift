//
//  Data.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 20/10/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Data {
    
    #if canImport(Darwin) || swift(>=4.2)
    
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
            return 0 //UInt8(arc4random() & 0xFF)
            #endif
        }
        
        return Data(bytes: bytes)
    }
    
    #endif
}
