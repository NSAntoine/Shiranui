//
//  ContentView.swift
//  Shiranui
//
//  Created by Serena on 01/12/2023.
//

import SwiftUI

struct ContentView: View {
    @State var searchText: String = ""
    @State var showingScanViewController: Bool = false
    @State var showingWelcomeSheet: Bool = Preferences.isFirstTimeLaunch
    @State var albums: [Album] = Preferences.userScannedAlbums
    
    @State var selectedAlbum: Album?
    @Namespace var namespace
    
    let backgroundColor = Color(UIColor.secondarySystemBackground)
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                List {
                    standardForEachView
                        .listRowBackground(backgroundColor)
                        .listRowSeparator(.hidden)
                    ScanItemRow(showingBarcodeSheet: $showingScanViewController)
                        .listRowBackground(backgroundColor)
                        .listRowSeparator(.hidden)
                }
                
                .listStyle(.plain)
                .navigationTitle("Shiranui")
                .searchable(text: $searchText)
                .onAppear {
                    NotificationCenter.default.addObserver(forName: .userScannedAlbumsDidChange, object: nil, queue: nil) { notif in
                        guard let newAlbums = notif.object as? [Album] else { return }
                        withAnimation {
                            self.albums = newAlbums
                        }
                    }
                }
                .sheet(isPresented: $showingScanViewController) {
                    ScanItemViewControllerBridge()
                        .presentationDetents([.fraction(0.5)])
                }
                .sheet(isPresented: $showingWelcomeSheet) {
                    WelcomeView()
                }
            }
        }
    }
    
    @ViewBuilder
    var standardForEachView: some View {
        ForEach(self.searchText.isEmpty ? albums : albums.filter { $0.displayTitle.contains(searchText) }, id: \.self) { album in
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                    self.selectedAlbum = album
                }
            } label: {
                AlbumRow(album: album)
                    .listRowSeparator(.hidden)
                    .contextMenu {
                        Button(role: .destructive) {
                            Preferences.userScannedAlbums.removeAll { iteratedAlbum in
                                return iteratedAlbum == album
                            }
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
            }
        }
    }
}
