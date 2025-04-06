import Foundation

// --- Re-iterate the Helper (Keep this accessible in your project) ---
enum Secrets {
    static var geminiApiKey: String {
        // Retrieve the key from Info.plist
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GeminiApiKey") as? String else {
            // Make sure "ApiKey" exactly matches the key name you added in your target's Info tab
            fatalError("""
                ERROR: ApiKey not found in Info.plist.
                Possible Issues:
                1. Check spelling: Is the key in Info.plist *exactly* 'ApiKey'?
                2. Check value: Is the value for 'ApiKey' in Info.plist set to '$(API_KEY)'?
                3. Check xcconfig linking: Is Secrets.xcconfig correctly linked to your build configuration (Project > Info > Configurations)?
                4. Check xcconfig content: Does Secrets.xcconfig contain 'API_KEY = your_actual_key'?
                5. Check Build: Try cleaning the build folder (Cmd+Shift+K) and rebuilding.
                """)
        }

        // Optional but recommended: Check if it's still the placeholder
        if key == "PASTE_YOUR_API_KEY_HERE" || key.isEmpty {
             fatalError("""
                ERROR: API_KEY in Secrets.xcconfig appears to be empty or still the placeholder value.
                Please ensure you have replaced 'PASTE_YOUR_API_KEY_HERE' with your actual key in the Secrets.xcconfig file.
                Remember: Secrets.xcconfig should NOT be committed to Git.
                """)
        }
        return key
    }
    
    static var polygonApiKey: String {
        // Retrieve the key from Info.plist
        guard let key = Bundle.main.object(forInfoDictionaryKey: "PolygonApiKey") as? String else {
            // Make sure "ApiKey" exactly matches the key name you added in your target's Info tab
            fatalError("""
                ERROR: ApiKey not found in Info.plist.
                Possible Issues:
                1. Check spelling: Is the key in Info.plist *exactly* 'ApiKey'?
                2. Check value: Is the value for 'ApiKey' in Info.plist set to '$(API_KEY)'?
                3. Check xcconfig linking: Is Secrets.xcconfig correctly linked to your build configuration (Project > Info > Configurations)?
                4. Check xcconfig content: Does Secrets.xcconfig contain 'API_KEY = your_actual_key'?
                5. Check Build: Try cleaning the build folder (Cmd+Shift+K) and rebuilding.
                """)
        }

        // Optional but recommended: Check if it's still the placeholder
        if key == "PASTE_YOUR_API_KEY_HERE" || key.isEmpty {
             fatalError("""
                ERROR: API_KEY in Secrets.xcconfig appears to be empty or still the placeholder value.
                Please ensure you have replaced 'PASTE_YOUR_API_KEY_HERE' with your actual key in the Secrets.xcconfig file.
                Remember: Secrets.xcconfig should NOT be committed to Git.
                """)
        }
        return key
    }
    
    static var alphaVantageApiKey: String {
        // Retrieve the key from Info.plist
        guard let key = Bundle.main.object(forInfoDictionaryKey: "AlphaVantageApiKey") as? String else {
            // Make sure "ApiKey" exactly matches the key name you added in your target's Info tab
            fatalError("""
                ERROR: ApiKey not found in Info.plist.
                Possible Issues:
                1. Check spelling: Is the key in Info.plist *exactly* 'ApiKey'?
                2. Check value: Is the value for 'ApiKey' in Info.plist set to '$(API_KEY)'?
                3. Check xcconfig linking: Is Secrets.xcconfig correctly linked to your build configuration (Project > Info > Configurations)?
                4. Check xcconfig content: Does Secrets.xcconfig contain 'API_KEY = your_actual_key'?
                5. Check Build: Try cleaning the build folder (Cmd+Shift+K) and rebuilding.
                """)
        }

        // Optional but recommended: Check if it's still the placeholder
        if key == "PASTE_YOUR_API_KEY_HERE" || key.isEmpty {
             fatalError("""
                ERROR: API_KEY in Secrets.xcconfig appears to be empty or still the placeholder value.
                Please ensure you have replaced 'PASTE_YOUR_API_KEY_HERE' with your actual key in the Secrets.xcconfig file.
                Remember: Secrets.xcconfig should NOT be committed to Git.
                """)
        }
        return key
    }
    
    static var twelveDataApiKey: String {
        // Retrieve the key from Info.plist
        guard let key = Bundle.main.object(forInfoDictionaryKey: "TwelveDataApiKey") as? String else {
            // Make sure "ApiKey" exactly matches the key name you added in your target's Info tab
            fatalError("""
                ERROR: ApiKey not found in Info.plist.
                Possible Issues:
                1. Check spelling: Is the key in Info.plist *exactly* 'ApiKey'?
                2. Check value: Is the value for 'ApiKey' in Info.plist set to '$(API_KEY)'?
                3. Check xcconfig linking: Is Secrets.xcconfig correctly linked to your build configuration (Project > Info > Configurations)?
                4. Check xcconfig content: Does Secrets.xcconfig contain 'API_KEY = your_actual_key'?
                5. Check Build: Try cleaning the build folder (Cmd+Shift+K) and rebuilding.
                """)
        }

        // Optional but recommended: Check if it's still the placeholder
        if key == "PASTE_YOUR_API_KEY_HERE" || key.isEmpty {
             fatalError("""
                ERROR: API_KEY in Secrets.xcconfig appears to be empty or still the placeholder value.
                Please ensure you have replaced 'PASTE_YOUR_API_KEY_HERE' with your actual key in the Secrets.xcconfig file.
                Remember: Secrets.xcconfig should NOT be committed to Git.
                """)
        }
        return key
    }
    
    static var finnHubApiKey: String {
        // Retrieve the key from Info.plist
        guard let key = Bundle.main.object(forInfoDictionaryKey: "FinnHubApiKey") as? String else {
            // Make sure "ApiKey" exactly matches the key name you added in your target's Info tab
            fatalError("""
                ERROR: ApiKey not found in Info.plist.
                Possible Issues:
                1. Check spelling: Is the key in Info.plist *exactly* 'ApiKey'?
                2. Check value: Is the value for 'ApiKey' in Info.plist set to '$(API_KEY)'?
                3. Check xcconfig linking: Is Secrets.xcconfig correctly linked to your build configuration (Project > Info > Configurations)?
                4. Check xcconfig content: Does Secrets.xcconfig contain 'API_KEY = your_actual_key'?
                5. Check Build: Try cleaning the build folder (Cmd+Shift+K) and rebuilding.
                """)
        }

        // Optional but recommended: Check if it's still the placeholder
        if key == "PASTE_YOUR_API_KEY_HERE" || key.isEmpty {
             fatalError("""
                ERROR: API_KEY in Secrets.xcconfig appears to be empty or still the placeholder value.
                Please ensure you have replaced 'PASTE_YOUR_API_KEY_HERE' with your actual key in the Secrets.xcconfig file.
                Remember: Secrets.xcconfig should NOT be committed to Git.
                """)
        }
        return key
    }
}
