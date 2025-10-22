//
//  MoreViewController.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import UIKit

class MoreViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    // MARK: - Properties
    
    private struct MenuItem {
        let icon: String
        let title: String
        let subtitle: String?
        let action: () -> Void
        
        init(icon: String, title: String, subtitle: String? = nil, action: @escaping () -> Void) {
            self.icon = icon
            self.title = title
            self.subtitle = subtitle
            self.action = action
        }
    }
    
    private var menuSections: [[MenuItem]] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMenuItems()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "More"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupMenuItems() {
        // Account Section
        let accountSection = [
            MenuItem(icon: "person.circle", title: "Profile", subtitle: "View and edit your profile") { [weak self] in
                self?.showProfile()
            },
            MenuItem(icon: "crown", title: "Upgrade to Premium", subtitle: "Unlock all features") { [weak self] in
                self?.showUpgrade()
            }
        ]
        
        // App Section
        let appSection = [
            MenuItem(icon: "bell", title: "Notifications", subtitle: "Manage your alerts") { [weak self] in
                self?.showNotifications()
            },
            MenuItem(icon: "lock.shield", title: "Privacy & Security") { [weak self] in
                self?.showPrivacy()
            },
            MenuItem(icon: "paintbrush", title: "Appearance", subtitle: "Customize your experience") { [weak self] in
                self?.showAppearance()
            }
        ]
        
        // Help Section
        let helpSection = [
            MenuItem(icon: "questionmark.circle", title: "Help & Support") { [weak self] in
                self?.showHelp()
            },
            MenuItem(icon: "star", title: "Rate the App") { [weak self] in
                self?.rateApp()
            },
            MenuItem(icon: "info.circle", title: "About", subtitle: "Version 1.0.0") { [weak self] in
                self?.showAbout()
            }
        ]
        
        menuSections = [accountSection, appSection, helpSection]
    }
    
    // MARK: - Actions
    
    private func showProfile() {
        let vc = UIViewController()
        vc.title = "Profile"
        vc.view.backgroundColor = .systemBackground
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showUpgrade() {
        let vc = UIViewController()
        vc.title = "Upgrade to Premium"
        vc.view.backgroundColor = .systemBackground
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showNotifications() {
        let vc = UIViewController()
        vc.title = "Notifications"
        vc.view.backgroundColor = .systemBackground
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showPrivacy() {
        let vc = UIViewController()
        vc.title = "Privacy & Security"
        vc.view.backgroundColor = .systemBackground
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showAppearance() {
        let vc = UIViewController()
        vc.title = "Appearance"
        vc.view.backgroundColor = .systemBackground
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showHelp() {
        let vc = UIViewController()
        vc.title = "Help & Support"
        vc.view.backgroundColor = .systemBackground
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func rateApp() {
        let alert = UIAlertController(
            title: "Rate Rentable",
            message: "Enjoying the app? Please rate us on the App Store!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Rate Now", style: .default) { _ in
            // Open App Store rating
            print("Opening App Store...")
        })
        alert.addAction(UIAlertAction(title: "Maybe Later", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showAbout() {
        let vc = UIViewController()
        vc.title = "About"
        vc.view.backgroundColor = .systemBackground
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MoreViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuSections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let menuItem = menuSections[indexPath.section][indexPath.row]
        
        // Configure cell
        var config = cell.defaultContentConfiguration()
        config.image = UIImage(systemName: menuItem.icon)
        config.imageProperties.tintColor = .systemBlue
        config.text = menuItem.title
        config.secondaryText = menuItem.subtitle
        config.textProperties.font = .systemFont(ofSize: 16, weight: .regular)
        config.secondaryTextProperties.font = .systemFont(ofSize: 13, weight: .regular)
        config.secondaryTextProperties.color = .secondaryLabel
        
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MoreViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let menuItem = menuSections[indexPath.section][indexPath.row]
        menuItem.action()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Account"
        case 1: return "Preferences"
        case 2: return "Support"
        default: return nil
        }
    }
}


