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
    private var collectionView: UICollectionView!
    private var visibleCategories: [TrackerCategory] = []
    private let searchController = UISearchController(searchResultsController: nil)
    
    
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
        setupCollectionView()
        reloadVisibleTrackers()
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
    
    private func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .ypWhite
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    private func showVisibleTrackers() {
        let hasTrackers = !visibleCategories.isEmpty
        
        collectionView.isHidden = !hasTrackers
        
        initialStateImageView.isHidden = hasTrackers
        initialStateLabel.isHidden = hasTrackers
    }
    
    func trackerCompletion(id: UUID, date: Date) {
        let calendar = Calendar.current
        if calendar.compare(date, to: Date(), toGranularity: .day) == .orderedDescending {
            print("Ошибка: нельзя отметить трекер для будущей даты")
            return
        }
        
        let index = completedTrackers.firstIndex { record in
            record.trackerId == id && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
        
        if let index{
            completedTrackers.remove(at: index)
        } else {
            let newRecord = TrackerRecord(trackerId: id, date: date)
            completedTrackers.append(newRecord)
        }
        collectionView.reloadData()
    }
    
    func addNewTracker(_ tracker: Tracker, toCategoryWithTitle categoryTitle: String) {
        var newCategories: [TrackerCategory] = []
        var isCategoryFound = false
        
        for category in categories {
            if category.title == categoryTitle {
                var newTrackers = category.trackers
                newTrackers.append(tracker)
                
                let updatedCategory = TrackerCategory(title: category.title, trackers: newTrackers)
                newCategories.append(updatedCategory)
                isCategoryFound = true
            } else {
                newCategories.append(category)
            }
        }
        if !isCategoryFound {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            newCategories.append(newCategory)
        }
        
        self.categories = newCategories
        
        reloadVisibleTrackers()
    }
    
    private func reloadVisibleTrackers() {
        let calendar = Calendar.current
        let filterWeekDay = calendar.component(.weekday, from: currentDate)
        
        let currentWeekDayIndex = filterWeekDay == 1 ? 6 : filterWeekDay - 2
        guard let currentWeekDay = WeekDay(rawValue: currentWeekDayIndex) else { return }
        
        var filteredCategories: [TrackerCategory] = []
        
        for category in categories {
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(currentWeekDay)
            }
            
            if !filteredTrackers.isEmpty {
                let newCategory = TrackerCategory(title: category.title, trackers: filteredTrackers)
                filteredCategories.append(newCategory)
            }
        }
        
        self.visibleCategories = filteredCategories
        
        collectionView.reloadData()
        showVisibleTrackers()
    }
    
    @objc private func plusButtonTapped() {
        let createTrackerViewController = CreateTrackerViewController()
        createTrackerViewController.delegate = self
        
        present(createTrackerViewController, animated: true, completion: nil)
        
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        self.currentDate = sender.date
        reloadVisibleTrackers()
    }
}
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 32 - 9
        let cellWidth = availableWidth / 2
        
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories.isEmpty ? 0 : visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        let isCompleted = completedTrackers.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
        }
        
        let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        cell.configure(with: tracker, completedDays: completedDays, isCompleted: isCompleted)
        
        cell.completionButtonTappedHandler = { [weak self] in
            guard let self = self else { return }
            
            self.trackerCompletion(id: tracker.id, date: self.currentDate)
            
            collectionView.reloadItems(at: [indexPath])
        }
        
        return cell
    }
}

extension TrackersViewController: CreateTrackerViewControllerDelegate {
    func createTrackerViewController(_ vc: CreateTrackerViewController, didCreateTracker tracker: Tracker, toCategory categoryTitle: String) {
        
        addNewTracker(tracker, toCategoryWithTitle: categoryTitle)
        reloadVisibleTrackers()
    }
}
