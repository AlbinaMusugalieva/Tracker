//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//
import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func createTrackerViewController(_ vc: CreateTrackerViewController, didCreateTracker tracker: Tracker, toCategory categoryTitle: String)
}

final class CreateTrackerViewController: UIViewController {
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "createTracker.newHabit".localized()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameTrackerTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "createTracker.placeholder".localized()
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "createTracker.errorLimit".localized()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var optionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBackground
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.isScrollEnabled = false
        collection.dataSource = self
        collection.delegate = self
        
        collection.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collection.register(HeaderSectionView.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: HeaderSectionView.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("cancel".localized(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypRed, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("create".localized(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let colors: [UIColor] = [
        .ypColor1, .ypColor2, .ypColor3, .ypColor4, .ypColor5, .ypColor6,
        .ypColor7, .ypColor8, .ypColor9, .ypColor10, .ypColor11, .ypColor12,
        .ypColor13, .ypColor14, .ypColor15, .ypColor16, .ypColor17, .ypColor18
    ]
    
    private var selectedDays: [Int] = []
    private var selectedCategoryName: String?
    private var isEditMode = false
    private var editingTracker: Tracker?
    private var originalCategoryName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupViews()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(nameTrackerTextField)
        view.addSubview(errorLabel)
        contentView.addSubview(optionsTableView)
        contentView.addSubview(collectionView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
        view.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            nameTrackerTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            optionsTableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsTableView.heightAnchor.constraint(equalToConstant: 150),
            
            collectionView.topAnchor.constraint(equalTo: optionsTableView.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 444),
            
            buttonsStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        if isEditMode {
            titleLabel.text = "createTracker.editHabit".localized()
            createButton.setTitle("save".localized(), for: .normal)
            nameTrackerTextField.text = editingTracker?.name
            
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        }
    }
    
    private func convertDaysToText(days: [Int]) -> String? {
        if days.isEmpty { return nil }
        
        if days.count == 7 { return "weekday.everyday".localized() }
        
        let shortNames = ["weekday.short.monday".localized(), "weekday.short.tuesday".localized(), "weekday.short.wednesday".localized(), "weekday.short.thursday".localized(), "weekday.short.friday".localized(), "weekday.short.saturday".localized(), "weekday.short.sunday".localized()]
        
        let convertedArray = days.map { shortNames[$0] }
        
        return convertedArray.joined(separator: ", ")
    }
    
    private func checkValidation() {
        let isTextFieldNotEmpty = !(nameTrackerTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let currentText = nameTrackerTextField.text ?? ""
        let limitTextLength = currentText.count <= 38
        let isEmojiSelected = selectedEmojiIndexPath != nil
        let isColorSelected = selectedColorIndexPath != nil
        let isCategorySelected = selectedCategoryName != nil
        let isEnabled: Bool = isTextFieldNotEmpty && limitTextLength && isEmojiSelected && isColorSelected && isCategorySelected
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
    }
    
    func configureForEditing(tracker: Tracker, categoryName: String) {
        self.isEditMode = true
        self.editingTracker = tracker
        self.originalCategoryName = categoryName
        
        self.selectedCategoryName = categoryName
        
        self.selectedDays = tracker.schedule.map { $0.rawValue }
        
        if let emojiIndex = emojis.firstIndex(of: tracker.emoji) {
            self.selectedEmojiIndexPath = IndexPath(row: emojiIndex, section: 0)
        }
        if let colorIndex = colors.firstIndex(where: { $0.toColorString == tracker.color.toColorString }) {
            self.selectedColorIndexPath = IndexPath(row: colorIndex, section: 1)
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonTapped() {
        guard let trackerName = nameTrackerTextField.text, !trackerName.isEmpty,let emojiIndex = selectedEmojiIndexPath?.row,let colorIndex = selectedColorIndexPath?.row, let categoryTitle = selectedCategoryName  else { return }
        
        let weekDaysArray = selectedDays.compactMap { WeekDay(rawValue: $0) }
        let scheduleSet = Set(weekDaysArray)
        
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: colors[colorIndex],
            emoji: emojis[emojiIndex],
            schedule: scheduleSet
        )
        
        let trackerStore = TrackerStore()
        if isEditMode {
            guard let oldTracker = editingTracker else { return }
            
            let updatedTracker = Tracker(
                id: oldTracker.id,
                name: trackerName,
                color: colors[colorIndex],
                emoji: emojis[emojiIndex],
                schedule: scheduleSet,
                isPinned: oldTracker.isPinned
            )
            
            do {
                try trackerStore.updateTracker(
                    updatedTracker,
                    oldCategory: originalCategoryName ?? "",
                    newCategory: categoryTitle
                )
                dismiss(animated: true, completion: nil)
            } catch {
                print("Ошибка обновления трекера в Core Data: \(error)")
            }
            
        } else {
            let newTracker = Tracker(
                id: UUID(),
                name: trackerName,
                color: colors[colorIndex],
                emoji: emojis[emojiIndex],
                schedule: scheduleSet
            )
            
            do {
                try trackerStore.createTracker(newTracker, toCategoryTitle: categoryTitle)
                delegate?.createTrackerViewController(self, didCreateTracker: newTracker, toCategory: categoryTitle)
                
                dismiss(animated: true, completion: nil)
            } catch {
                print("Ошибка сохранения трекера в Core Data: \(error)")
            }
        }
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

extension CreateTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "OptionCell")
        cell.backgroundColor = .clear
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.accessoryType = .disclosureIndicator
        
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = .ypGray
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "createTracker.category".localized()
            if let selectedCategoryName = selectedCategoryName {
                cell.detailTextLabel?.text = selectedCategoryName
            } else {
                cell.detailTextLabel?.text = ""
            }
        } else {
            cell.textLabel?.text = "createTracker.schedule".localized()
            cell.detailTextLabel?.text = convertDaysToText(days: selectedDays)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let store = TrackerCategoryStore()
            let categoryViewModel = CategoryViewModel(categoryStore: store, selectedCategoryTitle: self.selectedCategoryName)
            let categoryVC = CategoryViewController(viewModel: categoryViewModel)
            
            categoryViewModel.onCategorySelected = { [weak self] selectedCategoryTitle in
                guard let self = self else { return }
                self.selectedCategoryName = selectedCategoryTitle
                self.optionsTableView.reloadData()
                self.checkValidation()
            }
            let navigationController = UINavigationController(rootViewController: categoryVC)
            present(navigationController, animated: true)
        } else {
            if indexPath.row == 1 {
                let scheduleViewController = ScheduleViewController(selectedDays: self.selectedDays)
                scheduleViewController.delegate = self
                
                present(scheduleViewController, animated: true)
            }
        }
    }
}

extension CreateTrackerViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkValidation()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if updatedText.count > 38 {
            errorLabel.isHidden = false
            checkValidation()
            return false
        }
        else {
            errorLabel.isHidden = true
            return true
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        errorLabel.isHidden = true
        createButton.isEnabled = false
        createButton.backgroundColor = .ypGray
        return true
    }
}


extension CreateTrackerViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ vc: ScheduleViewController, didSelectDays days: [Int]) {
        self.selectedDays = days
        
        optionsTableView.reloadData()
    }
}

extension CreateTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else { return UICollectionViewCell() }
            cell.titleLabel.text = emojis[indexPath.row]
            
            if indexPath == selectedEmojiIndexPath {
                cell.backgroundColor = .ypLightGray
                cell.layer.cornerRadius = 16
            } else {
                cell.backgroundColor = .clear
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else { return UICollectionViewCell() }
            let color = colors[indexPath.row]
            cell.colorView.backgroundColor = color
            
            if indexPath == selectedColorIndexPath {
                cell.layer.borderWidth = 3
                cell.layer.borderColor = color.withAlphaComponent(0.3).cgColor
                cell.layer.cornerRadius = 8
            } else {
                cell.layer.borderWidth = 0
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderSectionView.identifier, for: indexPath) as? HeaderSectionView else {
            return UICollectionReusableView()
        }
        header.titleLabel.text = indexPath.section == 0 ? "Emoji" : "createTracker.color".localized()
        return header
    }
}

extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let oldIndexPath = selectedEmojiIndexPath
            selectedEmojiIndexPath = indexPath
            var indexPathsToReload = [indexPath]
            if let old = oldIndexPath { indexPathsToReload.append(old) }
            collectionView.reloadItems(at: indexPathsToReload)
        } else {
            let oldIndexPath = selectedColorIndexPath
            selectedColorIndexPath = indexPath
            var indexPathsToReload = [indexPath]
            if let old = oldIndexPath { indexPathsToReload.append(old) }
            collectionView.reloadItems(at: indexPathsToReload)
        }
        checkValidation()
    }
}
