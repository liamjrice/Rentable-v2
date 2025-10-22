//
//  UIImage+Extensions.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import UIKit

extension UIImage {
    
    // MARK: - Compression
    
    /// Compresses image to JPEG with specified quality
    /// - Parameter quality: Compression quality (0.0 - 1.0)
    /// - Returns: Compressed image data
    func jpegData(compressionQuality quality: CGFloat) -> Data? {
        return self.jpegData(compressionQuality: quality)
    }
    
    /// Compresses image to fit within size limit
    /// - Parameter maxSizeInBytes: Maximum size in bytes (default: 1MB)
    /// - Returns: Compressed image data
    func compressedData(maxSizeInBytes: Int = 1_048_576) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = self.jpegData(compressionQuality: compression)
        
        // Progressively reduce quality until size is acceptable
        while let data = imageData, data.count > maxSizeInBytes && compression > 0.1 {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
    
    // MARK: - Resizing
    
    /// Resizes image to fit within max dimensions
    /// - Parameter maxSize: Maximum width/height
    /// - Returns: Resized image
    func resized(toMaxSize maxSize: CGFloat) -> UIImage {
        let size = self.size
        
        // Check if resize is needed
        guard size.width > maxSize || size.height > maxSize else {
            return self
        }
        
        // Calculate new size maintaining aspect ratio
        let ratio = size.width / size.height
        var newSize: CGSize
        
        if ratio > 1 {
            // Landscape
            newSize = CGSize(width: maxSize, height: maxSize / ratio)
        } else {
            // Portrait or square
            newSize = CGSize(width: maxSize * ratio, height: maxSize)
        }
        
        // Render at new size
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        self.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
    /// Resizes image to exact size
    /// - Parameter size: Target size
    /// - Returns: Resized image
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        self.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
    // MARK: - Cropping
    
    /// Crops image to square from center
    /// - Returns: Square cropped image
    func croppedToSquare() -> UIImage {
        let size = self.size
        let sideLength = min(size.width, size.height)
        
        let x = (size.width - sideLength) / 2
        let y = (size.height - sideLength) / 2
        
        let cropRect = CGRect(x: x, y: y, width: sideLength, height: sideLength)
        
        guard let cgImage = self.cgImage?.cropping(to: cropRect) else {
            return self
        }
        
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    // MARK: - Optimization
    
    /// Optimizes image for profile photo (square, compressed, max 1MB)
    /// - Returns: Optimized image data
    func optimizedForProfile() -> Data? {
        // Crop to square
        let squared = self.croppedToSquare()
        
        // Resize to max 1000x1000
        let resized = squared.resized(toMaxSize: 1000)
        
        // Compress to max 1MB
        return resized.compressedData(maxSizeInBytes: 1_048_576)
    }
    
    // MARK: - Info
    
    /// Returns file size of image in bytes
    var sizeInBytes: Int? {
        return self.jpegData(compressionQuality: 1.0)?.count
    }
    
    /// Returns file size of image in MB
    var sizeInMB: Double? {
        guard let bytes = sizeInBytes else { return nil }
        return Double(bytes) / 1_048_576
    }
}

