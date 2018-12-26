//
//  Error.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 14/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Error {
    
    /// NSError with localized description from a Swift native LocalizedError.
    public var cocoaError: NSError {
        let userInfo = [
            NSLocalizedFailureReasonErrorKey: self.localizedDescription,
            NSLocalizedDescriptionKey: self.localizedDescription
        ]
        return NSError(domain: NSCocoaErrorDomain, code: -1, userInfo: userInfo)
    }
}
