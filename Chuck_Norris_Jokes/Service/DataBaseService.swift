import Foundation
import RealmSwift

protocol DataBaseServiceProtocol {
    func save(joke: Joke) throws
    func deleteJoke(joke id: String) throws
    func fetchAllJokesSortedByDate() throws -> [JokeObject]
    func fetchAllCategories() throws -> [String]
    func fetchJokes(forCategory category: String) throws -> [JokeObject]
}

final class DataBaseService: DataBaseServiceProtocol {

    func save(joke: Joke) throws {
        let realm = try RealmProvider.shared.getRealm()
        
        let categories: [String]
            if joke.categories.isEmpty {
                categories = ["Без категории"]
            } else {
                categories = joke.categories
            }
        
        let object = JokeObject(
            id: joke.id,
            value: joke.value,
            url: joke.url,
            createdAt: Date(),
            categories: categories
        )
        
        try realm.write {
            realm.add(object, update: .modified)
        }
    }
    
    func deleteJoke(joke id: String) throws {
        let realm = try RealmProvider.shared.getRealm()
        
        guard let object = realm.object(ofType: JokeObject.self, forPrimaryKey: id) else { return }
        try realm.write {
            realm.delete(object)
        }
    }
    
    func fetchAllJokesSortedByDate() throws -> [JokeObject] {
        let realm = try RealmProvider.shared.getRealm()
    
        let results = realm.objects(JokeObject.self)
            .sorted(byKeyPath: "createdAt", ascending: false)
        return Array(results)
    }
    
    func fetchAllCategories() throws -> [String] {
        let realm = try RealmProvider.shared.getRealm()
        
        let jokes = realm.objects(JokeObject.self)
        
        var set = Set<String>()
        for joke in jokes {
            for jokeCategory in joke.categories {
                set.insert(jokeCategory)
            }
        }
        
        return Array(set).sorted()
    }
    
    func fetchJokes(forCategory category: String) throws -> [JokeObject] {
        let realm = try RealmProvider.shared.getRealm()
        
        let result =  realm.objects(JokeObject.self)
            .filter("ANY categories == %@", category)
            .sorted(byKeyPath: "createdAt", ascending: false)
        
        return Array(result)
    }
}
