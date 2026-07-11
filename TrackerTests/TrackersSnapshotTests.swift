//
//  TrackersSnapshotTests.swift
//  TrackerTests
//
//  Created by Albina Musugalieva.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersSnapshotTests: XCTestCase {
    
    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")
        try super.tearDownWithError()
    }
    
    func testTrackersViewControllerLight() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        let trackersViewController = TrackersViewController()
        trackersViewController.loadViewIfNeeded()
        
        assertSnapshot(
            matching: trackersViewController,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    func testTrackersViewControllerDark() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        let trackersViewController = TrackersViewController()
        trackersViewController.loadViewIfNeeded()
        
        assertSnapshot(
            matching: trackersViewController,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark))
        )
    }
    
}
