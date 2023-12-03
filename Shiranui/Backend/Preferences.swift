//
//  Preferences.swift
//  Shiranui
//
//  Created by Serena on 01/12/2023.
//  

import Foundation

@propertyWrapper
struct Storage<Value> {
    let key: String
    let defaultValue: Value
    
    var wrappedValue: Value {
        get {
            UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct CodableStorage<Value: Codable> {
    let key: String
    let defaultValue: Value
    let changeCallback: (Value) -> Void
    
    var wrappedValue: Value {
        get {
            guard let data = UserDefaults.standard.data(forKey: key),
                  let decoded = try? JSONDecoder().decode(Value.self, from: data) else {
                return defaultValue
            }
            
            return decoded
        }
        
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                changeCallback(newValue)
                UserDefaults.standard.set(encoded, forKey: key)
            }
        }
    }
}

enum Preferences {
    @Storage(key: "isFirstTimeLaunch", defaultValue: true)
    static var isFirstTimeLaunch: Bool
    
    @CodableStorage(key: "UserScannedAlbums", defaultValue: [], changeCallback: { newAlbums in
        NotificationCenter.default.post(name: .userScannedAlbumsDidChange, object: newAlbums)
    })
    static private var _userScannedAlbums: [Album]
    
    static var userScannedAlbums: [Album] {
        get {
            let albums = _userScannedAlbums
            print(albums)
            return albums
        }
        
        set {
            // In order to keep userScannedAlbums unique while still having it be an array
            // we do this
            _userScannedAlbums = Array(Set(newValue))
        }
    }
}
