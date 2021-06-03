//
//  UnitConverterReciprocal.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 23/3/21.
//  Copyright © 2021 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

@available(macOS 10.12, *)
@available(watchOS 3.0, *)
class UnitConverterReciprocal: UnitConverter {
    private let numerator: Double
    
    init(numerator: Double) {
        self.numerator = numerator
    }
    
    override func baseUnitValue(fromValue value: Double) -> Double {
        return self.numerator / value
    }
    
    override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
        return self.numerator / baseUnitValue
    }
}
