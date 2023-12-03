//
//  WelcomeView.swift
//  Shiranui
//
//  Created by Serena on 02/12/2023.
//  

import SwiftUI

struct WelcomeView: View {
    @State var hueRotate: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.dismiss) var dismissAction
    
    // Inspired by Apple's MusicKit example welcome screen
    var body: some View {
        ZStack {
            animatedGradient
            VStack {
                VStack {
                    Text("Shiranui")
                        .foregroundColor(.primary)
                        .font(.largeTitle.weight(.semibold))
                        .shadow(radius: 2)
                    Text("Mostly a demo")
                        .foregroundColor(.primary)
                        .font(.system(size: 14).weight(.semibold).italic())
                        .shadow(radius: 2)
                        .padding(.bottom, 1)
                }
                .preferredColorScheme(.dark)
                .padding(.top, 80)
                
                Spacer()
                Button("Continue") {
                    dismissAction()
                    Preferences.isFirstTimeLaunch = false
                }
                .preferredColorScheme(.light)
                .font(.title3.bold())
                .foregroundColor(.accentColor)
                .padding()
                .background(Color(uiColor: (colorScheme == .dark) ? .secondarySystemBackground : .systemBackground).cornerRadius(8))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).speed(0.70).repeatForever(autoreverses: true)) {
                hueRotate.toggle()
            }
        }
        .interactiveDismissDisabled()
    }
    
    @ViewBuilder
    var animatedGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .blue,
                Color(red: 0.968627, green: 0.309804, blue: 0.619608),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .hueRotation(.degrees(hueRotate ? 35.65 : 0))
    }
}
