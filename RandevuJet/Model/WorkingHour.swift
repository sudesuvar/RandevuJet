//
//  WorkingHour.swift
//  RandevuJet
//
//  Created by sude on 26.07.2025.
//

import Foundation

struct WorkingHour: Codable {
    var start: String
    var end: String
}

func generateHourlyWorkingHours(from startHour: Int, to endHour: Int) -> [WorkingHour] {
    var workingHours = [WorkingHour]()
    
    for hour in startHour..<endHour {
        let start = String(format: "%02d:00", hour)
        let end = String(format: "%02d:00", hour + 1)
        workingHours.append(WorkingHour(start: start, end: end))
    }
    
    return workingHours
}


