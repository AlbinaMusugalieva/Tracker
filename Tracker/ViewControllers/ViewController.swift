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
        
        let trackersNC = UINavigationController(rootViewController: trackerViewController)
        let statisticsNC = UINavigationController(rootViewController: statisticsViewController)
        
//        trackersNC.tabBarItem = trackerViewController.tabBarItem
//        statisticsNC.tabBarItem = statisticsViewController.tabBarItem
//        
//        trackersNC.title = nil
//            statisticsNC.title = nil
        
        viewControllers = [trackersNC, statisticsNC]
        
    }
}

