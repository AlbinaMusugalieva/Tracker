//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import Foundation

import UIKit

final class CreateCategoryViewController: UIViewController {
    
    private let categoryStore = TrackerCategoryStore()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = .ypBackground
        textField.textColor = .ypBlack
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.layer.cornerRadius = 16
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            doneButton.isEnabled = true
            doneButton.backgroundColor = .ypBlack
        } else {
            doneButton.isEnabled = false
            doneButton.backgroundColor = .ypGray
        }
    }
    
    @objc private func didTapDoneButton() {
        guard let categoryName = textField.text, !categoryName.isEmpty else { return }
        
        do {
            _ = try categoryStore.fetchOrCreateCategory(with: categoryName)
            
            dismiss(animated: true)
        } catch {
            print("Ошибка при сохранении категории: \(error)")
        }
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func setupViews() {
        view.backgroundColor = .ypWhite
        title = "Новая категория"
        
        view.addSubview(textField)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
