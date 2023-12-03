//
//  AlbumRow.swift
//  Shiranui
//
//  Created by Serena on 01/12/2023.
//  

import SwiftUI

struct AlbumRow: View {
    let album: Album
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
//        AlbumRow2(album: album)
        mainView
    }
    
    @ViewBuilder
    var mainView: some View {
        VStack(spacing: 0) {
            cardContents
                .padding([.bottom, .top], 16)
                .background(colorScheme == .dark ? Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)) : .white)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 15, topTrailingRadius: 15))
                .shadow(radius: 5)
                .mask(Rectangle().padding([.top, .horizontal], -20))
                .frame(width: 385)
            UnevenRoundedRectangle(bottomLeadingRadius: 15, bottomTrailingRadius: 15)
                .foregroundColor(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray))
                .frame(width: 385, height: 40)
                .shadow(radius: 5)
                .overlay {
                    HStack {
                        Button.init {
                            UIApplication.shared.open(album.discogsPageURL)
                        } label: {
                            HStack {
                                Image(.discogs)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(10)
                                Text("View in Discogs")
                                    .foregroundStyle(.viewInDiscogsButtonText)
                            }
                            .padding(.leading, 20)
                        }

                        Spacer()
                    }
                }
                .mask(Rectangle().padding([.bottom, .horizontal], -20))
        }
    }
    
    @ViewBuilder
    var cardContents: some View {
        HStack {
            AsyncImage(url: album.coverImageURL) { image in
                image.image?
                    .resizable()
                    .frame(width: 100, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.leading)
            }
            
            VStack(alignment: .leading) {
                Text(album.displayTitle)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .fixedSize(horizontal: false, vertical: true)
                Text(makeSubtitleText())
                    .font(.system(size: 10).italic())
                    .foregroundStyle(.secondary)
            }
            .padding(.trailing)
        }
//        
//        HStack {
//            Spacer()
//            
//            Button.init {
//                UIApplication.shared.open(album.discogsPathURL)
//            } label: {
//                HStack {
//                    Image(.discogs)
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .cornerRadius(10)
//                    Text("View in Discogs")
//                        .foregroundStyle(/*Color(red: 0.20, green: 0.20, blue: 0.20)*/Color(red: 0.95, green: 0.95, blue: 0.95))
//                    /*
//                        .foregroundStyle(LinearGradient(colors: [
//                            Color(red: 0.20, green: 0.20, blue: 0.20),
//                            Color(red: 0.95, green: 0.95, blue: 0.95),
//                            Color(red: 0.20, green: 0.20, blue: 0.20)
//                        ], startPoint: .leading, endPoint: .trailing))
//                     */
//                }
//            }
//            .padding(.trailing)
//            .buttonStyle(.bordered)
//        }
    }
    
    func makeSubtitleText() -> String {
        var initialText = String(album.year)
        
        if let genres = album.genres {
            initialText.append(" • \(genres.joined(separator: ", "))")
        }
        return initialText
    }
}

struct AlbumRow2: View {
    let album: Album
    
    var body: some View {
        mainView
            .clipShape(RoundedRectangle(cornerRadius: 25))
    }
    
    @ViewBuilder
    var mainView: some View {
        AsyncImage(url: album.coverImageURL) { image in
            image.image?
                .resizable()
                .frame(width: 385, height: 255)
                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .padding(.leading)
        }
    }
}
