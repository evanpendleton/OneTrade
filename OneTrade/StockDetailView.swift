import SwiftUI
import Foundation

// MARK: - Existing API Services (Polygon, Twelve Data, Gemini)
// Make sure you have these implemented somewhere in your project.
 
// Example: TwelveDataAPI, GeminiService, PolygonAPI are assumed to exist as per your previous code.

struct TrendView: View {
    let title: String
    let value: Double?
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
            if let value = value {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(value, specifier: "%.1f")")
                        .font(.headline)
                        .foregroundColor(value >= 0 ? .green : .red)
                    Text("%")
                        .font(.caption2)
                        .baselineOffset(1)
                        .foregroundColor(value >= 0 ? .green : .red)
                }
            } else {
                Text("N/A")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color(.systemGray4))
        .cornerRadius(10)
    }
}

struct StockDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let stock: Stock
    let onDismiss: () -> Void
    
    // Company info and API responses
    @State private var companyInfo: CompanyInfo? = nil
    @State private var infoError: String? = nil
    @State private var isLoading: Bool = false
    @State private var geminiResponse: String? = nil
    
    // Price and trend data
    @State private var currentPrice: Double?
    @State private var dailyTrend: Double?
    @State private var weeklyTrend: Double?
    @State private var monthlyTrend: Double?
    @State private var threeMonthlyTrend: Double?
    
    // New state for news sentiment analysis
    @State private var newsSentiment: String? = nil
    @State private var newsError: String? = nil

    private var headerTitle: String {
        companyInfo?.name ?? stock.name
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Header: Stock name and current price
                        HStack {
                            Text(headerTitle)
                                .font(.title)
                            Spacer()
                            if let price = currentPrice {
                                Text("$\(price, specifier: "%.2f")")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top, 50)
                        
                        // Trend views (daily, weekly, monthly, 3-month)
                        HStack(spacing: 10) {
                            TrendView(title: "Daily", value: dailyTrend)
                            TrendView(title: "Weekly", value: weeklyTrend)
                            TrendView(title: "Monthly", value: monthlyTrend)
                            TrendView(title: "3-Month", value: threeMonthlyTrend)
                        }
                        
                        // Company Info
                        if let info = companyInfo {
                            Text("Symbol: \(info.ticker)")
                            Text("Exchange: \(info.primary_exchange)")
                            Text("Description: \(info.description)")
                                .padding(.vertical, 5)
                            Text("Industry: \(info.sic_description)")
                            Text("Sector: \(info.sic_code)")
                            Text("Address: \(info.address?.address1 ?? "N/A"), \(info.address?.city ?? "N/A"), \(info.address?.state ?? "N/A") \(info.address?.postal_code ?? "N/A")")
                            Text("Website: \(info.homepage_url)")
                            if let marketCap = info.market_cap {
                                Text("Market Cap: $\(marketCap, specifier: "%.2f")")
                            }
                            if let employees = info.total_employees {
                                Text("Employees: \(employees)")
                            }
                        } else if isLoading {
                            ProgressView("Loading…")
                        } else if let geminiText = geminiResponse {
                            Text(geminiText)
                                .multilineTextAlignment(.leading)
                        } else if let error = infoError {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                        }
                        
                        // News Sentiment Section
                        if let sentiment = newsSentiment {
                            Divider()
                            Text("News Sentiment")
                                .font(.headline)
                            Text(sentiment)
                                .foregroundColor(.purple)
                        } else if let newsErr = newsError {
                            Text("News Error: \(newsErr)")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                }
                
                // Dismiss Button
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.gray.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(10)
            }
            .navigationBarHidden(true)
            .onAppear {
                isLoading = true
                Task {
                    await loadStockData()
                    await loadTrendData()
                    await loadCurrentPrice()
                    await loadNewsSentiment()
                }
            }
        }
    }
    
    // MARK: - API Loading Functions
    
    private func loadStockData() async {
        // Try Polygon API first
        let polygonResult = await PolygonAPI.shared.getCompanyInfo(for: stock.symbol)
        switch polygonResult {
        case .success(let info):
            if !info.description.isEmpty {
                DispatchQueue.main.async {
                    self.companyInfo = info
                    self.isLoading = false
                }
                return
            }
            print("Polygon missing description, trying Twelve Data...")
        case .failure:
            print("Polygon API failed, trying Twelve Data...")
        }
        
        // Try Twelve Data
        let twelveResult = await TwelveDataAPI.shared.getCompanyInfo(for: stock.symbol)
        switch twelveResult {
        case .success(let info):
            if !info.description.isEmpty {
                DispatchQueue.main.async {
                    self.companyInfo = info
                    self.isLoading = false
                }
            } else {
                print("Twelve Data missing description, calling Gemini...")
                let geminiResult = await GeminiService.shared.generateStockContent(stock: stock.symbol)
                switch geminiResult {
                case .success(let geminiText):
                    let updatedInfo = CompanyInfo(
                        ticker: info.ticker,
                        name: info.name,
                        market: info.market,
                        locale: info.locale,
                        primary_exchange: info.primary_exchange,
                        type: info.type,
                        active: info.active,
                        currency_name: info.currency_name,
                        cik: info.cik,
                        composite_figi: info.composite_figi,
                        share_class_figi: info.share_class_figi,
                        market_cap: info.market_cap,
                        phone_number: info.phone_number,
                        address: info.address,
                        description: geminiText,
                        sic_code: info.sic_code,
                        sic_description: info.sic_description,
                        ticker_root: info.ticker_root,
                        homepage_url: info.homepage_url,
                        total_employees: info.total_employees,
                        list_date: info.list_date,
                        branding: info.branding,
                        share_class_shares_outstanding: info.share_class_shares_outstanding,
                        weighted_shares_outstanding: info.weighted_shares_outstanding,
                        round_lot: info.round_lot
                    )
                    DispatchQueue.main.async {
                        self.companyInfo = updatedInfo
                        self.isLoading = false
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.infoError = "Gemini API Error: \(error)"
                        self.isLoading = false
                    }
                }
            }
        case .failure:
            print("Twelve Data API failed, calling Gemini as fallback...")
            let geminiResult = await GeminiService.shared.generateStockContent(stock: stock.symbol)
            switch geminiResult {
            case .success(let geminiText):
                DispatchQueue.main.async {
                    self.geminiResponse = geminiText
                    self.isLoading = false
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.infoError = "Gemini API Error: \(error)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func loadTrendData() async {
        let timeSeriesResult = await TwelveDataAPI.shared.getDailyTimeSeries(for: stock.symbol)
        switch timeSeriesResult {
        case .success(let response):
            let timeSeries = response.values
            let sortedValues = timeSeries.sorted { $0.datetime > $1.datetime }
            guard sortedValues.count > 1 else { return }
            
            func computeTrend(offset: Int) -> Double? {
                guard sortedValues.count > offset,
                      let latestClose = Double(sortedValues[0].close),
                      let previousClose = Double(sortedValues[offset].close) else {
                    return nil
                }
                return ((latestClose - previousClose) / previousClose) * 100
            }
            
            let computedDailyTrend = computeTrend(offset: 1)
            let computedWeeklyTrend = computeTrend(offset: 5)
            let computedMonthlyTrend = computeTrend(offset: 21)
            let computedThreeMonthlyTrend = computeTrend(offset: 63)
            
            DispatchQueue.main.async {
                self.dailyTrend = computedDailyTrend
                self.weeklyTrend = computedWeeklyTrend
                self.monthlyTrend = computedMonthlyTrend
                self.threeMonthlyTrend = computedThreeMonthlyTrend
            }
        case .failure(let error):
            print("Failed to load time series: \(error)")
        }
    }
    
    private func loadCurrentPrice() async {
        let priceResult = await TwelveDataAPI.shared.getCurrentPrice(for: stock.symbol)
        switch priceResult {
        case .success(let price):
            DispatchQueue.main.async {
                self.currentPrice = price
            }
        case .failure(let error):
            print("Failed to load current price: \(error)")
        }
    }
    
    // MARK: - News Sentiment Analysis via Finnhub & Gemini
    
    private func loadNewsSentiment() async {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = Date()
        guard let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: today) else { return }
        let toDate = dateFormatter.string(from: today)
        let fromDate = dateFormatter.string(from: threeMonthsAgo)
        
        // Fetch news articles from Finnhub
        let newsResult = await FinnhubNewsService.shared.getCompanyNews(for: stock.symbol, from: fromDate, to: toDate)
        switch newsResult {
        case .success(let articles):
            let sortedArticles = articles.sorted { $0.datetime > $1.datetime }
            let maxArticles = 25
            let articlesToSend = sortedArticles.prefix(maxArticles)
            
            // Build Gemini prompt using titles and summaries
            var articlesText = ""
            for (index, article) in articlesToSend.enumerated() {
                articlesText += "\(index + 1). Title: \(article.headline)\n"
                let summaryText = (article.summary?.isEmpty == false) ? article.summary! : "No Summary Available."
                articlesText += "   Summary: \(summaryText)\n\n"
            }
            
            let geminiPrompt = """
            Would you buy, wait, or sell \(stock.symbol) stock right now. Respond with a single word: "buy", "wait", or "sell", followed by a brief explanation of your reasoning. Do not include any direct quotes.

            Use the following recent news articles to support your decision:
            \(articlesText)
            """
            
            // Call Gemini API to analyze sentiment
            let geminiResult = await GeminiService.shared.generateContent(prompt: geminiPrompt)
            switch geminiResult {
            case .success(let responseText):
                DispatchQueue.main.async {
                    self.newsSentiment = responseText
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.newsError = "Gemini API Error: \(error.localizedDescription)"
                }
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.newsError = "Finnhub Error: \(error.localizedDescription)"
            }
        }
    }
}
