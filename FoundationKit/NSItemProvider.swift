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

#if canImport(Darwin)
extension NSItemProvider {
    private enum Error: LocalizedError {
        case invalidItemProvider
        case conversionError
        
        var errorDescription: String? {
            switch self {
            case .invalidItemProvider:
                 return "Invalid item provider."
            case .conversionError:
                return "Provided item could not be converted to the expected type."
            }
        }
    }
    
    public func loadItem<T>(forTypeIdentifier typeIdentifier: String, options: [AnyHashable : Any]? = nil) throws -> T {
        var result: Result<NSSecureCoding, Swift.Error> = .failure(Error.invalidItemProvider)
        
        let semaphore = DispatchSemaphore(value: 0)
        self.loadItem(forTypeIdentifier: typeIdentifier, options: options) { (item, error) in
            defer {
                semaphore.signal()
            }
            
            if let error = error {
                result = .failure(error)
            }
            else if let item = item {
                result = .success(item)
            }
        }
        semaphore.wait()
        
        guard let item = try result.get() as? T else {
            throw Error.conversionError
        }
        
        return item
    }
    
    @available(macOS 10.13, *)
    @available(iOS 11.0, *)
    @available(tvOS 11.0, *)
    public func loadInPlaceFileRepresentation(forTypeIdentifier typeIdentifier: String) throws -> URL {
        var result: Result<URL, Swift.Error> = .failure(Error.invalidItemProvider)

        let semaphore = DispatchSemaphore(value: 0)
        self.loadInPlaceFileRepresentation(forTypeIdentifier: typeIdentifier as String) { (url, isInPlace, error) in
            defer {
                semaphore.signal()
            }
            
            do {
                if let error = error {
                    throw error
                }
                if var url = url {
                    if !isInPlace {
                        let temporaryURL = FileManager.default.temporaryRandomFileURL(filename: url.lastPathComponent)
                        try FileManager.default.copyItem(at: url, to: temporaryURL)
                        url = temporaryURL
                    }
                    
                    result = .success(url)
                }
            }
            catch {
                result = .failure(error)
            }
        }
        semaphore.wait()
        
        return try result.get()
    }
}
#endif
