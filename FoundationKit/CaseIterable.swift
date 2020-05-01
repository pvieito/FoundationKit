//
//  CaseIterable.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 30/04/2020.
//  Copyright © 2020 Pedro José Pereira Vieito. All rights reserved.
//

#if canImport(Darwin)
import Foundation

@available(macOS 15.0, *)
@available(iOS 13.0, *)
@available(tvOS 13.0, *)
@available(watchOS 6.0, *)
extension CaseIterable where Self: CustomStringConvertible {
    public init(description: String) throws {
        guard let value = Self.allCases.filter({ $0.description == description }).first else {
            throw NSError(description: "Invalid input value “\(description)”. Valid values are \(Self.allCases.listDescription)")
        }
        
        self = value
    }
}
#endif
