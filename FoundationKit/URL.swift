//
//  URL.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 5/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

#if canImport(CoreFoundation)
import CoreFoundation
#endif

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

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
#if canImport(Darwin)
        return UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension, self.pathExtension as CFString, nil)?.takeRetainedValue() as String?
#else
        return nil
#endif
    }
    
    public func typeIdentifierConforms(to otherTypeIdentifier: String) -> Bool {
#if canImport(Darwin)
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

#if canImport(UniformTypeIdentifiers)
@available(iOS 14, *)
@available(macOS 11, *)
@available(watchOS 7, *)
@available(tvOS 14, *)
extension URL {
    public var uniformTypeIdentifier: UTType? {
        guard let typeIdentifier = self.typeIdentifier else { return nil }
        return UTType(typeIdentifier)
    }
    
    public func typeIdentifierConforms(to otherTypeIdentifier: UTType) -> Bool {
        return self.typeIdentifierConforms(to: otherTypeIdentifier.identifier)
    }
    
    public func typeIdentifierConforms(to otherTypeIdentifiers: [UTType]) -> Bool {
        return self.typeIdentifierConforms(to: otherTypeIdentifiers.map(\.identifier))
    }
}
#endif

extension URL {
#if os(macOS)
    @available(*, deprecated, renamed: "open(applicationIdentifier:)")
    public func open(with applicationIdentifier: String) throws {
        try self.open(withAppBundleIdentifier: applicationIdentifier)
    }
#endif
    
    /// Attempts to open the resource at the specified URL asynchronously.
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
    public func open(withAppBundleIdentifier applicationIdentifier: String? = nil) throws {
#if !os(macOS)
        if let applicationIdentifier = applicationIdentifier {
            throw NSError(description: "Opening URL “\(self.absoluteString)” with application “\(applicationIdentifier)” is not supported on this platform.")
        }
#endif
        
#if os(watchOS)
        WKExtension.shared().openSystemURL(self)
#else
        var success = false
        
#if canImport(UIKit)
        let shared: AnyObject? = UIApplication.shared
        if let shared {
            success = shared.openURL(self)
        }
        else {
#if targetEnvironment(macCatalyst)
            success = NSWorkspace._openURL(self)
#endif
        }
#elseif os(macOS)
        if let applicationIdentifier = applicationIdentifier {
            try [self].open(withAppBundleIdentifier: applicationIdentifier)
            success = true
        }
        else {
            success = NSWorkspace.shared.open(self)
        }
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
    public func loadData(options: Data.ReadingOptions? = nil) throws -> Data {
        return try Data(contentsOf: self, options: options ?? .init())
    }
}

#if canImport(CoreFoundation)
extension URL {
    /// Platform path styles for a file URL.
    public enum PlatformPathStyle: Int, CaseIterable, CustomStringConvertible {
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
#endif

#if canImport(LinkPresentation) && !os(tvOS)
@available(macOS 10.15, *)
@available(iOS 13, *)
extension URL {
    public func fetchLinkMetadata(timeout: TimeInterval? = nil) throws -> LPLinkMetadata {
        let linkMetadataProvider = LPMetadataProvider()
        if let timeout = timeout {
            linkMetadataProvider.timeout = timeout
        }
        return try DispatchSemaphore.returningWait { handler in
            linkMetadataProvider.startFetchingMetadata(for: self, completionHandler: handler)
        }
    }
}
#endif

extension Collection where Element == URL {
    /// Returns the first common parent directory of all URLs in the collection.
    @available(macOS 10.11, *)
    public var commonParentDirectory: URL? {
        let stringPaths = self.map({ $0.path })
        
        if self.count == 1, let url = self.first {
            return url.hasDirectoryPath ? url : url.deletingLastPathComponent()
        }
        if var commonPath = stringPaths.reduce(stringPaths.max(), { $0?.commonPrefix(with: $1) }) {
            if commonPath.last != Character(String.slashCharacter) {
                commonPath = commonPath
                    .components(separatedBy: String.slashCharacter)
                    .dropLast()
                    .joined(separator: String.slashCharacter)
            }
            return URL(fileURLWithPath: commonPath)
        }
        else {
            return nil
        }
    }
    
    @available(macOS 10.11, *)
    @available(*, deprecated, renamed: "commonParentDirectory")
    public var commonAntecessor: URL? {
        return self.commonParentDirectory
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

extension Collection where Element == URL {
    public func open() throws {
        var lastError: Error? = nil
        for url in self {
            do {
                try url.open()
            }
            catch {
                lastError = error
            }
        }
        
        if let lastError {
            throw lastError
        }
    }
    
#if os(macOS)
    public func open(withAppBundleIdentifier bundleIdentifier: String) throws {
        guard let bundle = Bundle.applicationBundle(identifier: bundleIdentifier) else {
            throw NSError(description: "Error opening items: application with identifier “\(bundleIdentifier)” not found.")
        }
        try bundle.launchApplicationWith(urls: Array(self))
    }
#endif
}

#if canImport(UIKit)
@objc protocol _URL_UIApplication {
    func openURL(_ url: URL) -> Bool
}
#endif
