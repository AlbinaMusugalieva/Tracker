//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import UIKit

final class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private let onboardingData: [(image: UIImage, title: String)] = [
        (UIImage(resource: .background1), "Отслеживайте только то, что хотите"),
        (UIImage(resource: .background2), "Даже если это не желтые стаканы чая")
    ]
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = onboardingData.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypBlack.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let firstViewController = createContentViewController(at: 0) {
            setViewControllers([firstViewController], direction: .forward, animated: true)
        }
        
        setupViews()
    }
    
    @objc private func didTapActionButton() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        window.rootViewController = ViewController()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
    
    private func setupViews() {
        view.addSubview(pageControl)
        view.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            actionButton.heightAnchor.constraint(equalToConstant: 60),
            
            pageControl.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func createContentViewController(at index: Int) -> UIViewController? {
        guard index >= 0 && index < onboardingData.count else { return nil }
        
        let contentViewController = UIViewController()
        contentViewController.view.tag = index
        
        let data = onboardingData[index]
        
        let imageView = UIImageView()
        imageView.image = data.image
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = data.title
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        contentViewController.view.addSubview(imageView)
        contentViewController.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentViewController.view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentViewController.view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentViewController.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentViewController.view.trailingAnchor),
            
            label.leadingAnchor.constraint(equalTo: contentViewController.view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentViewController.view.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: contentViewController.view.centerYAnchor, constant: 60)
        ])
        
        return contentViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = viewController.view.tag
        return createContentViewController(at: currentIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = viewController.view.tag
        return createContentViewController(at: currentIndex + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let currentViewController = pageViewController.viewControllers?.first {
            pageControl.currentPage = currentViewController.view.tag
        }
    }
}
