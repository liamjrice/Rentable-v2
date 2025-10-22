import UIKit

class ChatMessageCell: UITableViewCell {
    
    // MARK: - UI Components
    private let messageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(messageContainer)
        messageContainer.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            messageContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            messageLabel.topAnchor.constraint(equalTo: messageContainer.topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: messageContainer.bottomAnchor, constant: -12),
            messageLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor, constant: -16),
        ])
        
        // Create but don't activate constraints yet
        leadingConstraint = messageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = messageContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
    }
    
    // MARK: - Configuration
    func configure(with message: ChatMessage) {
        messageLabel.text = message.text
        
        // Deactivate all positioning constraints
        leadingConstraint?.isActive = false
        trailingConstraint?.isActive = false
        
        if message.isFromUser {
            // User messages: aligned to the right, blue background
            messageContainer.backgroundColor = UIColor.systemBlue
            messageLabel.textColor = .white
            
            leadingConstraint = messageContainer.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 60)
            trailingConstraint = messageContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            
        } else {
            // AI messages: aligned to the left, gray background
            messageContainer.backgroundColor = UIColor.systemGray5
            messageLabel.textColor = .label
            
            leadingConstraint = messageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
            trailingConstraint = messageContainer.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -60)
        }
        
        // Activate the new constraints
        leadingConstraint?.isActive = true
        trailingConstraint?.isActive = true
    }
}

