//
//  MainTabView.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import SwiftUI

struct MainTabView: View {
    
    // MARK: - Properties
    
    @State private var selectedTab: Tab = .home
    @StateObject private var appState = AppState.shared
    
    // MARK: - Tab Enum
    
    enum Tab {
        case home
        case properties
        case more
    }
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack {
                homeView
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(Tab.home)
            
            // Properties Tab
            NavigationStack {
                propertiesView
            }
            .tabItem {
                Label("Properties", systemImage: "building.2.fill")
            }
            .tag(Tab.properties)
            
            // More Tab
            NavigationStack {
                moreView
            }
            .tabItem {
                Label("More", systemImage: "ellipsis.circle.fill")
            }
            .tag(Tab.more)
        }
        .tint(.blue)
    }
    
    // MARK: - Tab Views
    
    private var homeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "house.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
            
            Text("Welcome to Rentable")
                .font(.title.bold())
            
            // Line 70-79
            if let user = appState.currentUser {
                Text("Hello, \(user.fullName ?? "there")!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Home")
    }
    
    private var propertiesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.2.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
            
            Text("Properties")
                .font(.title.bold())
            
            Text("Your rental properties will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Properties")
    }
    
    private var moreView: some View {
        List {
            Section("Account") {
                if let user = appState.currentUser {
                    HStack {
                        if let imageURL = user.profileImageURL,
                           let url = URL(string: imageURL) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullName ?? "User")
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Section("Settings") {
                NavigationLink {
                    Text("Profile Settings")
                } label: {
                    Label("Profile", systemImage: "person.fill")
                }
                
                NavigationLink {
                    Text("Notifications")
                } label: {
                    Label("Notifications", systemImage: "bell.fill")
                }
                
                NavigationLink {
                    Text("Privacy & Security")
                } label: {
                    Label("Privacy", systemImage: "lock.fill")
                }
            }
            
            Section("Support") {
                NavigationLink {
                    Text("Help Center")
                } label: {
                    Label("Help", systemImage: "questionmark.circle.fill")
                }
                
                NavigationLink {
                    Text("About")
                } label: {
                    Label("About", systemImage: "info.circle.fill")
                }
            }
            
            Section {
                Button(role: .destructive, action: {
                    Task {
                        await AppCoordinator.shared.logout()
                    }
                }) {
                    Label("Sign Out", systemImage: "arrow.right.square.fill")
                }
            }
        }
        .navigationTitle("More")
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}

