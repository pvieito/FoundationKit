//
//  GenericError.swift
//  CommonKit
//
//  Created by Pedro José Pereira Vieito on 14/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

/// A generic localized error.
public class GenericError: Error, LocalizedError {

    public var errorDescription: String?

    /// Initialize a GenericError with a description.
    ///
    /// - Parameter description: Error description.
    public init(_ description: String) {
        errorDescription = description
    }
}
