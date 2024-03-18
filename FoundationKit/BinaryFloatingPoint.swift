//
//  BinaryFloatingPoint.swift
//  
//
//  Created by Pedro José Pereira Vieito on 18/3/24.
//

import Foundation

extension Collection where Element: BinaryFloatingPoint {
    /// Returns the average of all elements in the array
    public func average() -> Element? {
        return self.isEmpty ? nil : Element(self.sum()) / Element(self.count)
    }
}
