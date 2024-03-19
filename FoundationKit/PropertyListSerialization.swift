//
//  PropertyListSerialization.swift
//
//
//  Created by Pedro José Pereira Vieito on 19/3/24.
//

import Foundation

extension PropertyListSerialization {
    public static func data(from propertyList: Any, format: PropertyListSerialization.PropertyListFormat? = nil, options: PropertyListSerialization.WriteOptions? = nil) throws -> Data {
        return try self.data(fromPropertyList: propertyList, format: format ?? .xml, options: options ?? 0)
    }
    
    public static func propertyList(from data: Data, options: PropertyListSerialization.ReadOptions = []) throws -> Any {
        return try self.propertyList(from: data, options: options, format: nil)
    }
}
