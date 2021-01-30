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

#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

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
        if UserDefaults.standard.bool(forKey: "com.pvieito.FoundationKit.INShortcut.SimulateShortcutsSupport") {
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
extension INShortcut {
    fileprivate static let shortcutFileExtension = "shortcut"
    
    @available(iOSApplicationExtension, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
    private static func launchShortcutsApplicationImportingShortcut(at url: URL) throws {
        try INShortcut.enforceShortcutsApplicationAvailability()
        try url.open()
    }
    
    @available(iOSApplicationExtension, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
    public static func launchShortcutsApplicationImportingTemplateShortcut(at bundle: Bundle? = nil) throws {
        let bundle = bundle ?? Bundle.main
        guard let shorcutsTemplatesURL = bundle.shorcutsTemplatesURLs.first else {
            throw NSError(description: "Shortcuts templates not found at bundle “\(bundle.bundleName)”.")
        }
        try self.launchShortcutsApplicationImportingShortcut(at: shorcutsTemplatesURL)
    }
}

@available(macOS 11.0, *)
extension INShortcut {
    public enum ShortcutsAutomationOnboardingAlert: CustomStringConvertible {
        case onboardingAlertTitle
        case onboardingAlertMessage
        case onboardingAlertImportTemplateShortcutButtonText
        case onboardingAlertCreateBlankShortcutButtonText
        case onboardingAlertCancelButtonText
        case allowUntrustedShortcutsAlertTitle
        case allowUntrustedShortcutsAlertMessage
        case allowUntrustedShortcutsAlertDismissButtonText

        public var description: String {
            switch self {
            case .onboardingAlertTitle:
                return "Shortcuts Automation"
            case .onboardingAlertMessage:
                return "You can import a template shortcut into Shortcuts to begin learning how to use the \(Bundle.main.bundleName) actions or start from scratch with a blank shortcut."
            case .onboardingAlertImportTemplateShortcutButtonText:
                return "Import Template Shortcut…"
            case .onboardingAlertCreateBlankShortcutButtonText:
                return "Create Blank Shortcut…"
            case .onboardingAlertCancelButtonText:
                return "Cancel"
            case .allowUntrustedShortcutsAlertTitle:
                return "Allow Untrusted Shortcuts"
            case .allowUntrustedShortcutsAlertMessage:
                #if os(macOS) || targetEnvironment(macCatalyst)
                let preferencesLocationText = "Shortcuts preferences"
                #else
                let preferencesLocationText = "Shortcuts section of the Settings app"
                #endif
                return "Note that to import a shortcut into Shortcuts you need to enable the “\(Self.allowUntrustedShortcutsAlertTitle.description)” option in the \(preferencesLocationText)."
            case .allowUntrustedShortcutsAlertDismissButtonText:
                return "OK"
            }
        }
        
        @UserDefaults.Wrapper(key: "com.pvieito.FoundationKit.INShortcut.ShortcutsAutomationOnboardingAlert.AllowUntrustedShortcutsToImportTemplateAlertWasPresented", defaultValue: false)
        public static var allowUntrustedShortcutsToImportTemplateAlertWasPresented: Bool
        
        #if os(macOS)
        public static func presentAlert(bundle: Bundle? = nil, errorHandler: @escaping ((Error) -> Void)) {
            do {
                let alert = NSAlert()
                alert.messageText = INShortcut.ShortcutsAutomationOnboardingAlert.onboardingAlertTitle.description
                alert.informativeText = INShortcut.ShortcutsAutomationOnboardingAlert.onboardingAlertMessage.description
                alert.addButton(withTitle: INShortcut.ShortcutsAutomationOnboardingAlert.onboardingAlertImportTemplateShortcutButtonText.description)
                alert.addButton(withTitle: ShortcutsAutomationOnboardingAlert.onboardingAlertCreateBlankShortcutButtonText.description)
                alert.addButton(withTitle: ShortcutsAutomationOnboardingAlert.onboardingAlertCancelButtonText.description)
                let response = alert.runModal()
                switch response {
                case .alertFirstButtonReturn:
                    if !self.allowUntrustedShortcutsToImportTemplateAlertWasPresented {
                        let alert = NSAlert()
                        alert.messageText = INShortcut.ShortcutsAutomationOnboardingAlert.allowUntrustedShortcutsAlertTitle.description
                        alert.informativeText = INShortcut.ShortcutsAutomationOnboardingAlert.allowUntrustedShortcutsAlertMessage.description
                        alert.addButton(withTitle: INShortcut.ShortcutsAutomationOnboardingAlert.allowUntrustedShortcutsAlertDismissButtonText.description)
                        let _ = alert.runModal()
                        self.allowUntrustedShortcutsToImportTemplateAlertWasPresented = true
                    }
                    try INShortcut.launchShortcutsApplicationImportingTemplateShortcut(at: bundle)
                case .alertSecondButtonReturn:
                    try INShortcut.launchShortcutsApplicationCreatingShortcut()
                default:
                    break
                }
            }
            catch {
                errorHandler(error)
            }
        }
        #elseif os(iOS)
        @available(iOSApplicationExtension, unavailable)
        @available(tvOSApplicationExtension, unavailable)
        @available(macCatalystApplicationExtension, unavailable)
        public static func presentAlert(on viewController: UIViewController, bundle: Bundle? = nil, errorHandler: @escaping ((Error) -> Void)) {
            let onboardingAlertController = UIAlertController(title: INShortcut.ShortcutsAutomationOnboardingAlert.onboardingAlertTitle.description, message: INShortcut.ShortcutsAutomationOnboardingAlert.onboardingAlertMessage.description, preferredStyle: .alert)
            let openShortcutTemplateAction = UIAlertAction(title: INShortcut.ShortcutsAutomationOnboardingAlert.onboardingAlertImportTemplateShortcutButtonText.description, style: .default) { _ in
                func launchShortcutsApplicationImportingTemplateShortcut() {
                    do {
                        try INShortcut.launchShortcutsApplicationImportingTemplateShortcut(at: bundle)
                    }
                    catch {
                        errorHandler(error)
                    }
                }
                
                if !self.allowUntrustedShortcutsToImportTemplateAlertWasPresented {
                let allowUntrustedShortcutsAlertController = UIAlertController(title: INShortcut.ShortcutsAutomationOnboardingAlert.allowUntrustedShortcutsAlertTitle.description, message: INShortcut.ShortcutsAutomationOnboardingAlert.allowUntrustedShortcutsAlertMessage.description, preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: INShortcut.ShortcutsAutomationOnboardingAlert.allowUntrustedShortcutsAlertDismissButtonText.description, style: .default) { _ in
                    self.allowUntrustedShortcutsToImportTemplateAlertWasPresented = true
                    launchShortcutsApplicationImportingTemplateShortcut()
                }
                allowUntrustedShortcutsAlertController.addAction(dismissAction)
                viewController.present(allowUntrustedShortcutsAlertController, animated: true)
                }
                else {
                    launchShortcutsApplicationImportingTemplateShortcut()
                }
            }
            onboardingAlertController.addAction(openShortcutTemplateAction)
            let openShortcutsAction = UIAlertAction(title: ShortcutsAutomationOnboardingAlert.onboardingAlertCreateBlankShortcutButtonText.description, style: .default) { _ in
                do {
                    try INShortcut.launchShortcutsApplicationCreatingShortcut()
                }
                catch {
                    errorHandler(error)
                }
            }
            onboardingAlertController.addAction(openShortcutsAction)
            let cancelAction = UIAlertAction(title: INShortcut.ShortcutsAutomationOnboardingAlert.onboardingAlertCancelButtonText.description, style: .cancel)
            onboardingAlertController.addAction(cancelAction)
            viewController.present(onboardingAlertController, animated: true)
        }
        #endif
    }
}

@available(macOS 11.0, *)
extension Bundle {
    private var shorcutsTemplates: [[String: Any]] {
        return self.object(forInfoDictionaryKey: "com.pvieito.FoundationKit.INShortcut.ShortcutsTemplates") as? [[String: Any]] ?? []
    }
    
    var shorcutsTemplatesURLs: [URL] {
        return self.shorcutsTemplates.compactMap { $0["URL"] as? String } .compactMap { $0.genericURL }
    }
}

@available(macOS 11.0, *)
extension URL {
    fileprivate var isShortcutFile: Bool {
        return self.isFileURL && self.pathExtension == INShortcut.shortcutFileExtension
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
