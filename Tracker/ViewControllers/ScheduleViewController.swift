//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(_ vc: ScheduleViewController, didSelectDays days: [Int])
}

class ScheduleViewController: UIViewController {
    weak var delegate: ScheduleViewControllerDelegate?
    private let weekDays = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private var selectedDays: [Int] = []
    
    private let titleLabel = UILabel()
    private let scheduleTableView = UITableView()
    private let doneButton = UIButton(type: .system)
    
    init(selectedDays: [Int]) {
        self.selectedDays = selectedDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupViews()
    }
    
    private func setupViews(){
        
        titleLabel.text = "Расписание"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scheduleTableView.backgroundColor = .ypBackground
        scheduleTableView.layer.cornerRadius = 16
        scheduleTableView.isScrollEnabled = false
        scheduleTableView.separatorStyle = .singleLine
        scheduleTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        view.addSubview(scheduleTableView)
        scheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        
        doneButton.setTitle("Готово", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.setTitleColor(.ypWhite, for: .normal)
        doneButton.backgroundColor = .ypBlack
        doneButton.layer.cornerRadius = 16
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scheduleTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    
    @objc private func doneButtonTapped() {
        delegate?.scheduleViewController(self, didSelectDays: selectedDays)
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "WeekDayCell")
        cell.backgroundColor = .clear
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .label 
        cell.textLabel?.text = weekDays[indexPath.row]
        
        let switchView = UISwitch()
        switchView.onTintColor = .ypBlue
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        switchView.isOn = selectedDays.contains(indexPath.row)
        cell.accessoryView = switchView
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension ScheduleViewController {
    @objc private func switchChanged(_ sender: UISwitch) {
        let dayIndex = sender.tag
        
        if sender.isOn {
            if !selectedDays.contains(dayIndex) {
                selectedDays.append(dayIndex)
            }
        } else {
            if let indexToRemove = selectedDays.firstIndex(of: dayIndex) {
                selectedDays.remove(at: indexToRemove)
            }
        }
        
        selectedDays.sort()
    }
}
