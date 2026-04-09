import Foundation

protocol RandomJokeViewModelProtocol {
    var onJokeUpdated: ((String) -> Void)? { get set }
    var onLoadingChanged: ((Bool) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    
    func loadRandomJoke() async
}

final class RandomJokeViewModel: RandomJokeViewModelProtocol {
    
    private let jokeService: JokesServiceProtocol
    private let dataBase: DataBaseServiceProtocol
    
    private let dbQueue = DispatchQueue(label: "quotes.db.queue", qos: .background)
    
    var onJokeUpdated: ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    
    init(jokeService: JokesServiceProtocol = JokesService(),
         dataBase: DataBaseServiceProtocol = DataBaseService()) {
        self.jokeService = jokeService
        self.dataBase = dataBase
    }
    
    func loadRandomJoke() async {
        onLoadingChanged?(true)
        
        do {
            let joke = try await jokeService.fetchRandomJoke()
            
            try await saveToDatabase(joke: joke)
            _ = joke.categories.isEmpty ? "Без категории" : joke.categories.joined(separator: ", ")
            
            let text = "\(joke.value)"
            onLoadingChanged?(false)
            onJokeUpdated?(text)
        } catch {
            onLoadingChanged?(false)
            onError?("Ошибка: \(error.localizedDescription)")
        }
    }
    
    private func saveToDatabase(joke: Joke) async throws {
        try await withCheckedThrowingContinuation { continuation in
            dbQueue.async {
                do {
                    try self.dataBase.save(joke: joke)
                    NotificationCenter.default.post(name: .jokesDidChange, object: nil)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
