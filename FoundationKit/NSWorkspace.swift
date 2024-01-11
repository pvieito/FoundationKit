//
//  NSWorkspace.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 6/1/24.
//  Copyright © 2024 Pedro José Pereira Vieito. All rights reserved.

#if canImport(Cocoa)
import Foundation
import Cocoa

#if targetEnvironment(macCatalyst)
typealias NSWorkspace = NSObject
#endif

extension NSWorkspace {
    private static var _sharedWorkspace: NSObject? = {
        guard let NSWorkspace: AnyObject = NSClassFromString("NSWorkspace") else { return nil }
        return NSWorkspace.perform(Selector(("sharedWorkspace"))).takeUnretainedValue() as? NSObject
    }()
    
    static func _applicationBundle(identifier: String) -> Bundle? {
        guard let sharedWorkspace = Self._sharedWorkspace else { return nil }
        let urlForApplicationWithBundleIdentifierSelector = NSSelectorFromString("URLForApplicationWithBundleIdentifier:")
        if sharedWorkspace.responds(to: urlForApplicationWithBundleIdentifierSelector),
           let applicationURL = sharedWorkspace.perform(urlForApplicationWithBundleIdentifierSelector, with: identifier).takeUnretainedValue() as? URL,
                let applicationBundle = Bundle(url: applicationURL) {
            return applicationBundle
        }
        return nil
    }
    
    static func _applicationBundle(name: String) -> Bundle? {
        guard let sharedWorkspace = Self._sharedWorkspace else { return nil }
        let fullPathForApplicationSelector = NSSelectorFromString("fullPathForApplication:")
        if sharedWorkspace.responds(to: fullPathForApplicationSelector),
           let path = sharedWorkspace.perform(fullPathForApplicationSelector, with: name).takeUnretainedValue() as? String,
                let applicationBundle = Bundle(path: path) {
            return applicationBundle
        }
        return nil
    }
    
    static func _openURL(_ url: URL) -> Bool {
        guard let sharedWorkspace = Self._sharedWorkspace else { return false }
        let openURLSelector = NSSelectorFromString("openURL:")
        if sharedWorkspace.responds(to: openURLSelector),
           let method = sharedWorkspace.method(for: openURLSelector) {
            typealias NSWorkspace_openURL_function_ = @convention(c) (AnyObject, Selector, NSURL) -> Bool
            let NSWorkspace_openURL_function = unsafeBitCast(method, to: NSWorkspace_openURL_function_.self)
            return NSWorkspace_openURL_function(sharedWorkspace, openURLSelector, url as NSURL)
        }
        return false
    }
}
#endif
