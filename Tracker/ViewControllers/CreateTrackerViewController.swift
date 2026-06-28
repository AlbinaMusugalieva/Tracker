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
    
    private var selectedDays: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupViews() {
        
        titleLabel.text = "Новая привычка"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        view.addSubview(optionsTableView)
        optionsTableView.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            nameTrackerTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            
            optionsTableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsTableView.heightAnchor.constraint(equalToConstant: 150),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
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
        if isTextFieldNotEmpty && limitTextLength{
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
        guard let trackerName = nameTrackerTextField.text, !trackerName.isEmpty else { return }
        
        let weekDaysArray = selectedDays.compactMap { WeekDay(rawValue: $0) }
        let scheduleSet = Set(weekDaysArray)
        
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: .ypGreen,
            emoji: "🚀",
            schedule: scheduleSet
        )
        
        delegate?.createTrackerViewController(self, didCreateTracker: newTracker, toCategory: "Важное")
        
        dismiss(animated: true, completion: nil)
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
