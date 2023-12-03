//
//  AlbumFetcher.swift
//  Shiranui
//
//  Created by Serena on 01/12/2023.
//  

import Foundation

class AlbumFetcher {
    static let shared = AlbumFetcher()
    
    let discogsConsumerKey: String
    let discogsConsumerSecret: String
    
    init() {
        guard let keyCString = Bundle.main.object(forInfoDictionaryKey: "DISCOGS_API_KEY") as? String,
              let secretCString = Bundle.main.object(forInfoDictionaryKey: "DISCOGS_API_SECRET") as? String else {
            fatalError(
                "Please configure the DISCOGS_CONSUMER_KEY & DISCOGS_CONSUMER_SECRET Info.plist keys to use the app, see Discogs Developer Documentation for steps on getting your consumer key & secret"
            )
        }
        
        self.discogsConsumerKey = keyCString
        self.discogsConsumerSecret = secretCString
    }
    
    func album(withBarcodeString barcodeString: String) async throws -> AlbumSearchResult {
        var components = URLComponents(string: "https://api.discogs.com/database/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: barcodeString),
            URLQueryItem(name: "key", value: self.discogsConsumerKey),
            URLQueryItem(name: "secret", value: self.discogsConsumerSecret)
        ]
        
        guard let finalURL = components?.url else {
            throw FetcherError("Failed to construct request URL")
        }
        
        let (data, response) = try await URLSession.shared.data(from: finalURL)
        if let statusResponseCode = (response as? HTTPURLResponse) {
            guard (200...299).contains(statusResponseCode.statusCode) else {
                throw FetcherError("Non 200 status code returned by discogs: \(statusResponseCode.statusCode)")
            }
        }
        
//        print(String(data: data, encoding: .utf8))
        return try JSONDecoder().decode(AlbumSearchResult.self, from: data)
    }
    
    struct FetcherError: Swift.Error, LocalizedError, CustomStringConvertible {
        var description: String
        
        init(_ description: String) {
            self.description = description
        }
        
        var errorDescription: String? { description }
    }
}
