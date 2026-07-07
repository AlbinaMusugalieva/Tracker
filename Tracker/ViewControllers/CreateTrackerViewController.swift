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
    
    private let titleLabel = UILabel()
    private let nameTrackerTextField = UITextField()
    private let createButton = UIButton(type: .system)
    private let optionsTableView = UITableView()
    private let cancelButton = UIButton(type: .system)
    private let buttonsStackView = UIStackView()
    private let errorLabel = UILabel()
    private let scrollView = UIScrollView()
    private var collectionView: UICollectionView!
    private let contentView = UIView()
    
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let colors: [UIColor] = [
        .ypColor1, .ypColor2, .ypColor3, .ypColor4, .ypColor5, .ypColor6,
        .ypColor7, .ypColor8, .ypColor9, .ypColor10, .ypColor11, .ypColor12,
        .ypColor13, .ypColor14, .ypColor15, .ypColor16, .ypColor17, .ypColor18
    ]
    
    private var selectedDays: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupCollectionView()
        setupViews()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
       
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collectionView.register(HeaderSectionView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderSectionView.identifier)
    }
    private func setupViews() {
        
        titleLabel.text = "Новая привычка"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        nameTrackerTextField.placeholder = "Введите название трекера"
        nameTrackerTextField.font = .systemFont(ofSize: 17, weight: .regular)
        nameTrackerTextField.backgroundColor = .ypBackground
        nameTrackerTextField.layer.cornerRadius = 16
        nameTrackerTextField.clearButtonMode = .whileEditing
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameTrackerTextField.leftView = paddingView
        nameTrackerTextField.leftViewMode = .always
        view.addSubview(nameTrackerTextField)
        nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTrackerTextField.delegate = self
        
        errorLabel.text = "Ограничение 38 символов"
        errorLabel.font = .systemFont(ofSize: 17, weight: .regular)
        errorLabel.textColor = .ypRed
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        view.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        optionsTableView.backgroundColor = .ypBackground
        optionsTableView.layer.cornerRadius = 16
        optionsTableView.isScrollEnabled = false
        optionsTableView.separatorStyle = .singleLine
        optionsTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        optionsTableView.dataSource = self
        optionsTableView.delegate = self
        
        
        optionsTableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(optionsTableView)
        
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.setTitleColor(.ypWhite, for: .normal)
        createButton.backgroundColor = .ypGray
        createButton.layer.cornerRadius = 16
        createButton.isEnabled = false
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 8
        
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
        view.addSubview(buttonsStackView)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
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
    }
    
    private func convertDaysToText(days: [Int]) -> String? {
        if days.isEmpty { return nil }
        
        if days.count == 7 { return "Каждый день" }
        
        let shortNames = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
        
        let convertedArray = days.map { shortNames[$0] }
        
        return convertedArray.joined(separator: ", ")
    }
    
    private func checkValidation() {
        let isTextFieldNotEmpty = !(nameTrackerTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let currentText = nameTrackerTextField.text ?? ""
        let limitTextLength = currentText.count <= 38
        let isEmojiSelected = selectedEmojiIndexPath != nil
        let isColorSelected = selectedColorIndexPath != nil
        if isTextFieldNotEmpty && limitTextLength && isEmojiSelected && isColorSelected {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonTapped() {
        guard let trackerName = nameTrackerTextField.text, !trackerName.isEmpty,let emojiIndex = selectedEmojiIndexPath?.row,let colorIndex = selectedColorIndexPath?.row  else { return }
        
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
           do {
               try trackerStore.createTracker(newTracker, toCategoryTitle: "Важное")
                  delegate?.createTrackerViewController(self, didCreateTracker: newTracker, toCategory: "Важное")

               dismiss(animated: true, completion: nil)
           } catch {
               print("Ошибка сохранения трекера в Core Data: \(error)")
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
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = nil
        } else {
            cell.textLabel?.text = "Расписание"
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
            //Категория, реализация в будущем
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
        header.titleLabel.text = indexPath.section == 0 ? "Emoji" : "Цвет"
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    
    // Фиксированный размер ячеек 52x52 из Фигмы Практикума
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    // Стандартные отступы секции из ТЗ (18 слева и справа)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
    
    // Минимальный отступ между ячейками
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
