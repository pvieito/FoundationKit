//
//  Collection.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 14/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Collection {
    public func compact<T>() -> [T] where Element == Optional<T> {
        return self.compactMap { $0 }
    }
    
    public var nonEmptyCollection: Self? {
        return self.isEmpty ? nil : self
    }
    
    public var hasContent: Bool {
        return !self.isEmpty
    }
}

extension Array {
    /// Returns the array with the specified elements appended.
    ///
    /// - Parameter newElements: Elements appended to the returned array.
    /// - Returns: Array with the elements appended.
    public func appending<S>(contentsOf newElements: S) -> Self
        where S : Sequence, S.Iterator.Element == Element {
            return self + newElements
    }
    
    /// Returns the array with the specified element appended.
    ///
    /// - Parameter newElement: Element appended to the returned array.
    /// - Returns: Array with the element appended.
    public func appending(_ newElement: Element) -> Self {
        return self + [newElement]
    }
}

extension Collection {
    /// Get element at index, if any.
    public func get(elementAt index: Index) -> Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}
