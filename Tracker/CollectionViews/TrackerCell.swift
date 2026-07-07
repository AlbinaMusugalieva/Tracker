//
//  TrackerCellCollectionViewCell.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    private let colorView = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let daysLabel = UILabel()
    private let trackerCompletionButton = UIButton(type: .system)
    var completionButtonTappedHandler: (() -> Void)?
    
    override init (frame: CGRect){
        super.init (frame: frame)
        setupViews()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 16
        colorView.layer.masksToBounds = true
        
        colorView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        colorView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white
        
        contentView.addSubview(daysLabel)
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        daysLabel.textColor = .black
        
        contentView.addSubview(trackerCompletionButton)
        trackerCompletionButton.translatesAutoresizingMaskIntoConstraints = false
        trackerCompletionButton.layer.cornerRadius = 17
        trackerCompletionButton.layer.masksToBounds = true
        trackerCompletionButton.tintColor = .white
        trackerCompletionButton.addTarget(self, action: #selector(trackButtonTapped), for: .touchUpInside)

        
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
        
        daysLabel.text = "\(completedDays) дней"
        
        var config = UIButton.Configuration.filled()
        
        config.background.backgroundColor = tracker.color
        config.background.cornerRadius = 17
        config.baseForegroundColor = .white
        
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 11, weight: .regular)
        let iconImage = isCompleted ? UIImage(systemName: "checkmark", withConfiguration: imageConfiguration) : UIImage(systemName: "plus", withConfiguration: imageConfiguration)
        
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
