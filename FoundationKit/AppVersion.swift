//
//  AppVersion.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 31/5/23.
//  Copyright © 2023 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

public typealias AppVersion = OperatingSystemVersion

extension AppVersion: Comparable {
    public static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
        return lhs.majorVersion == rhs.majorVersion && lhs.minorVersion == rhs.minorVersion && lhs.patchVersion == rhs.patchVersion
    }

    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if lhs.majorVersion != rhs.majorVersion {
            return lhs.majorVersion < rhs.majorVersion
        } else if lhs.minorVersion != rhs.minorVersion {
            return lhs.minorVersion < rhs.minorVersion
        } else {
            return lhs.patchVersion < rhs.patchVersion
        }
    }
}

extension AppVersion {
    public init?(from string: String) {
        let stringComponents = string.split(separator: ".")
        let components = stringComponents.compactMap { Int($0) }
        guard stringComponents.count == components.count, components.count >= 1 && components.count <= 3 else {
            return nil
        }

        let major = components[0]
        let minor = components.get(elementAt: 1) ?? 0
        let patch = components.get(elementAt: 2) ?? 0
        self.init(majorVersion: major, minorVersion: minor, patchVersion: patch)
    }
}
