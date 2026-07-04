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
        addTopBorderToTabBar()
    }
    
    private func setupMainTabBar(){
        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypGray
        tabBar.backgroundColor = .ypWhite
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        let trackersNavigationController = UINavigationController(rootViewController: trackerViewController)
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        
        viewControllers = [trackersNavigationController, statisticsNavigationController]
    }
    
    private func addTopBorderToTabBar() {
        let lineView = UIView()
        lineView.backgroundColor = .ypGray
        tabBar.addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: tabBar.topAnchor),
            lineView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

