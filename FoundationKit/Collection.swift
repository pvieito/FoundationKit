//
//  Collection.swift
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

extension Collection where Element == URL {
    /// Returns the first common parent directory of all URLs in the array.
    @available(macOS 10.11, *)
    public var commonAntecessor: URL? {
        
        let stringPaths = self.map({ $0.path })
        
        if self.count == 1, let url = self.first {
            return url.hasDirectoryPath ? url : url.deletingLastPathComponent()
        }
        if var commonPath = stringPaths.reduce(stringPaths.max(), { $0?.commonPrefix(with: $1) }) {
            if commonPath.last != "/" {
                commonPath = commonPath.components(separatedBy: "/").dropLast().joined(separator: "/")
            }
            return URL(fileURLWithPath: commonPath)
        }
        else {
            return nil
        }
    }
    
    /// Returns the URL paths ordered by their last path component.
    public var alphabeticallyOrdered: [URL] {
        return self.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
    
    /// Return the path of each URL in the array.
    public var paths: [String] {
        return self.map({ $0.path })
    }
    
    /// Return the last path component of each URL in the array.
    public var lastPathComponents: [String] {
        return self.map({ $0.lastPathComponent })
    }
}

extension Collection where Element == String {
    /// Returns array of URLs with the Strings as the paths.
    public var pathURLs: [URL] {
        return self.map({ $0.pathURL })
    }
    
    /// Returns array of URLs intialized with the valid Strings.
    public var validURLs: [URL] {
        return self.compactMap {
            return FileManager.default.fileExists(atPath: $0) ? URL(fileURLWithPath: $0) : URL(string: $0)
        }
    }
}
