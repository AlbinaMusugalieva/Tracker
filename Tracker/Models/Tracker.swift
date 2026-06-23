//
//  Tracker.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import UIKit

enum WeekDay: Int, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var shortName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
}

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Set<WeekDay>?
}
