//
//  INIntentType.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 01/05/2020.
//  Copyright © 2020 Pedro José Pereira Vieito. All rights reserved.
//

#if canImport(Intents)
import Foundation
import Intents

public protocol INIntentType {
    var intentClass: AnyClass { get }
}

extension INIntentType {
    public var intentClassName: String {
        return NSStringFromClass(self.intentClass)
    }
}

@available(tvOS 14.0, *)
@available(macOS 11.0, *)
@available(watchOS 3.2, *)
extension INIntentType where Self: CaseIterable {
    public init?(intent: INIntent) {
        for intentType in Self.allCases {
            if type(of: intent) === intentType.intentClass {
                self = intentType
                return
            }
        }
        
        return nil
    }
}

extension INIntentType where Self: RawRepresentable, Self.RawValue == String {
    public var intentClassName: String {
        return self.rawValue
    }
}
#endif
