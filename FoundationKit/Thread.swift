//
//  Thread.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 8/9/20.
//  Copyright © 2020 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Thread {
    @available(*, deprecated, renamed: "runSynchronouslyOnMainThread(block:)")
    public static func runSychronouslyOnMainThread(block: (() -> ())) {
        return runSynchronouslyOnMainThread(block: block)
    }
    
    public static func runSynchronouslyOnMainThread(block: (() -> ())) {
        if Thread.current.isMainThread {
            block()
        }
        else {
            DispatchQueue.main.sync {
                block()
            }
        }
    }
}
