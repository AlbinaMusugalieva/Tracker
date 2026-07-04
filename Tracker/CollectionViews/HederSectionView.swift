//
//  HederSectionView.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import UIKit

final class HeaderSectionView: UICollectionReusableView {
    static let identifier = "HeaderSectionView"
    
    let titleLabel = UILabel ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        addSubview(titleLabel)
        titleLabel.font = .boldSystemFont(ofSize: 19)
        titleLabel.textColor = .ypBlack
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
