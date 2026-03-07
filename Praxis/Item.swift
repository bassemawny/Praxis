//
//  Item.swift
//  Praxis
//
//  Created by Bassem on 07.03.26.
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
