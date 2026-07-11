//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import Foundation
import AppMetricaCore

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    func report(event: String, screen: String = "Main", item: String? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": screen
        ]
        
        if let item = item {
            params["item"] = item
        }
        
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("AppMetrica failure: \(error.localizedDescription)")
        })
    }
}
