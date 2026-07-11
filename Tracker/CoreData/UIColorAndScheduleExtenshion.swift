//
//  UIColorAndSchedule.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import UIKit

extension UIColor {
    static let ypColors: [UIColor] = [
        .ypColor1, .ypColor2, .ypColor3, .ypColor4, .ypColor5, .ypColor6,
        .ypColor7, .ypColor8, .ypColor9, .ypColor10, .ypColor11, .ypColor12,
        .ypColor13, .ypColor14, .ypColor15, .ypColor16, .ypColor17, .ypColor18
    ]
    
    var toColorString: String {
        if let index = UIColor.ypColors.firstIndex(where: { $0 == self }) {
            return String(index)
        }
        return "0"
    }
    
    static func fromColorString(_ string: String) -> UIColor {
        if let index = Int(string), index >= 0 && index < ypColors.count {
            return ypColors[index]
        }
        return .ypColor1
    }
}

final class ScheduleConverter {
    static func toString(_ schedule: Set<WeekDay>) -> String {
        return schedule.map { String($0.rawValue) }.joined(separator: ",")
    }
    
    static func toSet(_ string: String) -> Set<WeekDay> {
        if string.isEmpty { return [] }
        let components = string.components(separatedBy: ",")
        let days = components.compactMap { Int($0) }.compactMap { WeekDay(rawValue: $0) }
        return Set(days)
    }
}

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
