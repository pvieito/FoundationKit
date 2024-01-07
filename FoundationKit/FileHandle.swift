//
//  FileHandle.swift
//  
//
//  Created by Pedro José Pereira Vieito on 7/1/24.
//

import Foundation

extension FileHandle {
    var isTTY: Bool {
        return isatty(self.fileDescriptor) != 0
    }
}
