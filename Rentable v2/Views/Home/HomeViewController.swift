//
//  HomeViewController.swift
//  Rentable v2
//
//  Created by Liam Rice on 17/10/2025.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private var inputContainerBottomConstraint: NSLayoutConstraint?
    private var originalBottomConstraintConstant: CGFloat = 0
    private var keyboardConstraint: NSLayoutConstraint?
    
    // AI Service
    private let aiService = AIService()
    private var messages: [ChatMessage] = []
    private var isLoading = false
    
    // MARK: - UI Components
    
    private let headerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private let profileButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 24
        button.clipsToBounds = true
        
        // Set placeholder profile image
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "person.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        button.backgroundColor = .systemGray5
        
        return button
    }()
    
    private let notificationDot: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var upgradeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Upgrade", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        
        // Apply gradient and styling from Figma
        button.layer.cornerRadius = 24
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3).cgColor
        button.clipsToBounds = true
        
        return button
    }()
    
    private let inputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 32
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let microphoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "mic.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .secondaryLabel
        return button
    }()
    
    private let inputTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Get started ...",
            attributes: [
                .foregroundColor: UIColor.secondaryLabel,
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        )
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .default
        textField.returnKeyType = .send
        textField.enablesReturnKeyAutomatically = true
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 12
        
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        let image = UIImage(systemName: "arrow.up", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        
        return button
    }()
    
    private let chatTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        return tableView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupChatTableView()
        setupKeyboardObservers()
        setupActions()
        
        // Hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUpgradeButtonGradient()
    }
    
    private func setupUpgradeButtonGradient() {
        // Skip if button has no size yet
        guard upgradeButton.bounds.size.width > 0 else { return }
        
        // Remove existing gradient layers to avoid duplicates
        upgradeButton.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        // Create gradient layer with simplified approach
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.298, green: 0.585, blue: 0.982, alpha: 1).cgColor,
            UIColor(red: 0.024, green: 0.4, blue: 0.922, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = upgradeButton.bounds
        gradientLayer.cornerRadius = 24
        
        upgradeButton.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Use system background color that adapts to light/dark mode
        view.backgroundColor = .systemBackground
        
        // Add chat table view
        view.addSubview(chatTableView)
        
        // Add input container
        view.addSubview(inputContainer)
        inputContainer.addSubview(microphoneButton)
        inputContainer.addSubview(inputTextField)
        inputContainer.addSubview(sendButton)
        inputContainer.addSubview(loadingIndicator)
        
        // Add header - these should be on top
        view.addSubview(headerContainer)
        headerContainer.addSubview(profileButton)
        headerContainer.addSubview(notificationDot)
        headerContainer.addSubview(upgradeButton)
        
        // Ensure input container is visible
        view.bringSubviewToFront(inputContainer)
        
        NSLayoutConstraint.activate([
            
            // Chat table view
            chatTableView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 16),
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor, constant: -16),
            
            // Header container
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerContainer.heightAnchor.constraint(equalToConstant: 48),
            
            // Profile button
            profileButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            profileButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 48),
            profileButton.heightAnchor.constraint(equalToConstant: 48),
            
            // Notification dot
            notificationDot.topAnchor.constraint(equalTo: profileButton.topAnchor, constant: 2),
            notificationDot.trailingAnchor.constraint(equalTo: profileButton.trailingAnchor, constant: -2),
            notificationDot.widthAnchor.constraint(equalToConstant: 10),
            notificationDot.heightAnchor.constraint(equalToConstant: 10),
            
            // Upgrade button
            upgradeButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            upgradeButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            upgradeButton.widthAnchor.constraint(equalToConstant: 98),
            upgradeButton.heightAnchor.constraint(equalToConstant: 48),
            
            // Input container
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputContainer.heightAnchor.constraint(equalToConstant: 56),
            
            // Microphone button
            microphoneButton.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 14),
            microphoneButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            microphoneButton.widthAnchor.constraint(equalToConstant: 24),
            microphoneButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Send button
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -14),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 24),
            sendButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Input text field
            inputTextField.leadingAnchor.constraint(equalTo: microphoneButton.trailingAnchor, constant: 8),
            inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            inputTextField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            
            // Loading indicator
            loadingIndicator.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -14),
            loadingIndicator.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
        ])
        
        if #available(iOS 15.0, *) {
            // Use the system keyboard layout guide for perfect syncing
            keyboardConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
            keyboardConstraint?.isActive = true
        }
        
        // Store bottom constraint reference for keyboard animation (fallback for < iOS 15)
        if #available(iOS 15.0, *) {
            // Not needed when using keyboardLayoutGuide
            inputContainerBottomConstraint = nil
            originalBottomConstraintConstant = 0
        } else {
            let safeAreaBottom = view.safeAreaInsets.bottom
            let bottomConstant = -(safeAreaBottom + 16)
            inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomConstant)
            inputContainerBottomConstraint?.isActive = true
            originalBottomConstraintConstant = bottomConstant
        }
    }
    
    private func setupChatTableView() {
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        
        // Rotate table view upside down for chat-like behavior (newest at bottom)
        chatTableView.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        inputTextField.delegate = self
    }
    
    // MARK: - Actions
    @objc private func sendButtonTapped() {
        guard let text = inputTextField.text, !text.isEmpty, !isLoading else { return }
        sendMessage(text)
    }
    
    private func sendMessage(_ text: String) {
        // Add user message
        let userMessage = ChatMessage(text: text, isFromUser: true)
        messages.insert(userMessage, at: 0)
        
        // Update UI
        inputTextField.text = ""
        isLoading = true
        updateSendButtonState()
        
        // Insert user message cell
        chatTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        // Send to AI
        aiService.sendMessage(userMessage: text) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isLoading = false
                self.updateSendButtonState()
                
                switch result {
                case .success(let response):
                    // Add AI response
                    let aiMessage = ChatMessage(text: response, isFromUser: false)
                    self.messages.insert(aiMessage, at: 0)
                    self.chatTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    
                case .failure(let error):
                    // Show error
                    self.showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateSendButtonState() {
        if isLoading {
            sendButton.isHidden = true
            loadingIndicator.startAnimating()
        } else {
            sendButton.isHidden = false
            loadingIndicator.stopAnimating()
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if #available(iOS 15.0, *) {
            return
        }
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        // Convert keyboard frame to view's coordinate system
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let keyboardTop = keyboardFrameInView.origin.y
        
        // Calculate how much to move up: from bottom of screen to top of keyboard
        let viewBottom = view.bounds.height
        let keyboardHeight = viewBottom - keyboardTop
        
        // Move input container to sit just above the keyboard with padding
        inputContainerBottomConstraint?.constant = -keyboardHeight - 16
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve << 16),
            animations: { self.view.layoutIfNeeded() }
        )
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if #available(iOS 15.0, *) {
            return
        }
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        // Return input container to original position (stored during setup)
        inputContainerBottomConstraint?.constant = originalBottomConstraintConstant
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve << 16),
            animations: { self.view.layoutIfNeeded() }
        )
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as? ChatMessageCell else {
            return UITableViewCell()
        }
        
        let message = messages[indexPath.row]
        cell.configure(with: message)
        
        // Rotate cell back to normal (since table view is upside down)
        cell.transform = CGAffineTransform(rotationAngle: .pi)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITextFieldDelegate
extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped()
        return true
    }
}

