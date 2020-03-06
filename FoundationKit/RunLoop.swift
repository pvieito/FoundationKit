//
//  RunLoop.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 07/03/2020.
//  Copyright © 2020 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension RunLoop {
    public func stop() {
        CFRunLoopStop(self.getCFRunLoop())
    }
}
