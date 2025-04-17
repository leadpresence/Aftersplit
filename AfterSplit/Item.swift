//
//  Item.swift
//  AfterSplit
//
//  Created by Chibueze Felix on 02/03/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
