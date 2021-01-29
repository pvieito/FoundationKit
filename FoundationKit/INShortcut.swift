//
//  INShortcut.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 29/1/21.
//  Copyright © 2021 Pedro José Pereira Vieito. All rights reserved.
//

#if canImport(Intents) && !os(watchOS) && !os(tvOS)
import Foundation
import Intents

@available(macOS 11.0, *)
extension INShortcut {
    private static let shortcutsApplicationScheme = "shortcuts"
    private static var shortcutsApplicationURLBaseComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = self.shortcutsApplicationScheme
        return urlComponents
    }
    
    private static var shortcutsApplicationLaunchURL: URL {
        return shortcutsApplicationURLBaseComponents.url!
    }

    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
    public static var isShortcutsApplicationAvailable: Bool {
        if UserDefaults.standard.bool(forKey: "com.pvieito.UIXKit.INShortcut.SimulateShortcutsSupport") {
            return true
        }
        return shortcutsApplicationLaunchURL.isSupported
    }
    
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
    public static func enforceShortcutsApplicationAvailability() throws {
        guard self.isShortcutsApplicationAvailable else {
            throw NSError(description: "Shortcuts is not available on this platform.")
        }
    }
}

@available(macOS 11.0, *)
extension INShortcut {
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
    public static func launchShortcutsApplication() throws {
        try self.shortcutsApplicationLaunchURL.openEnforcingShortcutsApplicationAvailability()
    }
    
    private static var shortcutsApplicationCreateShortcutURL: URL {
        var urlComponents = self.shortcutsApplicationURLBaseComponents
        urlComponents.host = "create-shortcut"
        return urlComponents.url!
    }
    
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
    public static func launchShortcutsApplicationCreatingShortcut() throws {
        try self.shortcutsApplicationCreateShortcutURL.openEnforcingShortcutsApplicationAvailability()
    }
    
    private static func shortcutsApplicationOpenShortcutURL(shortcutName: String) -> URL {
        var urlComponents = self.shortcutsApplicationURLBaseComponents
        urlComponents.host = "open-shortcut"
        urlComponents.queryItems = [URLQueryItem(name: "name", value: shortcutName)]
        return urlComponents.url!
    }
    
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
    public static func launchShortcutsApplicationOpeningShortcut(shortcutName: String) throws {
        try self.shortcutsApplicationOpenShortcutURL(shortcutName: shortcutName).openEnforcingShortcutsApplicationAvailability()
    }
}

@available(macOS 11.0, *)
extension INShortcut {
    public enum RunShortcutInput {
        case input(text: String)
        case clipboard
        
        var queryItems: [URLQueryItem] {
            switch self {
            case .input(text: let text):
                return [
                    URLQueryItem(name: "input", value: "text"),
                    URLQueryItem(name: "text", value: text)
                ]
            case .clipboard:
                return [URLQueryItem(name: "input", value: "clipboard")]
            }
        }
    }
    
    private static func shortcutsApplicationRunShortcutURL(shortcutName: String, input: RunShortcutInput? = nil) -> URL {
        var urlComponents = self.shortcutsApplicationURLBaseComponents
        urlComponents.host = "run-shortcut"
        var queryItems = [URLQueryItem(name: "name", value: shortcutName)]
        if let input = input {
            queryItems += input.queryItems
        }
        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }

    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
    public static func launchShortcutsApplicationRunningShortcut(shortcutName: String, input: RunShortcutInput? = nil) throws {
        try self.shortcutsApplicationRunShortcutURL(shortcutName: shortcutName, input: input).openEnforcingShortcutsApplicationAvailability()
    }
}

@available(macOS 11.0, *)
extension URL {
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
    fileprivate func openEnforcingShortcutsApplicationAvailability() throws {
        try INShortcut.enforceShortcutsApplicationAvailability()
        try self.open()
    }
}
#endif
