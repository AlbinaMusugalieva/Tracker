//
//  Tracker.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import UIKit

enum WeekDay: Int, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var name: String {
        switch self {
        case .monday: return "weekday.monday".localized()
        case .tuesday: return "weekday.tuesday".localized()
        case .wednesday: return "weekday.wednesday".localized()
        case .thursday: return "weekday.thursday".localized()
        case .friday: return "weekday.friday".localized()
        case .saturday: return "weekday.saturday".localized()
        case .sunday: return "weekday.sunday".localized()
        }
    }
}

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Set<WeekDay>
    let isPinned: Bool
    
    init(
        id: UUID,
        name: String,
        color: UIColor,
        emoji: String,
        schedule: Set<WeekDay>,
        isPinned: Bool = false
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isPinned = isPinned
    }
}
