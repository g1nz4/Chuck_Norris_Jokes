import Foundation

protocol CategoriesListViewModelProtocol {
    var numberOfItems: Int { get }
    var onDataChanged: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
        
    func loadListCategories()
    func categoryName(at index: Int) -> String
}

final class CategoriesListViewModel: CategoriesListViewModelProtocol {

    private let db: DataBaseServiceProtocol
    private var categories: [String] = []
    
    var numberOfItems: Int { categories.count }
    var onDataChanged: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(db: DataBaseServiceProtocol = DataBaseService()) {
        self.db = db
    }
    
    func loadListCategories() {
        do {
            categories = try db.fetchAllCategories()
            onDataChanged?()
        } catch {
            onError?("Ошибка загрузки категорий: \(error.localizedDescription)")
        }
    }
    
    func categoryName(at index: Int) -> String {
        guard index < categories.count else { return "" }
        return categories[index]
    }
    
}
