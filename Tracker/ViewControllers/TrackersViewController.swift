//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import UIKit

final class TrackersViewController: UIViewController, TrackerStoreDelegate {
    
    private let initialStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .initialStarLogo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let initialStateLabel: UILabel = {
        let label = UILabel()
        label.text = "emptyState.title".localized()
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
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("filters.button".localized(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.white, for: .normal) // Кнопка всегда должна быть читаемой
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    private var collectionView: UICollectionView!
    private let searchController = UISearchController(searchResultsController: nil)
    private var currentFilter: TrackerFilter = .all
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(
            title: "trackers.title".localized(),
            image: UIImage(resource: .trackerLogoTabBar),
            selectedImage: UIImage(resource: .trackerLogoTabBar)
        )
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        trackerStore.delegate = self
        
        setupTrackersNavigationBar()
        setupInitialState()
        setupCollectionView()
        setupFilters()
        
        loadCompletedTrackers()
        reloadVisibleTrackers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.report(event: "open")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.report(event: "close")
    }
    
    private func setupTrackersNavigationBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "trackers.title".localized()
        
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
        
        searchController.searchBar.placeholder = "search.placeholder".localized()
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
        collectionView.backgroundColor = .systemBackground
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(HeaderSectionView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "Header")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupFilters(){
        view.addSubview(filtersButton)
        
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func loadCompletedTrackers() {
        do {
            self.completedTrackers = try trackerRecordStore.fetchRecords()
        } catch {
            print("Ошибка загрузки отметок выполнения: \(error)")
        }
    }
    
    private func showVisibleTrackers() {
        let hasTrackers = trackerStore.numberOfSections > 0
        
        collectionView.isHidden = !hasTrackers
        initialStateImageView.isHidden = hasTrackers
        initialStateLabel.isHidden = hasTrackers
    }
    
    private func reloadVisibleTrackers() {
        let calendar = Calendar.current
        let filterWeekDay = calendar.component(.weekday, from: currentDate)
        
        let currentWeekDayIndex = filterWeekDay == 1 ? 6 : filterWeekDay - 2
        guard let currentWeekDay = WeekDay(rawValue: currentWeekDayIndex) else { return }
        
        let completedIdsForCurrentDate = Set(completedTrackers.filter {
            Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }.map { $0.trackerId })
        
        trackerStore.filterTrackers(for: currentWeekDay, filter: currentFilter, completedIds: completedIdsForCurrentDate)
        
        
        collectionView.reloadData()
        showVisibleTrackers()
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        reloadVisibleTrackers()
    }
    
    @objc private func plusButtonTapped() {
        AnalyticsService.shared.report(event: "click", item: "add_track")
        let createTrackerViewController = CreateTrackerViewController()
        createTrackerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: createTrackerViewController)
        present(navigationController, animated: true)
    }
    
    func storeDidUpdate(_ store: TrackerStore) {
        collectionView.reloadData()
        showVisibleTrackers()
    }
    
    @objc private func didTapFiltersButton() {
        AnalyticsService.shared.report(event: "click", item: "filter")
        let filtersViewController = FiltersViewController(selectedFilter: currentFilter)
        
        filtersViewController.onFilterSelected = { [weak self] filter in
            guard let self = self else { return }
            self.currentFilter = filter
            if filter == .today {
                self.datePicker.date = Date()
                self.currentDate = Date()
            }
            self.reloadVisibleTrackers()
        }
        present(filtersViewController, animated: true)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 18)
    }
    
    func collectionView( _ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let tracker = trackerStore.object(at: indexPath) else {
            return nil
        }
        
        let categoryName = trackerStore.headerTitleInSection(indexPath.section) ?? ""
        
        
        let isPinned = tracker.isPinned
        let pinTitle = isPinned ? "contextMenu.unpinned".localized(): "contextMenu.pinned".localized()
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, actionProvider: { [weak self] _ in
            return UIMenu(children: [
                UIAction(title: pinTitle) { _ in
                    self?.pinTracker(at: indexPath)
                },
                UIAction(title: "contextMenu.edit".localized()) {_ in
                    AnalyticsService.shared.report(event: "click", item: "edit")
                    self?.editTracker(at: indexPath)
                },
                UIAction(title: "contextMenu.delete".localized(), attributes: .destructive) { _ in
                    AnalyticsService.shared.report(event: "click", item: "delete")
                    self?.deleteTracker(at: indexPath)
                },
            ])
        })
    }
    
    func collectionView( _ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration ) -> UITargetedPreview? {
        
        guard let identifier = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: identifier) as? TrackerCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        let visiblePath = UIBezierPath(roundedRect: cell.colorView.bounds, cornerRadius: 16)
        parameters.visiblePath = visiblePath
        
        return UITargetedPreview(view: cell.colorView, parameters: parameters)
    }
    
    private func pinTracker(at indexPath: IndexPath) {
        do {
            let trackerStore = TrackerStore()
            try trackerStore.togglePinTracker(at: indexPath)
        } catch {
            print("Ошибка при закреплении трекера: \(error)")
        }
    }
    
    private func editTracker(at indexPath: IndexPath) {
        guard let tracker = trackerStore.object(at: indexPath) else { return }
        let categoryName = trackerStore.headerTitleInSection(indexPath.section) ?? ""
        
        let editViewController = CreateTrackerViewController()
        
        editViewController.configureForEditing(tracker: tracker, categoryName: categoryName)
        
        
        editViewController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: editViewController)
        present(navigationController, animated: true)
    }
    
    private func deleteTracker(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "alert.delete.title".localized(),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            do {
                let trackerStore = TrackerStore()
                try trackerStore.deleteTracker(at: indexPath)
            } catch {
                print("Ошибка при удалении трекера: \(error)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerStore.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        guard let tracker = trackerStore.object(at: indexPath) else { return UICollectionViewCell() }
        
        let isCompleted = completedTrackers.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
        }
        
        let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        cell.configure(with: tracker, completedDays: completedDays, isCompleted: isCompleted)
        
        cell.completionButtonTappedHandler = { [weak self] in
            guard let self = self else { return }
            AnalyticsService.shared.report(event: "click", item: "track")
            
            if Calendar.current.compare(self.currentDate, to: Date(), toGranularity: .day) == .orderedDescending {
                print("Ошибка: нельзя отметить трекер для будущей даты")
                return
            }
            
            do {
                if isCompleted {
                    try self.trackerRecordStore.removeRecord(with: tracker.id, date: self.currentDate)
                } else {
                    try self.trackerRecordStore.addRecord(with: tracker.id, date: self.currentDate)
                }
                
                self.loadCompletedTrackers()
                collectionView.reloadItems(at: [indexPath])
                
            } catch {
                print("Ошибка изменения статуса выполнения трекера: \(error)")
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? HeaderSectionView else {
            return UICollectionReusableView()
        }
        header.titleLabel.text = trackerStore.headerTitleInSection(indexPath.section)
        return header
    }
}

extension TrackersViewController: CreateTrackerViewControllerDelegate {
    func createTrackerViewController(_ vc: CreateTrackerViewController, didCreateTracker tracker: Tracker, toCategory categoryTitle: String) {
        reloadVisibleTrackers()
    }
}
