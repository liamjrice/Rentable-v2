//
//  PhotoStepView.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import SwiftUI
import PhotosUI

struct PhotoStepView: View {
    
    // MARK: - Properties
    
    @Binding var signupData: SignupData
    let onContinue: () -> Void
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var isLoading = false
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a profile photo")
                        .font(.title.bold())
                    
                    Text("Help others recognize you. You can always change this later.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 32)
                
                // Photo Display
                VStack(spacing: 20) {
                    ZStack {
                        if let image = signupData.profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 160)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 3)
                                )
                                .accessibilityLabel("Profile photo preview")
                        } else {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 160, height: 160)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        if isLoading {
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 160, height: 160)
                            
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        }
                    }
                    
                    // Photo Picker Button
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images
                    ) {
                        Label(
                            signupData.profileImage == nil ? "Choose Photo" : "Change Photo",
                            systemImage: "camera.fill"
                        )
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .cornerRadius(12)
                    .disabled(isLoading)
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            await loadImage(from: newItem)
                        }
                    }
                    .accessibilityLabel("Choose profile photo")
                    .accessibilityHint("Opens photo picker to select your profile picture")
                }
                
                // Tips
                VStack(alignment: .leading, spacing: 12) {
                    Text("Photo tips:")
                        .font(.subheadline.bold())
                    
                    tipRow(icon: "checkmark.circle.fill", text: "Use a clear, recent photo of yourself", color: .green)
                    tipRow(icon: "checkmark.circle.fill", text: "Face should be clearly visible", color: .green)
                    tipRow(icon: "checkmark.circle.fill", text: "Good lighting helps", color: .green)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("Profile Photo")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                VStack(spacing: 12) {
                    Button(action: {
                        onContinue()
                    }) {
                        Text(signupData.profileImage == nil ? "Skip for Now" : "Complete Signup")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .cornerRadius(12)
                    .disabled(isLoading)
                    .accessibilityLabel(signupData.profileImage == nil ? "Skip adding photo" : "Complete signup with photo")
                    .accessibilityHint("Finalizes your account creation")
                    
                    if signupData.profileImage == nil {
                        Text("You can add a photo later in settings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func tipRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        isLoading = true
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                // Compress and resize image
                let compressedImage = compressImage(image)
                await MainActor.run {
                    signupData.profileImage = compressedImage
                }
            }
        } catch {
            print("Error loading image: \(error)")
        }
        
        isLoading = false
    }
    
    private func compressImage(_ image: UIImage) -> UIImage {
        // Resize to max 1000x1000
        let maxSize: CGFloat = 1000
        var newSize = image.size
        
        if image.size.width > maxSize || image.size.height > maxSize {
            let ratio = image.size.width / image.size.height
            
            if ratio > 1 {
                newSize = CGSize(width: maxSize, height: maxSize / ratio)
            } else {
                newSize = CGSize(width: maxSize * ratio, height: maxSize)
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PhotoStepView(
            signupData: .constant(SignupData()),
            onContinue: { print("Continue") }
        )
    }
}

