//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private let initialStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .initialStarLogo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let initialStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .trackerLogoTabBar),
            selectedImage: UIImage(resource: .trackerLogoTabBar)
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupTrackersNavigationBar()
        
        setupInitialState()
    }
    
    private func setupTrackersNavigationBar(){
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Трекеры"
        
        
        let plusButton = UIBarButtonItem(
            image: UIImage(resource: .plus),
            style: .plain,
            target: self,
            action: #selector(plusButtonTapped)
        )
        plusButton.tintColor = .label
        navigationItem.leftBarButtonItem = plusButton
        
        
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerItem
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        searchController.obscuresBackgroundDuringPresentation = false
        
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupInitialState() {
        view.addSubview(initialStateImageView)
        view.addSubview(initialStateLabel)
        initialStateImageView.translatesAutoresizingMaskIntoConstraints = false
        initialStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            initialStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            initialStateImageView.widthAnchor.constraint(equalToConstant: 80),
            initialStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            initialStateLabel.topAnchor.constraint(equalTo: initialStateImageView.bottomAnchor, constant: 8),
            initialStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            initialStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func plusButtonTapped() {
        print("Нажата кнопка добавления трекера")
        // Здесь будет открытие экрана выбора типа трекера
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        print("Выбрана дата: \(sender.date)")
        // Здесь будет фильтрация коллекции трекеров по дате
    }
}

