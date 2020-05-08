//
//  UUID.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 25/10/2018.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension UUID {
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
}
