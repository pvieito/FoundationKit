//
//  PropertyListSerialization.swift
//
//
//  Created by Pedro José Pereira Vieito on 19/3/24.
//

import Foundation

extension PropertyListSerialization {
    public static func data(from item: Any, format: PropertyListSerialization.PropertyListFormat = .xml, options: PropertyListSerialization.WriteOptions? = nil) throws -> Data {
        return try PropertyListSerialization.data(fromPropertyList: item, format: format, options: options ?? 0)
    }
}
