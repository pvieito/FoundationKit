//
//  Date.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 30/09/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Date {
    public func rounded(minuteInterval: Int) -> Date {
        let dateComponents = Calendar.current.dateComponents([.minute], from: self)
        let minutes = dateComponents.minute!

        let intervalRemainder = Double(minutes).truncatingRemainder(
            dividingBy: Double(minuteInterval)
        )

        let halfInterval = Double(minuteInterval) / 2.0

        let roundingAmount = intervalRemainder > halfInterval ? minuteInterval : 0
        let minutesRounded = minutes / minuteInterval * minuteInterval
        let timeInterval = TimeInterval(
            60 * (minutesRounded + roundingAmount - minutes)
        )

        let roundedDate = Date(timeInterval: timeInterval, since: self)
        return roundedDate
    }
    
    public mutating func round(minuteInterval: Int) {
        self = self.rounded(minuteInterval: minuteInterval)
    }
}
