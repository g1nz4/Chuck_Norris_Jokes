import Foundation

protocol JokesServiceProtocol {
    func fetchRandomJoke() async throws -> Joke
}

final class JokesService: JokesServiceProtocol {
    
    private let baseURL = "https://api.chucknorris.io/jokes/random"
    
    func fetchRandomJoke() async throws -> Joke {
        let data = try await NetworkService.urlSessionAsync(stringURL: baseURL)
        let dto = try JSONDecoder().decode(Joke.self, from: data)
        return dto
    }
}
