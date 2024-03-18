//
//  Measurement.swift
//  
//
//  Created by Pedro José Pereira Vieito on 18/3/24.
//

import Foundation

@available(macOS 10.12, *)
@available(watchOS 3.0, *)
extension Collection {
    public func average<UnitType: Dimension>(in unit: UnitType = .baseUnit()) -> Measurement<UnitType>? where Element == Measurement<UnitType> {
        guard !self.isEmpty else { return nil }
        let zeroMeasurement = Measurement(value: .zero, unit: unit)
        let sum = reduce(zeroMeasurement, { $0 + $1.converted(to: unit) })
        return sum / Double(self.count)
    }
}
