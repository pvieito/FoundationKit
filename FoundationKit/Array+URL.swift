//
//  ArrayURL.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 27/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Array where Element == URL {

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
