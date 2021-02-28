//
//  UUID.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 25/10/2018.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

#if canImport(CryptoKit)
import CryptoKit
#endif

extension UUID {
    public static func random() -> UUID {
        return UUID()
    }
    
    public static var zero: UUID {
        let uuid: uuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        return UUID(uuid: uuid)
    }
    
    public init?(data: Data) {
        guard data.count == 16 else {
            return nil
        }
        
        let uuid: uuid_t = (
            data[0],
            data[1],
            data[2],
            data[3],
            data[4],
            data[5],
            data[6],
            data[7],
            data[8],
            data[9],
            data[10],
            data[11],
            data[12],
            data[13],
            data[14],
            data[15])
        self.init(uuid: uuid)
    }
    
    public var data: Data {
        return Data([
            self.uuid.0,
            self.uuid.1,
            self.uuid.2,
            self.uuid.3,
            self.uuid.4,
            self.uuid.5,
            self.uuid.6,
            self.uuid.7,
            self.uuid.8,
            self.uuid.9,
            self.uuid.10,
            self.uuid.11,
            self.uuid.12,
            self.uuid.13,
            self.uuid.14,
            self.uuid.15,
        ])
    }
}

#if canImport(CryptoKit)
@available(macOS 10.15, *)
@available(iOS 13, *)
@available(tvOS 13, *)
@available(watchOS 6, *)
extension UUID {
    public init(hashing string: String) {
        self.init(hashing: Data(string.utf8))
    }
    
    public init(hashing data: Data) {
        let hashedData = Data(Insecure.MD5.hash(data: data))
        self.init(data: hashedData)!
    }
}
#endif
