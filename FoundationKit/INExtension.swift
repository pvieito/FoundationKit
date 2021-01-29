//
//  INExtension.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 02/05/2020.
//  Copyright © 2020 Pedro José Pereira Vieito. All rights reserved.
//

#if canImport(Intents)
import Foundation
import Intents

@available(tvOS 14.0, *)
@available(macOS 11.0, *)
@available(watchOS 3.2, *)
extension INExtension {
    private static let intentsServiceApplicationExtensionPointIdentifier = "com.apple.intents-service"
    
    static var isProcessRunningAsIntentsServiceExtension: Bool {
        return Bundle.main.isApplicationExtension &&
            Bundle.main.applicationExtensionPointIdentifier == Self.intentsServiceApplicationExtensionPointIdentifier
    }
    
    public static func enforceInAppIntentHandling() throws {
        guard !INExtension.isProcessRunningAsIntentsServiceExtension else {
            throw NSError(description: "Running this action requires a new operating system version. Please upgrade the system to the last version.")
        }
    }
    
    public static func enforceInAppIntentHandlingForBackgroundExecution(supportsOpenInAppAsAlternative: Bool = false) throws {
        guard !INExtension.isProcessRunningAsIntentsServiceExtension else {
            throw NSError(description: "Running this action without opening the app is not supported on this operating system version. Please upgrade the system to the last version or enable the “Open in App” action parameter.")
        }
    }
}
#endif
