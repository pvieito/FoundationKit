//
//  Array.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 14/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Array {

    /// Returns the array with the specified elements appended.
    ///
    /// - Parameter newElements: Elements appended to the returned array.
    /// - Returns: Array with the elements appended.
    public func appending<S>(contentsOf newElements: S) -> Array<Element> where S : Sequence, S.Iterator.Element == Element {
        return self + newElements
    }

    /// Returns the array with the specified element appended.
    ///
    /// - Parameter newElement: Element appended to the returned array.
    /// - Returns: Array with the element appended.
    public func appending(_ newElement: Element) -> Array<Element> {
        return self + [newElement]
    }
}

extension Array where Element: Hashable {
    
    /// The frequency distribution of elements in the array.
    public var frequencies: [Element: Int] {
        return self.reduce([:], { (partialFrequencies, element) -> [Element: Int] in
            var partialFrequencies = partialFrequencies
            partialFrequencies[element] = (partialFrequencies[element] ?? 0) + 1
            return partialFrequencies
        })
    }
    
    /// The most frequent element in the array.
    public var mode: Element? {
        return self.frequencies.max { $0.value < $1.value }?.key
    }
}
