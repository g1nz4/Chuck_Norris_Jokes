import Foundation
import RealmSwift
import KeychainAccess

final class RealmProvider {
    
    static let shared = RealmProvider()
    
    private let configuration: Realm.Configuration
    
    private init() {
        let key = RealmProvider.generateKey()
        var config = Realm.Configuration()
        config.encryptionKey = key
        self.configuration = config
    }
    
    func getRealm() throws -> Realm {
        try Realm(configuration: configuration)
    }
}

private extension RealmProvider {
    
    static let service = "com.chuck-norris-jokes.realm"
    static let realmKey = "realm-encryption-key"
    
    static func generateKey() -> Data {
        let keychain = Keychain(service: service)
        
        if let data = (try? keychain.getData(realmKey)) as Data?,
           data.count == 64 {
            return data
        }
        
        var key = Data(count: 64)
        let result = key.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 64, bytes.baseAddress!)
        }
        precondition(result == errSecSuccess, "Не удалось сгенерировать ключ.")
        
        do {
            try keychain.set(key, key: realmKey)
        } catch {
            preconditionFailure("Не удалось сохранить ключ: \(error)")
        }
        
        return key
    }
}
