//
//  ScanItemRow.swift
//  Shiranui
//
//  Created by Serena on 01/12/2023.
//  

import SwiftUI

struct ScanItemRow: View {
    @Binding var showingBarcodeSheet: Bool
    @State var animateGradient: Bool = true
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        mainView
    }
    
    @ViewBuilder
    var mainView: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(LinearGradient(colors: [.blue, Color(red: 0.968627, green: 0.309804, blue: 0.619608)], startPoint: .topLeading, endPoint: .bottomTrailing)/*.shadow(.drop(radius: 5))*/)
            .shadow(radius: 5)
            .hueRotation(.degrees(animateGradient ? 35.65 : 0))
            .animation(.easeInOut(duration: 1).speed(0.45).repeatForever(autoreverses: true), value: animateGradient)
            .frame(height: 140)
            .overlay {
                HStack {
                    Image(systemName: "barcode.viewfinder")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                    Text("Scan Album")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
            }
            .onAppear {
//                withAnimation(.easeInOut(duration: 1).speed(0.45).repeatForever(autoreverses: true)) {
//                    animateGradient.toggle()
//                }
            }
//            .shadow(radius: 25)
            .onTapGesture {
                self.showingBarcodeSheet = true
            }
    }
}

struct ScanItemViewControllerBridge: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return UINavigationController(rootViewController: ScanItemViewController())
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
