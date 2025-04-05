import SwiftUI

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
        .padding(.horizontal, 12)
        .background(Color(.systemGray4))
        .cornerRadius(10)
    }
}


struct StockDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let stock: Stock
    let onDismiss: () -> Void
    @State private var companyInfo: CompanyInfo? = nil
    @State private var infoError: String? = nil
    @State private var isLoading: Bool = false
    @State private var geminiResponse: String? = nil
    
    // New state properties for trends
    @State private var dailyTrend: Double?
    @State private var weeklyTrend: Double?
    @State private var monthlyTrend: Double?
    @State private var threeMonthlyTrend: Double?
    
    private var headerTitle: String {
        if let name = companyInfo?.name {
            return name
        } else {
            return stock.name
        }
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(headerTitle)
                            .font(.title)
                            .padding(.bottom, 5)
                            .padding(.top, 50)
                        
                        // Trends displayed at the top in a horizontal row
                        HStack(spacing: 10) {
                            TrendView(title: "Daily", value: dailyTrend)
                            TrendView(title: "Weekly", value: weeklyTrend)
                            TrendView(title: "Monthly", value: monthlyTrend)
                            TrendView(title: "3-Month", value: threeMonthlyTrend)
                        }
                        .padding(.top, 10)
                        
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                        } else if let gemini = geminiResponse {
                            Text(gemini)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                                .multilineTextAlignment(.leading)
                        } else if let error = infoError {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding()
                }
                
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
                }
            }
        }
    }
    
    // Existing company info loading function
    private func loadStockData() async {
        // 1) First try Polygon
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
            print("Polygon missing description, trying Alphavantage...")
        case .failure:
            print("Polygon API failed, trying Alphavantage...")
        }
        
        // 2) Try Alphavantage
        let alphaResult = await AlphavantageAPI.shared.getCompanyInfo(for: stock.symbol)
        switch alphaResult {
        case .success(let alphaInfo):
            if !alphaInfo.description.isEmpty {
                DispatchQueue.main.async {
                    self.companyInfo = alphaInfo
                    self.isLoading = false
                }
            } else {
                print("Alphavantage missing description, calling Gemini...")
                let geminiResult = await GeminiService.shared.generateStockContent(stock: stock.symbol)
                switch geminiResult {
                case .success(let geminiText):
                    let updatedInfo = CompanyInfo(
                        ticker: alphaInfo.ticker,
                        name: alphaInfo.name,
                        market: alphaInfo.market,
                        locale: alphaInfo.locale,
                        primary_exchange: alphaInfo.primary_exchange,
                        type: alphaInfo.type,
                        active: alphaInfo.active,
                        currency_name: alphaInfo.currency_name,
                        cik: alphaInfo.cik,
                        composite_figi: alphaInfo.composite_figi,
                        share_class_figi: alphaInfo.share_class_figi,
                        market_cap: alphaInfo.market_cap,
                        phone_number: alphaInfo.phone_number,
                        address: alphaInfo.address,
                        description: geminiText,
                        sic_code: alphaInfo.sic_code,
                        sic_description: alphaInfo.sic_description,
                        ticker_root: alphaInfo.ticker_root,
                        homepage_url: alphaInfo.homepage_url,
                        total_employees: alphaInfo.total_employees,
                        list_date: alphaInfo.list_date,
                        branding: alphaInfo.branding,
                        share_class_shares_outstanding: alphaInfo.share_class_shares_outstanding,
                        weighted_shares_outstanding: alphaInfo.weighted_shares_outstanding,
                        round_lot: alphaInfo.round_lot
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
            print("Alphavantage API failed, calling Gemini as fallback...")
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
    
    // New function to load trend data using Alphavantage’s daily time series
    private func loadTrendData() async {
        let timeSeriesResult = await AlphavantageAPI.shared.getDailyTimeSeries(for: stock.symbol)
        switch timeSeriesResult {
        case .success(let response):
            // Compute trends using sorted dates (latest first)
            let timeSeries = response.timeSeries
            let sortedDates = timeSeries.keys.sorted(by: >)
            guard sortedDates.count > 1 else { return }
            // Helper to compute percentage change
            func computeTrend(offset: Int) -> Double? {
                guard sortedDates.count > offset,
                      let latestClose = Double(timeSeries[sortedDates[0]]?.close ?? ""),
                      let previousClose = Double(timeSeries[sortedDates[offset]]?.close ?? "") else {
                    return nil
                }
                return ((latestClose - previousClose) / previousClose) * 100
            }
            // Daily (previous day), Weekly (approx. 5 trading days), Monthly (approx. 21 days), 3-Month (approx. 63 days)
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
}
