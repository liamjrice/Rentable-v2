import Foundation

enum Config {
    
    /// Google Gemini API Key
    static var geminiAPIKey: String {
        // Method 1: Try to get from Info.plist first (if it exists)
        if let key = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
           !key.isEmpty && !key.contains("$") {
            return key
        }
        
        // Method 2: Fallback to reading from Bundle resources
        guard let path = Bundle.main.path(forResource: "Config", ofType: "xcconfig"),
              let content = try? String(contentsOfFile: path),
              let line = content.components(separatedBy: .newlines)
                .first(where: { $0.contains("GEMINI_API_KEY") }),
              let value = line.components(separatedBy: "=").last?.trimmingCharacters(in: .whitespaces) else {
            fatalError("GEMINI_API_KEY not found in Config.xcconfig")
        }
        
        return value
    }
}
