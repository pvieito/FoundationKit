//
//  BinaryInteger.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 16/04/2020.
//  Copyright © 2020 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension BinaryInteger {
    public func clamped(to range: ClosedRange<Self>) -> Self {
        return max(min(self, range.upperBound), range.lowerBound)
    }
    
    public func clamped(to range: PartialRangeFrom<Self>) -> Self {
        return max(self, range.lowerBound)
    }
    
    public func clamped(to range: PartialRangeThrough<Self>) -> Self {
        return min(self, range.upperBound)
    }
}

extension BinaryInteger {
    public mutating func clamp(to range: ClosedRange<Self>) {
        self = self.clamped(to: range)
    }
    
    public mutating func clamp(to range: PartialRangeFrom<Self>) {
        self = self.clamped(to: range)
    }
    
    public mutating func clamp(to range: PartialRangeThrough<Self>) {
        self = self.clamped(to: range)
    }
}

extension Sequence where Element: AdditiveArithmetic {
    /// Returns the total sum of all elements in the sequence
    public func sum() -> Element { reduce(.zero, +) }
}

extension Collection where Element: BinaryInteger {
    /// Returns the average of all elements in the array
    public func average() -> Element? {
        return self.isEmpty ? nil : self.sum() / Element(self.count)
    }
    /// Returns the average of all elements in the array as Floating Point type
    public func average<T: FloatingPoint>() -> T? {
        return isEmpty ? nil : T(self.sum()) / T(self.count)
    }
}
