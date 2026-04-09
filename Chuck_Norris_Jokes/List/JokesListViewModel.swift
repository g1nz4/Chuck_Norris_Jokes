import Foundation
import RealmSwift

enum JokesListMode {
    case all
    case category(String)
}

protocol JokesListViewModelProtocol {
    var title: String { get }
    var numberOfItems: Int { get }
    var onDataChanged: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    
    func loadJokes()
    func jokeText(at index: Int) -> String
    func subtitleText(at index: Int) -> String
    func deleteJoke(at index: Int)
}

final class JokesListViewModel: JokesListViewModelProtocol {
    
    private let db: DataBaseServiceProtocol
    private let mode: JokesListMode
    private var jokes: [JokeObject] = []
    
    var title: String {
        switch mode {
        case .all:
            return "Все цитаты"
        case .category(let name):
            return name
        }
    }
    var numberOfItems: Int { return jokes.count }
    var onDataChanged: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(mode: JokesListMode,
        db: DataBaseServiceProtocol = DataBaseService()
    ) {
        self.mode = mode
        self.db = db
    }
    
    func loadJokes() {
        do {
            switch mode {
                case .all:
                    jokes = try db.fetchAllJokesSortedByDate()
                case .category(let category):
                    jokes = try db.fetchJokes(forCategory: category)
                }
                onDataChanged?()
        } catch {
            onError?("Ошибка загрузки из БД: \(error.localizedDescription)")
        }
    }
    
    func jokeText(at index: Int) -> String {
        guard index < jokes.count else { return "" }
        return jokes[index].value
    }
    
    func subtitleText(at index: Int) -> String {
        guard index < jokes.count else { return "" }
        
        let joke = jokes[index]
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        let dateString = formatter.string(from: joke.createdAt)
        
        return "\(dateString)"
    }
    
    func deleteJoke(at index: Int) {
        guard index < jokes.count else { return }
        let id = jokes[index].id
        do {
            try db.deleteJoke(joke: id)
            NotificationCenter.default.post(name: .jokesDidChange, object: nil)
            loadJokes()
        } catch {
            onError?("Ошибка удаления: \(error.localizedDescription)")
        }
    }
}
