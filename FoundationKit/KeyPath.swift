//
//  KeyPath.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 9/1/21.
//  Copyright © 2021 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

public prefix func !<T>(keyPath: KeyPath<T, Bool>) -> (T) -> Bool {
    return { !$0[keyPath: keyPath] }
}

public func ==<T, V: Equatable>(lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    return { $0[keyPath: lhs] == rhs }
}
