//
//  Item.swift
//  NewBear
//
//  Created by He Cho on 2024/4/9.
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
