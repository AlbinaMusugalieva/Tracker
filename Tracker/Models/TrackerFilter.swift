//
//  TrackerFilter.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import Foundation

enum TrackerFilter: Int, CaseIterable {
    case all = 0
    case today
    case completed
    case uncompleted
    
    var title: String {
        switch self {
        case .all: return "filters.all".localized()
        case .today: return "filters.today".localized()
        case .completed: return "filters.completed".localized()
        case .uncompleted: return "filters.uncompleted".localized()
        }
    }
}
