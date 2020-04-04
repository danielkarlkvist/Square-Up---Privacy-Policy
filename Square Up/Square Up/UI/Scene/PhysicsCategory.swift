//
//  PhysicsCategories.swift
//  Square Up
//
//  Created by Daniel Karlkvist on 2019-11-23.
//  Copyright © 2019 Daniel Karlkvist. All rights reserved.
//

import Foundation

enum PhysicsCategory {
    static let none: UInt32 = 0x0
    static let singleSquare: UInt32 = 0x1
    static let mainSquare: UInt32 = 0x1 << 1
}
