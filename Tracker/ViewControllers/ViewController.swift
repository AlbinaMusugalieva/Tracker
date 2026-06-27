//
//  ViewController.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import UIKit

final class ViewController: UITabBarController {
    let trackerViewController = TrackersViewController()
    let statisticsViewController = StatisticsViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainTabBar()
    }
    
    private func setupMainTabBar(){
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        tabBar.backgroundColor = .systemBackground
        
        let trackersNavigationController = UINavigationController(rootViewController: trackerViewController)
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        
        viewControllers = [trackersNavigationController, statisticsNavigationController]
    }
}

