//
//  URL.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 5/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import CoreFoundation

extension URL {

    /// Path Styles for a file URL.
    public enum PathStyle: Int, CustomStringConvertible {
        case posix = 0
        case hfs
        case windows

        fileprivate var cfPathStyle: CFURLPathStyle? {
            return CFURLPathStyle(rawValue: self.rawValue)
        }

        public var description: String {
            switch self {
            case .posix:
                return "POSIX"
            case .hfs:
                return "HFS"
            case .windows:
                return "Windows"
            }
        }
    }

    /// Returns the path of a given URL.
    /// 
    /// This function returns the URL's path as a file system path for a given path style.
    ///
    /// - Parameter style: The operating system path style to be used to create the path.
    /// - Returns: The path in the specified style.
    public func path(style: PathStyle) -> String? {

        guard let cfPathStyle = style.cfPathStyle else {
            return nil
        }

        guard self.isFileURL else {
            return nil
        }

        let path = CFURLCopyFileSystemPath(self as CFURL, cfPathStyle)

        return path as String?
    }
}
