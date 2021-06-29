//
//  HTTPURLResponse.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 29/6/21.
//  Copyright © 2021 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLResponse {
    public func enforceHTTPStatus() throws {
        guard let response = self as? HTTPURLResponse else {
            throw NSError(description: "Received invalid non-HTTP response.")
        }
        guard (100..<400).contains(response.statusCode) else {
            let statusCodeDescription = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
            throw NSError(description: "Request failed with HTTP status \(response.statusCode) “\(statusCodeDescription)”.")
        }
    }
}
