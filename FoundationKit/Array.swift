//
//  Array.swift
//  CommonKit
//
//  Created by Pedro José Pereira Vieito on 14/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Array {

    /// Returns the array with the specified elements appended.
    ///
    /// - Parameter newElements: Elements appended to the returned array.
    /// - Returns: Array with the elements appended.
    public func appending<S>(contentsOf newElements: S) -> Array<Element> where S : Sequence, S.Iterator.Element == Element {
        return self + newElements
    }
}
