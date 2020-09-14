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

extension Array where Element: Hashable {
    /// Returns the array with duplicates removed.
    public func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    /// Removes duplicates from the array.
    public mutating func removeDuplicates() {
        self = self.removingDuplicates()
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
    /// Returns array of file URLs intialized from the strings.
    public var pathURLs: [URL] {
        return self.map { $0.pathURL }
    }
    
    /// Returns array of generic URLs intialized from the strings, removing invalid entries.
    public var genericURLs: [URL] {
        return self.compactMap { $0.genericURL }
    }
    
    /// Returns array of resource URLs intialized from the strings, removing invalid entries.
    public var resourceURLs: [URL] {
        return self.compactMap { $0.resourceURL }
    }

    @available(*, deprecated, renamed: "resourceURLs")
    public var validURLs: [URL] {
        return self.resourceURLs
    }
}

extension Collection where Element: StringProtocol {
    public func joiningLines() -> String {
        return self.joined(separator: "\n")
    }
}

#if canImport(Darwin)
@available(macOS 10.15, *)
@available(iOS 13.0, *)
@available(tvOS 13.0, *)
@available(watchOS 6.0, *)
extension Collection where Element: CustomStringConvertible {
    public var listDescription: String {
        return ListFormatter.localizedString(byJoining: self.map({ $0.description }))
    }
    
    public var quotedListDescription: String {
        return ListFormatter.localizedString(byJoining: self.map({ "“\($0.description)”" }))
    }
}
#endif
