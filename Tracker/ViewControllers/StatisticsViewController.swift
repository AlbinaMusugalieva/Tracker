//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private let trackerRecordStore = TrackerRecordStore()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .emptyStatisticSmile))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "statistics.empty".localized()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bestPeriodCard = createStatisticCard(title: "statistics.bestPeriod".localized())
    private lazy var idealDaysCard = createStatisticCard(title: "statistics.idealDays".localized())
    private lazy var completedTrackersCard = createStatisticCard(title: "statistics.trackersCompleted".localized())
    private lazy var averageValueCard = createStatisticCard(title: "statistics.averageValue".localized())
    
    private lazy var cardsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [bestPeriodCard, idealDaysCard, completedTrackersCard, averageValueCard])
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(
            title: "statistics.title".localized(),
            image: UIImage(resource: .statisticsLogoTabBar),
            selectedImage: UIImage(resource: .statisticsLogoTabBar)
        )
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigation()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "statistics.title".localized()
    }
    
    private func setupViews() {
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(cardsStackView)
        
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            cardsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            cardsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func createStatisticCard(title: String) -> UIView {
        class GradientBorderView: UIView {
            private let gradientLayer = CAGradientLayer()
            private let shapeLayer = CAShapeLayer()
            
            override init(frame: CGRect) {
                super.init(frame: frame)
                setupGradient()
            }
            
            required init?(coder: NSCoder) {
                super.init(coder: coder)
            }
            
            private func setupGradient() {
                gradientLayer.colors = [
                    UIColor.ypColor5.cgColor,
                    UIColor.ypColor3.cgColor,
                    UIColor.ypColor1.cgColor
                ]
                gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
                gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
                
                shapeLayer.lineWidth = 1
                shapeLayer.fillColor = UIColor.clear.cgColor
                shapeLayer.strokeColor = UIColor.black.cgColor
                
                gradientLayer.mask = shapeLayer
                layer.addSublayer(gradientLayer)
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                
                gradientLayer.frame = bounds
                
                let path = UIBezierPath(roundedRect: bounds, cornerRadius: 16)
                shapeLayer.path = path.cgPath
            }
        }
        
        let cardView = GradientBorderView()
        cardView.backgroundColor = .ypBackground
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let numberLabel = UILabel()
        numberLabel.text = "0"
        numberLabel.font = .systemFont(ofSize: 34, weight: .bold)
        numberLabel.textColor = .label
        numberLabel.tag = 100
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(numberLabel)
        cardView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            numberLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            numberLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
        
        return cardView
    }
    
    private func updateStatistics() {
        let totalCompleted = trackerRecordStore.totalRecordsCount
        
        if totalCompleted == 0 {
            cardsStackView.isHidden = true
            placeholderImageView.isHidden = false
            placeholderLabel.isHidden = false
        } else {
            cardsStackView.isHidden = false
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
            
            if let numberLabel = completedTrackersCard.viewWithTag(100) as? UILabel {
                numberLabel.text = "\(totalCompleted)"
            }
        }
    }
}
