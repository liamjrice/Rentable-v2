//
//  RootTabBarController.swift
//  Rentable v2
//
//  Created by Liam Rice on 17/10/2025.
//

import UIKit

class RootTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        configureAppearance()
    }
    
    private func setupTabs() {
        // Home Tab (Chat Interface)
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.navigationBar.prefersLargeTitles = false
        homeNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // Inbox Tab
        let inboxVC = UIViewController()
        inboxVC.view.backgroundColor = .systemBackground
        inboxVC.title = "Inbox"
        let inboxNav = UINavigationController(rootViewController: inboxVC)
        inboxNav.navigationBar.prefersLargeTitles = false
        inboxNav.tabBarItem = UITabBarItem(
            title: "Inbox",
            image: UIImage(systemName: "envelope"),
            selectedImage: UIImage(systemName: "envelope.fill")
        )
        
        // Settings Tab
        let settingsVC = UIViewController()
        settingsVC.view.backgroundColor = .systemBackground
        settingsVC.title = "Settings"
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.navigationBar.prefersLargeTitles = false
        settingsNav.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        
        // More Tab
        let moreVC = MoreViewController()
        let moreNav = UINavigationController(rootViewController: moreVC)
        moreNav.navigationBar.prefersLargeTitles = false
        moreNav.tabBarItem = UITabBarItem(
            title: "More",
            image: UIImage(systemName: "ellipsis"),
            selectedImage: UIImage(systemName: "ellipsis.circle.fill")
        )
        
        viewControllers = [homeNav, inboxNav, settingsNav, moreNav]
    }
    
    private func configureAppearance() {
        // Modern tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .systemBackground
        
        // Set item colors
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        // Apply appearance
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        // Additional styling
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        tabBar.isTranslucent = false
    }
}

