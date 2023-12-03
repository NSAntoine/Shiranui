//
//  ShiranuiApp.swift
//  Shiranui
//
//  Created by Serena on 01/12/2023.
//  

import SwiftUI

@main
struct ShiranuiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Initialize AlbumFetcher
                    _ = AlbumFetcher.shared
                }
        }
    }
}
