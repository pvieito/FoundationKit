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
    
    public static func wait(block: (@escaping () -> ()) -> ()) {
        try! self.throwingWait { handler in
            let completionHandler = {
                handler(nil)
            }
            block(completionHandler)
        }
    }
    
    public static func throwingWait(block: (@escaping (Error?) -> ()) -> ()) throws {
        try self.returningWait { (handler: (@escaping (Void?, Error?) -> ())) in
            let completionHandler = { (handlerError: Error?) in
                handler((), handlerError)
            }
            block(completionHandler)
        }
    }
    
    @discardableResult
    public static func returningWait<T>(block: (@escaping (T?, Error?) -> ()) -> ()) throws -> T {
        let semaphore = DispatchSemaphore.zero()
        var error: Error?
        var result: T?
        let completionHandler = { (handlerResult: T?, handlerError: Error?) in
            error = handlerError
            result = handlerResult
            semaphore.signal()
        }
        block(completionHandler)
        semaphore.wait()
        if let error = error {
            throw error
        }
        else if let result = result {
            return result
        }
        else {
            throw NSError(description: "No result found in block.")
        }
    }
}
