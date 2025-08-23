//
//  AppLogger.swift
//  RandevuJet
//
//  Created by sude on 21.08.2025.
//

import Foundation
import os

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "KuaforApp"
    
    static let auth     = Logger(subsystem: subsystem, category: "Authentication")
    static let network  = Logger(subsystem: subsystem, category: "Network")
    static let database = Logger(subsystem: subsystem, category: "Database")
    static let ui       = Logger(subsystem: subsystem, category: "UI")
    static let general  = Logger(subsystem: subsystem, category: "General")
}
