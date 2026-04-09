import Foundation
import RealmSwift

struct Joke: Decodable {
    let id: String
    let value: String
    let url: String
    let categories: [String]
}

final class JokeObject: Object {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var value: String
    @Persisted var url: String
    @Persisted var createdAt: Date
    @Persisted var categories = List<String>()
    
    convenience init(id: String,
                     value: String,
                     url: String,
                     createdAt: Date = Date(),
                     categories: [String] = []) {
        self.init()
        self.id = id
        self.value = value
        self.url = url
        self.createdAt = createdAt
        self.categories.removeAll()
        self.categories.append(objectsIn: categories)
    }
}
