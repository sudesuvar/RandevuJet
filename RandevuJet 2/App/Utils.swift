//
//  Utils.swift
//  RandevuJet
//
//  Created by sude on 26.07.2025.
//

import Foundation


func generateHourlyIntervals(from start: String, to end: String) -> [String]? {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    
    guard let startDate = formatter.date(from: start),
          let endDate = formatter.date(from: end),
          startDate <= endDate else {
        return nil
    }
    
    var hours: [String] = []
    var current = startDate
    
    while current <= endDate {
        hours.append(formatter.string(from: current))
        // 1 saat ekle
        guard let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: current) else {
            break
        }
        current = nextHour
    }
    
    return hours
}

