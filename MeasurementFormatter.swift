//
//  MeasurementFormatter.swift
//  CommonKit
//
//  Created by Pedro José Pereira Vieito on 5/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

@available(watchOSApplicationExtension 10.0, *)
@available(iOSApplicationExtension 10.0, *)
@available(tvOSApplicationExtension 10.0, *)
@available(macOSApplicationExtension 10.12, *)
extension MeasurementFormatter {

    public func valueUnitStrings<UnitType>(from measurement: Measurement<UnitType>) -> (value: String, unit: String) {
        let formattedString = self.string(from: measurement)

        if formattedString == "" {
            let numberString = self.numberFormatter.string(from: NSNumber(value: measurement.value))
            let unitString = self.string(from: measurement.unit)
            return (numberString ?? "", unitString)
        }
        else {
            var components = formattedString.components(separatedBy: " ")

            if components.count == 1 {
                return (components.joined(separator: " "), "")
            }
            else if components.count > 1 {
                let unit = components.removeLast()
                return (components.joined(separator: " "), unit)
            }
            else {
                return ("", "")
            }
        }
    }
}
