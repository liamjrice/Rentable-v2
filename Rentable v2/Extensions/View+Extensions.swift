//
//  View+Extensions.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import SwiftUI

//// MARK: - Shake Animation
//
//struct ShakeEffect: GeometryEffect {
//    var amount: CGFloat = 10
//    var shakesPerUnit = 3
//    var animatableData: CGFloat
//    
//    func effectValue(size: CGSize) -> ProjectionTransform {
//        ProjectionTransform(CGAffineTransform(
//            translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
//            y: 0
//        ))
//    }
//}
//
//extension View {
//    /// Adds a shake animation to the view
//    /// - Parameter animateTrigger: Value that triggers the shake (increment to trigger)
//    func shake(animateTrigger: Int) -> some View {
//        modifier(ShakeEffect(animatableData: CGFloat(animateTrigger)))
//    }
//}

// MARK: - Button Press Animation

extension View {
    /// Adds a press animation to the view
    func pressAnimation() -> some View {
        self.buttonStyle(PressAnimationStyle())
    }
}

struct PressAnimationStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Card Style

extension View {
    /// Applies a card-like appearance to the view
    func cardStyle(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Loading Overlay

extension View {
    /// Adds a loading overlay to the view
    /// - Parameters:
    ///   - isLoading: Binding that controls visibility
    ///   - message: Loading message to display
    func loadingOverlay(isLoading: Bool, message: String = "Loading...") -> some View {
        self.overlay {
            if isLoading {
                LoadingView(message: message, style: .overlay)
            }
        }
    }
}

// MARK: - Error Alert

extension View {
    /// Adds an error alert to the view
    /// - Parameters:
    ///   - error: Optional error to display
    ///   - onDismiss: Action to perform when dismissed
    func errorAlert(error: Binding<Error?>, onDismiss: (() -> Void)? = nil) -> some View {
        self.alert("Error", isPresented: Binding(
            get: { error.wrappedValue != nil },
            set: { if !$0 { error.wrappedValue = nil } }
        )) {
            Button("OK") {
                error.wrappedValue = nil
                onDismiss?()
            }
        } message: {
            if let error = error.wrappedValue {
                Text(error.localizedDescription)
            }
        }
    }
}

// MARK: - Validation Border

extension View {
    /// Adds a validation border to the view
    /// - Parameters:
    ///   - isValid: Whether the input is valid
    ///   - hasInteracted: Whether the user has interacted with the field
    func validationBorder(isValid: Bool, hasInteracted: Bool) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor(isValid: isValid, hasInteracted: hasInteracted), lineWidth: 1.5)
        )
    }
    
    private func borderColor(isValid: Bool, hasInteracted: Bool) -> Color {
        if !hasInteracted {
            return .clear
        }
        return isValid ? .green : .red
    }
}

// MARK: - Haptic Feedback

enum HapticFeedback {
    case success
    case error
    case warning
    case selection
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    
    func trigger() {
        switch self {
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .impact(let style):
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
}

extension View {
    /// Triggers haptic feedback
    /// - Parameter feedback: Type of haptic feedback
    func hapticFeedback(_ feedback: HapticFeedback) -> some View {
        self.onAppear {
            feedback.trigger()
        }
    }
}

// MARK: - Keyboard Toolbar

struct KeyboardToolbar: ToolbarContent {
    @FocusState.Binding var focusedField: AnyHashable?
    let fields: [AnyHashable]
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Button("Previous") {
                moveToPrevious()
            }
            .disabled(!canMovePrevious)
            
            Spacer()
            
            Button("Next") {
                moveToNext()
            }
            .disabled(!canMoveNext)
        }
    }
    
    private var canMovePrevious: Bool {
        guard let current = focusedField,
              let index = fields.firstIndex(of: current) else {
            return false
        }
        return index > 0
    }
    
    private var canMoveNext: Bool {
        guard let current = focusedField,
              let index = fields.firstIndex(of: current) else {
            return false
        }
        return index < fields.count - 1
    }
    
    private func moveToPrevious() {
        guard let current = focusedField,
              let index = fields.firstIndex(of: current),
              index > 0 else {
            return
        }
        focusedField = fields[index - 1]
    }
    
    private func moveToNext() {
        guard let current = focusedField,
              let index = fields.firstIndex(of: current),
              index < fields.count - 1 else {
            return
        }
        focusedField = fields[index + 1]
    }
}

// MARK: - Conditional Modifier

extension View {
    /// Conditionally applies a modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

