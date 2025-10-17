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
        // Auth Tab
        let authVC = AuthenticationViewController()
        let authNav = UINavigationController(rootViewController: authVC)
        authNav.navigationBar.prefersLargeTitles = false
        authNav.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "person.circle"),
            selectedImage: UIImage(systemName: "person.circle.fill")
        )
        authNav.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        // Properties Tab
        let propertiesVC = PropertyListViewController()
        let propertiesNav = UINavigationController(rootViewController: propertiesVC)
        propertiesNav.navigationBar.prefersLargeTitles = false
        propertiesNav.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        propertiesNav.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        // Landlord Tab
        let landlordVC = LandlordDashboardViewController()
        let landlordNav = UINavigationController(rootViewController: landlordVC)
        landlordNav.navigationBar.prefersLargeTitles = false
        landlordNav.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "person.2"),
            selectedImage: UIImage(systemName: "person.2.fill")
        )
        landlordNav.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        viewControllers = [authNav, propertiesNav, landlordNav]
    }
    
    private func configureAppearance() {
        // Remove tab bar background for a cleaner look
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        
        // Set item colors
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        
        // Apply appearance
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        // Additional styling
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        tabBar.isTranslucent = true
    }
}

