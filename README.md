# OneTrade

<p align="center">
  <img src="Images/HomePage.PNG" alt="Home Page" width="300">
</p>

<p align="center">
  <img src="Images/ExamplePage1.PNG" alt="Example of AAPL stock - Page 1" width="300">
</p>

<p align="center">
  <img src="Images/ExamplePage2.PNG" alt="Example of AAPL stock - Page 2" width="300">
</p>

## Summary:
OneTrade is an iOS app developed with the idea of being an all-in-one solution for buying stocks without any fluff. Analyzing current market trends and common consensus on a given company, OneTrade provides the information needed to make an informed decision when buying stocks.

## Language:
- Swift

## APIs:
- [Google Gemini](https://aistudio.google.com/apikey) - Used for AI summaries of news articles and fallback for company descriptions
- [Polygon](https://polygon.io/) - Used to get company descriptions
- [twelvedata](https://twelvedata.com/) - Used to obtain current stock values
- [FinnHub](https://finnhub.io/) - Used to get current news articles

## Usage  

1. **Download the Repository**  
   - Clone or download the GitHub repo.  

2. **Configure Secrets**  
   - Navigate to the `OneTrade` folder.  
   - Rename `ExampleSecrets.xcconfig` to `Secrets.xcconfig`.  
   - Replace the placeholder API keys with your own.  

3. **Set Up Xcode**  
   - Open Xcode and select the blue **OneTrade** icon at the top.  
   - Under **TARGETS**, go to **Signing & Capabilities**.  
   - Set your **Team** to your Apple Developer account.  
   - Update the **Bundle Identifier** if needed.  

4. **Build on Device**  
   - Connect your iOS device.  
   - Click **Build** to run the app.  


## Credits:
- NASDAQ and NYSE Symbols - https://github.com/rreichel3/US-Stock-Symbols/blob/main/
- Code Help - ChatGPT and Google Gemini