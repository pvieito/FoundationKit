//
//  Array.swift
//  CommonKit
//
//  Created by Pedro José Pereira Vieito on 14/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Array {

    public func appending<S>(contentsOf newElements: S) -> Array<Element> where S : Sequence, S.Iterator.Element == Element {
        var array = self
        array.append(contentsOf: newElements)

        return array
    }
}
