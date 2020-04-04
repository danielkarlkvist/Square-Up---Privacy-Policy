//
//  RotationObservable.swift
//  Square Up
//
//  Created by Daniel Karlkvist on 2019-12-29.
//  Copyright © 2019 Daniel Karlkvist. All rights reserved.
//

import Foundation

protocol RotationObservable: class {
    func addRotationObserver(_ observer: RotationObserver)
    func notifyRotationObservers()
}
