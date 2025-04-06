import SwiftUI

struct Stock: Decodable, Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let lastsale: String?
    let netchange: String?
    let pctchange: String?
    let volume: String?
    let marketCap: String?
    let country: String?
    let ipoyear: String?
    let industry: String?
    let sector: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case symbol, name, lastsale, netchange, pctchange, volume, marketCap, country, ipoyear, industry, sector, url
    }
    
    var marketCapValue: Double {
        let cleaned = marketCap?
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "$", with: "")
            ?? "0"
        return Double(cleaned) ?? 0
    }
}

struct ContentView: View {
    @State private var searchText = ""
    @State private var stocks: [Stock] = []
    @State private var filteredStocks: [Stock] = []
    @State private var isSearching = false
    @State private var selectedStock: Stock? = nil

    let primaryJsonFile = "nasdaq_full_tickers"
    let secondaryJsonFile = "nyse_full_tickers"

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(searchText: $searchText, isSearching: $isSearching)
                
                List {
                    ForEach(filteredStocks) { stock in
                        Button {
                            selectedStock = stock
                        } label: {
                            HStack {
                                Text("\(stock.name) (\(stock.symbol))")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .onChange(of: searchText) {
                    filterStocks(searchText: searchText)
                }
            }
            .navigationTitle("OneTrade")
            .onAppear(perform: loadAllStockData)
            .fullScreenCover(item: $selectedStock) { stock in
                StockDetailView(stock: stock, onDismiss: {
                    selectedStock = nil
                })
            }
        }
    }

    private func loadStocks(from fileName: String) -> [Stock] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("JSON file not found: \(fileName).json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedStocks = try JSONDecoder().decode([Stock].self, from: data)
            print("Successfully loaded \(decodedStocks.count) stocks from \(fileName).json")
            return decodedStocks
        } catch {
            print("Error decoding JSON from \(fileName).json: \(error)")
            return []
        }
    }
    
    private func loadAllStockData() {
        print("Loading stock data...")
        let stocks1 = loadStocks(from: primaryJsonFile)
        let stocks2 = loadStocks(from: secondaryJsonFile)

        let combined = stocks1 + stocks2
        self.stocks = combined.sorted { $0.marketCapValue > $1.marketCapValue }
        self.filteredStocks = self.stocks

        print("Total stocks loaded: \(self.stocks.count)")
    }

    private func filterStocks(searchText: String) {
        let lower = searchText.lowercased()
        let matches: [Stock]
        
        if lower.isEmpty {
            matches = stocks
        } else {
            matches = stocks.filter {
                $0.name.lowercased().contains(lower) ||
                $0.symbol.lowercased().contains(lower)
            }
        }
        
        filteredStocks = matches.sorted { $0.marketCapValue > $1.marketCapValue }
    }
}
