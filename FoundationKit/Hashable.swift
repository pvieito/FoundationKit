//
//  Hashable.swift
//  
//
//  Created by Pedro José Pereira Vieito on 18/3/24.
//

import Foundation

extension Array where Element: Hashable {
    /// Returns the array with duplicates removed.
    public func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    public func dropDuplicates() -> [Element] {
        return self.removingDuplicates()
    }
    
    /// Removes duplicates from the array.
    public mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension Array where Element: Hashable {
    /// Returns the only element in the array only it there is only one element.
    public var onlyElement: Element? {
        guard self.count == 1 else {
            return nil
        }
        return self[0]
    }
    
    /// Returns the unique element in the array only it there is only one unique element.
    public var uniqueElement: Element? {
        return self.removingDuplicates().onlyElement
    }
}

extension Collection where Element: Hashable {
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
