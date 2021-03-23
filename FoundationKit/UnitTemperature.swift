//
//  UnitTemperature.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 23/3/21.
//  Copyright © 2021 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

@available(macOS 10.12, *)
extension UnitTemperature {
    public static let microReciprocalDegrees: UnitTemperature = {
        let converter = UnitConverterReciprocal(numerator: 1_000_000)
        return UnitTemperature(symbol: "mired", converter: converter)
    }()
}
