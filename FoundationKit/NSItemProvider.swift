//
//  NSProvider.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 10/05/2020.
//  Copyright © 2020 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

#if canImport(MobileCoreServices)
import MobileCoreServices
#endif

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

#if canImport(Darwin) && !os(watchOS)
extension NSItemProvider {
    static let conversionError = NSError(description: "Provided item could not be converted to the expected type.")
    
    public func loadItem<T>(forTypeIdentifier typeIdentifier: String, options: [AnyHashable : Any]? = nil) throws -> T {
        let result = try DispatchSemaphore.returningWait { handler in
            self.loadItem(forTypeIdentifier: typeIdentifier, options: options, completionHandler: handler)
        }
        guard let item = result as? T else {
            throw NSItemProvider.conversionError
        }
        return item
    }
    
    @available(macOS 10.13, *)
    @available(iOS 11.0, *)
    @available(tvOS 11.0, *)
    public func loadObject<T>(ofClass itemClass: NSItemProviderReading.Type) throws -> T {
        let result = try DispatchSemaphore.returningWait { handler in
            self.loadObject(ofClass: itemClass, completionHandler: handler)
        }
        guard let item = result as? T else {
            throw NSItemProvider.conversionError
        }
        return item
    }

    @available(macOS 10.13, *)
    @available(iOS 11.0, *)
    @available(tvOS 11.0, *)
    public func loadInPlaceFileRepresentation(forTypeIdentifier typeIdentifier: String) throws -> URL {
        return try DispatchSemaphore.returningWait { handler in
            self.loadInPlaceFileRepresentation(forTypeIdentifier: typeIdentifier as String) { (url, isInPlace, resultError) in
                var url = url
                var resultError = resultError
                
                do {
                    if let notInPlaceURL = url, !isInPlace {
                        url = try notInPlaceURL.temporaryAutocleanedFileCopy(directoryName: "\(Bundle.foundationKitBundleIdentifier).NSItemProvider.LoadInPlaceFileRepresentation")
                    }
                }
                catch {
                    url = nil
                    resultError = error
                }
                handler(url, resultError)
            }
        }
    }
}
#endif
