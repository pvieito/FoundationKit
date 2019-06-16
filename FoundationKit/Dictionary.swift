//
//  Dictionary+PropertyList.swift
//  BundleKit
//
//  Created by Pedro José Pereira Vieito on 10/06/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Dictionary {
    public var propertyList: String {
        if let propertyListData = try? PropertyListSerialization.data(
                fromPropertyList: self, format: .xml, options: 0),
            let propertyListString = String(data: propertyListData, encoding: .utf8) {
            return propertyListString
        }
        else {
            return "<invalid>"
        }
    }
}
