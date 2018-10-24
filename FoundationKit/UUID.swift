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
}
