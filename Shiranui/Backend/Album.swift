//
//  Album.swift
//  Shiranui
//
//  Created by Serena on 01/12/2023.
//  

import Foundation

struct AlbumSearchResult: Codable, Hashable {
    let results: [Album]
}

struct Album: Codable, Hashable {
    let title: String
    let barcodes: [String]
    let discogsPagePath: String
    let coverImageURL: URL
    let year: String
    let label: [String]?
    let genres: [String]?
    
    var displayTitle: String {
        var copy = title
        if let first = copy.firstIndex(of: "-") {
            copy.removeSubrange(copy.startIndex...first)
        }
        
        if copy.first == " " { copy.removeFirst() }
        
        return copy
    }
    
    var discogsPageURL: URL {
        URL(string: "https://www.discogs.com" + self.discogsPagePath)!
    }
    /*
     https://www.discogs.com/release/24869834-Shoji-Meguro-Kenichi-Tsuchiya-Toshiko-Tasaki-Tsukasa-Masuko-Shin-Megami-Tensei-III-Nocturne-Maniax-P
     https://www.discogs.com/release/24869834-Shoji-Meguro-Kenichi-Tsuchiya-Toshiko-Tasaki-Tsukasa-Masuko-Shin-Megami-Tensei-III-Nocturne-Maniax-P
     */
    
    enum CodingKeys: String, CodingKey {
        case title
        case barcodes = "barcode"
        case discogsPagePath = "uri"
        case coverImageURL = "cover_image"
        case label
        case year
        case genres = "genre"
    }
}
