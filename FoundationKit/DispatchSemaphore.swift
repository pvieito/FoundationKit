//
//  DispatchSemaphore.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 4/1/21.
//  Copyright © 2021 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation


extension DispatchSemaphore {
    private static func zero() -> DispatchSemaphore {
        return DispatchSemaphore(value: 0)
    }
    
    public static func wait(block: (@escaping (Error?) -> ()) -> ()) throws {
        let semaphore = DispatchSemaphore.zero()
        var error: Error?
        let completionHandler = { (handlerError: Error?) in
            error = handlerError
            semaphore.signal()
        }
        block(completionHandler)
        semaphore.wait()
        if let error = error {
            throw error
        }
    }
}
