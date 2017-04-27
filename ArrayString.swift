//
//  ArrayString.swift
//  CommonKit
//
//  Created by Pedro José Pereira Vieito on 27/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Array where Element == String {

    /// Returns array of URLs with the Strings as the paths.
    public var pathURLs: [URL] {
        return self.map({ $0.pathURL })
    }
}
