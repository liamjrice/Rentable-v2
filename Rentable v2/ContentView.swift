//
//  ContentView.swift
//  Rentable v2
//
//  Created by Liam Rice on 17/10/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        UIKitRootView()
            .ignoresSafeArea()
    }
}

struct UIKitRootView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return RootTabBarController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    ContentView()
}

