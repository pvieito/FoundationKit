//
//  INIntentResolutionResult.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 30/04/2020.
//  Copyright © 2020 Pedro José Pereira Vieito. All rights reserved.
//

#if canImport(Intents) && !os(tvOS)
import Foundation
import Intents

@available(iOS 13.0, *)
@available(macOS 11.0, *)
@available(watchOS 6.0, *)
extension Optional where Wrapped == INFile {
    public var optionalResolutionResult: INFileResolutionResult {
        if let wrapped = self {
            return .success(with: wrapped)
        }
        else {
            return .notRequired()
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 11.0, *)
@available(watchOS 6.0, *)
extension Optional where Wrapped == Array<INFile> {
    public var optionalResolutionResult: [INFileResolutionResult] {
        return (self ?? []).map({ INFileResolutionResult.success(with: $0) })
    }
}

@available(macOS 11.0, *)
@available(watchOS 6.0, *)
extension Optional where Wrapped == String {
    public var optionalResolutionResult: INStringResolutionResult {
        if let wrapped = self {
            return .success(with: wrapped)
        }
        else {
            return .notRequired()
        }
    }
}

@available(macOS 11.0, *)
@available(watchOS 6.0, *)
extension Optional where Wrapped == Array<String> {
    public var optionalResolutionResult: [INStringResolutionResult] {
        return (self ?? []).map({ INStringResolutionResult.success(with: $0) })
    }
}

@available(macOS 11.0, *)
@available(watchOS 6.0, *)
extension Optional where Wrapped == DateComponents {
    public var optionalResolutionResult: INDateComponentsResolutionResult {
        if let wrapped = self {
            return .success(with: wrapped)
        }
        else {
            return .notRequired()
        }
    }
}

@available(macOS 11.0, *)
@available(watchOS 6.0, *)
extension Optional where Wrapped == CLPlacemark {
    public var optionalResolutionResult: INPlacemarkResolutionResult {
        if let wrapped = self {
            return .success(with: wrapped)
        }
        else {
            return .notRequired()
        }
    }
}

@available(macOS 11.0, *)
@available(watchOS 6.0, *)
extension Optional where Wrapped == NSNumber {
    public var optionalResolutionResult: INBooleanResolutionResult {
        if let wrapped = self {
            return .success(with: wrapped.boolValue)
        }
        else {
            return .notRequired()
        }
    }
    
    public var resolvedBoolValue: Bool {
        return self?.boolValue ?? false
    }
}
#endif
