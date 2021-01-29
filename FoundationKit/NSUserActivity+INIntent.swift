//
//  NSUserActivity+INIntent.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 01/05/2020.
//  Copyright © 2020 Pedro José Pereira Vieito. All rights reserved.
//

#if canImport(Intents) && !os(macOS)
import Foundation
import Intents

@available(tvOS 14.0, *)
@available(watchOS 3.2, *)
extension NSUserActivity {
    public func interactionIntent<T>() throws -> T where T: NSObject {
        guard let intent = self.interaction?.intent as? T else {
            let intentClassName = NSStringFromClass(T.self)
            throw NSError(description: "Error reading intent of type “\(intentClassName)” from user activity.")
        }
        
        return intent
    }
}
#endif
