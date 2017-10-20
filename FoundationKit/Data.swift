//
//  Data.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 20/10/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Data {
    
    @available(*, deprecated, message: "Use Data.random(count:)")
    public init(randomBytesCount count: Int) {
        self = Data.random(count: count)
    }
    
    /// Returns a Data struct with the specified number of random bytes.
    ///
    /// - Parameter count: Number of random bytes.
    public static func random(count: Int) -> Data {
        let bytes = [UInt32](repeating: 0, count: count).map { _ in arc4random() }
        return Data(bytes: bytes, count: count)
    }
}
