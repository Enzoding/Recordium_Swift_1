//
//  Item.swift
//  Recordium_Swift
//
//  Created by 龙龙 on 2025/2/23.
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
