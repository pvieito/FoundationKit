//
//  Double.swift
//  CommonKit
//
//  Created by Pedro José Pereira Vieito on 12/3/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

public extension Double {

    /// Returns the number rounded with the decimal places specified.
    ///
    /// - Parameter decimalPlaces: Decimal places to return.
    /// - Returns: Rounded number as Double.
    public func rounded(decimalPlaces: Int) -> Double {
        let divisor = pow(10.0, Double(decimalPlaces))
        return (self * divisor).rounded() / divisor
    }

    /// Return the percentage with the decimal places specified.
    ///
    /// - Parameter decimalPlaces: Decimal places to return.
    /// - Returns: Percentage as Double.
    public func percentage(decimalPlaces: Int = 2) -> Double {
        return (self * 100).rounded(decimalPlaces: decimalPlaces)
    }
}
