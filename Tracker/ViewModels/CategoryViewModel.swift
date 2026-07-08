//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import Foundation

protocol CategoryViewModelProtocol {
    var onCategoriesChanged: (() -> Void)? { get set }
    var onCategorySelected: ((String) -> Void)? { get set }
    var numberOfCategories: Int { get }

    func categoryTitle(at index: Int) -> String
    func isCategorySelected(at index: Int) -> Bool
    func selectCategory(at index: Int)
    func fetchCategories()
}

final class CategoryViewModel: CategoryViewModelProtocol {
    private let categoryStore: TrackerCategoryStore
    private var categories: [TrackerCategory] = []
    private var selectedCategoryTitle: String?

    var onCategoriesChanged: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?

    var numberOfCategories: Int {
        return categories.count
    }

    init(categoryStore: TrackerCategoryStore, selectedCategoryTitle: String? = nil) {
        self.categoryStore = categoryStore
        self.selectedCategoryTitle = selectedCategoryTitle
        self.categoryStore.delegate = self
        fetchCategories()
    }

    func fetchCategories() {
        self.categories = categoryStore.fetchAllCategories()
        onCategoriesChanged?()
    }

    func categoryTitle(at index: Int) -> String {
        guard index < categories.count else { return "" }
        return categories[index].title
    }

    func isCategorySelected(at index: Int) -> Bool {
        guard index < categories.count else { return false }
        return categories[index].title == selectedCategoryTitle
    }

    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        let selectedTitle = categories[index].title
        self.selectedCategoryTitle = selectedTitle
        
        onCategoriesChanged?()
        
        onCategorySelected?(selectedTitle)
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func storeDidUpdate() {
        fetchCategories()
    }
}
