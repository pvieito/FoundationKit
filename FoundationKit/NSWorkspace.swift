//
//  NSWorkspace.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 6/1/24.
//  Copyright © 2024 Pedro José Pereira Vieito. All rights reserved.

#if canImport(Cocoa)
import Foundation
import Cocoa

typealias NSWorkspace = NSObject

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
    
    static func _openURL(_ url: URL) -> Bool {
        guard let sharedWorkspace = Self._sharedWorkspace else { return false }
        let openURLSelector = NSSelectorFromString("openURL:")
        if sharedWorkspace.responds(to: openURLSelector),
           let success = sharedWorkspace.perform(openURLSelector, with: url).takeUnretainedValue() as? Bool {
            return success
        }
        return false
    }
}
#endif
