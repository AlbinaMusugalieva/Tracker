//
//  TrackerCellCollectionViewCell.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackerCompletionButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.tintColor = .ypWhite
        button.addTarget(self, action: #selector(trackButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var completionButtonTappedHandler: (() -> Void)?
    
    override init (frame: CGRect){
        super.init (frame: frame)
        setupViews()
        
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupViews(){
        contentView.addSubview(colorView)
        colorView.addSubview(emojiLabel)
        colorView.addSubview(titleLabel)
        contentView.addSubview(daysLabel)
        contentView.addSubview(trackerCompletionButton)
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            
            daysLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            trackerCompletionButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            trackerCompletionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            trackerCompletionButton.widthAnchor.constraint(equalToConstant: 34),
            trackerCompletionButton.heightAnchor.constraint(equalToConstant: 34),
            trackerCompletionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
    }
    
    func configure(with tracker: Tracker, completedDays: Int, isCompleted: Bool) {
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        colorView.backgroundColor = tracker.color
        trackerCompletionButton.backgroundColor = tracker.color
        
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: ""),
            completedDays
        )
        daysLabel.text = daysString
        
        var config = UIButton.Configuration.filled()
        
        config.background.backgroundColor = tracker.color
        config.background.cornerRadius = 17
        config.baseForegroundColor = .white
        
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 11, weight: .regular)
        let iconImage = UIImage(systemName: isCompleted ? "checkmark" : "plus", withConfiguration: imageConfiguration)
        
        config.image = iconImage
        config.imagePlacement = .top
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        trackerCompletionButton.configuration = config
        
        trackerCompletionButton.alpha = isCompleted ? 0.5 : 1.0
    }
    
    @objc private func trackButtonTapped() {
        completionButtonTappedHandler?()
    }
}
