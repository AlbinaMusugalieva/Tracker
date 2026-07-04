//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import UIKit

final class StatisticsViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .statisticsLogoTabBar),
            selectedImage: UIImage(resource: .statisticsLogoTabBar)
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
