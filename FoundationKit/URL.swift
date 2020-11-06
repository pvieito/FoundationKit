//
//  URL.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 5/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import CoreFoundation

#if canImport(LinkPresentation)
import LinkPresentation
#endif

#if canImport(UIKit)
import UIKit
import MobileCoreServices
#elseif canImport(Cocoa)
import Cocoa
#endif

#if os(watchOS)
import WatchKit
#endif


extension URL {
    enum Error: LocalizedError {
        case openingFailure(URL)
        
        var errorDescription: String? {
            switch self {
            case .openingFailure(let url):
                return "Error opening URL “\(url.absoluteString)”."
            }
        }
    }
}

extension URL {
    public func appendingPathComponents(_ pathComponents: [String]) -> URL {
        var url = self
        for pathComponent in pathComponents {
            url.appendPathComponent(pathComponent)
        }
        return url
    }
    
    public func appendingPathComponents(_ pathComponents: String...) -> URL {
        return self.appendingPathComponents(pathComponents)
    }
    
    public mutating func appendPathComponents(_ pathComponents: [String]) {
        self = self.appendingPathComponents(pathComponents)
    }
    
    public mutating func appendPathComponents(_ pathComponents: String...) {
        self.appendPathComponents(pathComponents)
    }
}

extension URL {
    public var typeIdentifier: String? {
        #if canImport(UIKit) || canImport(Cocoa)
        return UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension, self.pathExtension as CFString, nil)?.takeRetainedValue() as String?
        #else
        return nil
        #endif
    }
    
    public func typeIdentifierConforms(to otherTypeIdentifier: String) -> Bool {
        #if canImport(UIKit) || canImport(Cocoa)
        guard let typeIdentifier = self.typeIdentifier else {
            return false
        }
        
        return UTTypeConformsTo(typeIdentifier as CFString, otherTypeIdentifier as CFString)
        #else
        return false
        #endif
    }
    
    public func typeIdentifierConforms(to otherTypeIdentifiers: [String]) -> Bool {
        for otherTypeIdentifier in otherTypeIdentifiers {
            if self.typeIdentifierConforms(to: otherTypeIdentifier) {
                return true
            }
        }
        
        return false
    }
}

extension URL {
    /// Attempts to open the resource at the specified URL asynchronously.
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @available(watchOSApplicationExtension, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
    public func open() throws {
        #if os(watchOS)
        WKExtension.shared().openSystemURL(self)
        #else
        var success = false

        #if canImport(UIKit)
        success = UIApplication.shared.openURL(self)
        #elseif canImport(Cocoa)
        success = NSWorkspace.shared.open(self)
        #elseif os(Linux)
        let openProcess = try Process(
            executableName: "xdg-open", arguments: [self.absoluteString])
        openProcess.standardOutput = nil
        openProcess.standardError = nil
        try openProcess.runAndWaitUntilExit()
        success = true
        #endif
        
        if !success {
            throw Error.openingFailure(self)
        }
        #endif
    }
    
    /// Returns a Boolean value indicating whether an app is available to handle a URL scheme.
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @available(watchOS, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
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
    
    /// Attempts to reveal the specified URL in a file browser.
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(macCatalyst, unavailable)
    public func reveal() throws {
        #if canImport(Cocoa) && !targetEnvironment(macCatalyst)
        NSWorkspace.shared.activateFileViewerSelecting([self.absoluteURL])
        #else
        throw Error.openingFailure(self)
        #endif
    }
}

extension URL {
    /// Platform path styles for a file URL.
    public enum PlatformPathStyle: Int, CaseIterable, CustomStringConvertible {
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
    
    /// Returns the platform path of a given URL.
    /// 
    /// This function returns the URL's path as a file system path for a given platform path style.
    ///
    /// - Parameter style: The operating system path style to be used to create the path.
    /// - Returns: The path in the specified style.
    public func platformPath(style: PlatformPathStyle) -> String? {
        
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

#if canImport(LinkPresentation) && !os(tvOS)
@available(macOS 10.15, *)
@available(iOS 13, *)
extension URL {
    public func fetchLinkMetadata(timeout: TimeInterval? = nil) throws -> LPLinkMetadata {
        let linkMetadataProvider = LPMetadataProvider()
        
        if let timeout = timeout {
            linkMetadataProvider.timeout = timeout
        }
        
        let defaultError = NSError(description: "Error fetching URL metadata.")
        var result: Result<LPLinkMetadata, Swift.Error> = .failure(defaultError)
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            linkMetadataProvider.startFetchingMetadata(for: self) { (linkMetadata, error) in
                defer {
                    semaphore.signal()
                }
                
                if let error = error {
                    result = .failure(error)
                }
                else if let linkMetadata = linkMetadata {
                    result = .success(linkMetadata)
                }
            }
        }
        semaphore.wait()
        
        return try result.get()
    }
}
#endif
