//
//  Item.swift
//  CatChallenge
//
//  Created by user943027 on 8/10/25.
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
