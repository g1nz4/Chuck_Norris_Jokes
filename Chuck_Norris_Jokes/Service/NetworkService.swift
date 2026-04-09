import Foundation

enum NetworkError: Error {
    case invalidURL
    case badStatusCode(Int)
}

final class NetworkService {
    
    static func urlSessionAsync(stringURL: String) async throws -> Data {
        guard let url = URL(string: stringURL) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse,
           !(200..<300).contains(httpResponse.statusCode) {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
        
        return data
    }
}
