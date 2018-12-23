//
//  URL.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 5/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import CoreFoundation

#if canImport(UIKit)
import UIKit
#elseif canImport(Cocoa)
import Cocoa
#endif

#if os(watchOS)
import WatchKit
#endif

extension URL {
    public enum Error: LocalizedError {
        case openingFailure(URL)
        
        public var errorDescription: String? {
            switch self {
            case .openingFailure(let url):
                return "Error opening URL “\(url.absoluteString)”."
            }
        }
    }
}

extension URL {
    /// Attempts to open the resource at the specified URL asynchronously.
    @available(iOSApplicationExtension, unavailable)
    public func open() throws {
        var success = false
        
        #if os(watchOS)
        WKExtension.shared().openSystemURL(self)
        #elseif canImport(UIKit)
        success = UIApplication.shared.openURL(self)
        #elseif canImport(Cocoa)
        success = NSWorkspace.shared.open(self)
        #endif
        
        if !success {
            throw Error.openingFailure(self)
        }
    }
    
    /// Returns a Boolean value indicating whether an app is available to handle a URL scheme.
    @available(iOSApplicationExtension, unavailable)
    public var isSupported: Bool {
        #if canImport(UIKit) && !os(watchOS)
        return UIApplication.shared.canOpenURL(self)
        #elseif canImport(Cocoa)
        guard let scheme = self.scheme else { return false }
        guard let schemeHandlers =
            LSCopyAllHandlersForURLScheme(scheme as CFString)?.takeRetainedValue() as? [String] else {
            return false
        }
        return !schemeHandlers.isEmpty
        #else
        return false
        #endif
    }
}

extension URL {
    /// Path Styles for a file URL.
    public enum PathStyle: Int, CustomStringConvertible {
        case posix = 0
        case hfs
        case windows
        
        fileprivate var cfPathStyle: CFURLPathStyle? {
            #if canImport(Darwin)
            return CFURLPathStyle(rawValue: self.rawValue)
            #else
            return CFURLPathStyle(self.rawValue)
            #endif
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
        
        #if canImport(Darwin)
        return CFURLCopyFileSystemPath(self as CFURL, cfPathStyle) as String?
        #else
        let cfURL = unsafeBitCast(self, to: CFURL.self)
        let fileSystemPath = CFURLCopyFileSystemPath(cfURL, cfPathStyle)
        
        guard let cfPath = fileSystemPath else {
            return nil
        }
        
        return unsafeBitCast(cfPath, to: NSString.self)._bridgeToSwift()
        #endif
    }
}
