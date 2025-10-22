# API Key Configuration Setup - Google Gemini

This guide explains how to securely store and use your Google Gemini API key in this Xcode project.

## Quick Setup

### 1. Get Your Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy your API key

### 2. Add Your API Key

Replace `your-gemini-api-key-here` in `Config.xcconfig` with your actual Gemini API key:

```
GEMINI_API_KEY = your-actual-api-key-here
```

### 3. Configure Xcode Project (Optional - for Info.plist method)

#### Step 1: Add Config.xcconfig to Xcode
1. In Xcode, right-click on the project navigator
2. Select "Add Files to Rentable v2..."
3. Navigate to and select `Config.xcconfig`
4. Make sure "Copy items if needed" is **unchecked**
5. Click "Add"

#### Step 2: Set Configuration File in Project Settings
1. Select the project in the Project Navigator (blue icon at the top)
2. In the left sidebar under "PROJECT", select "Rentable v2"
3. Select the "Info" tab
4. Under "Configurations", expand "Debug" and "Release"
5. For both configurations, set the configuration file:
   - Debug: Select "Config" from the dropdown
   - Release: Select "Config" from the dropdown

### 4. Use the API in Your Code

The API key is now accessible through the `Config` class:

```swift
// Use default initialization (automatically loads from Config)
let aiService = AIService()

aiService.sendMessage(userMessage: "Hello!") { result in
    switch result {
    case .success(let response):
        print("Response: \(response)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

## API Details

### Model Options

The default model is `gemini-1.5-flash` (fast and efficient). You can change it by:

```swift
let aiService = AIService(apiKey: Config.geminiAPIKey, model: "gemini-1.5-pro")
```

Available models:
- `gemini-1.5-flash` - Fast and efficient (default)
- `gemini-1.5-pro` - Most capable, best for complex tasks
- `gemini-1.0-pro` - Previous generation

### API Endpoint

```
https://generativelanguage.googleapis.com/v1beta/models/MODEL_NAME:generateContent?key=API_KEY
```

### Request Format

```json
{
  "contents": [
    {
      "parts": [
        {
          "text": "Your message here"
        }
      ]
    }
  ]
}
```

### Response Format

```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "AI response here"
          }
        ]
      }
    }
  ]
}
```

## Security Notes

✅ **What's Protected:**
- `Config.xcconfig` is listed in `.gitignore` and will not be committed to git
- Your API key stays on your local machine only

⚠️ **Important:**
- Never commit `Config.xcconfig` to version control
- Use `Config.example.xcconfig` as a template for team members
- Each developer should create their own `Config.xcconfig` file

## Comparison: Gemini vs OpenAI

| Feature | Gemini | OpenAI |
|---------|--------|--------|
| **Free Tier** | 15 requests/min | Limited free credits |
| **Cost** | More affordable | More expensive |
| **Speed** | Very fast (Flash) | Fast |
| **Capabilities** | Great for most tasks | Industry leading |
| **Multimodal** | Native support | GPT-4V only |

## Team Setup

When a new developer joins:

1. They should copy `Config.example.xcconfig` to `Config.xcconfig`
2. Add their own Gemini API key to `Config.xcconfig`
3. Follow the Xcode configuration steps above (if using Info.plist)

## Troubleshooting

### "Configuration value for key 'GEMINI_API_KEY' not found"

This means the value isn't being read properly. Check:
1. The `.xcconfig` file exists and has your API key
2. The file is referenced in the Xcode project
3. Clean build folder (Product → Clean Build Folder)
4. Rebuild the project

### API Key Not Working

1. Verify your API key is correct from Google AI Studio
2. Make sure you've enabled the Gemini API
3. Check your API quota/limits
4. Try testing the key directly in Google AI Studio

### Rate Limiting

If you hit rate limits:
- Free tier: 15 requests per minute
- Consider upgrading or adding delays between requests

## File Structure

```
Rentable-v2/
├── Config.xcconfig              # Your actual API key (ignored by git)
├── Config.example.xcconfig      # Template for team members
├── .gitignore                   # Includes Config.xcconfig
└── Rentable v2/
    ├── Config.swift            # Swift helper to access config values
    └── Network/
        └── AIService.swift     # Uses Config to get API key
```

## Resources

- [Google AI Studio](https://makersuite.google.com/)
- [Gemini API Documentation](https://ai.google.dev/docs)
- [API Pricing](https://ai.google.dev/pricing)
- [Rate Limits](https://ai.google.dev/docs/rate_limits)
