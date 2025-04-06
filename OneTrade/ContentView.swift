import SwiftUI

// Stock struct remains the same
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
}

struct ContentView: View {
    @State private var searchText = ""
    @State private var stocks: [Stock] = []
    @State private var filteredStocks: [Stock] = []
    @State private var isSearching = false // Keep if SearchBar uses it
    @State private var selectedStock: Stock? = nil
    // Removed presentationMode here, handled in StockDetailView now

    // --- Define the names of your JSON files ---
    let primaryJsonFile = "nasdaq_full_tickers"
    let secondaryJsonFile = "nyse_full_tickers"

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(searchText: $searchText, isSearching: $isSearching)

                List {
                    // Use filteredStocks which is updated by the search
                    ForEach(filteredStocks) { stock in
                        Button {
                            selectedStock = stock
                        } label: {
                            HStack {
                                // Display Name (Symbol) format
                                Text("\(stock.name) (\(stock.symbol))")
                                    .foregroundColor(.primary) // Ensure text color contrasts background
                            }
                        }
                    }
                }
                .listStyle(.plain)
                // Use the new Combine-based search filtering
                .onChange(of: searchText) { newValue in
                     filterStocks(searchText: newValue)
                 }
            }
            .navigationTitle("OneTrade")
            // Load data when the view appears
            .onAppear(perform: loadAllStockData)
             // Use fullScreenCover for presenting the detail view
             .fullScreenCover(item: $selectedStock) { stock in
                 // Pass a closure to handle dismissal within StockDetailView
                 StockDetailView(stock: stock, onDismiss: {
                     selectedStock = nil // Reset the selection when dismissed
                 })
            }
        }
         // Use .navigationViewStyle(.stack) on iPad if needed to avoid split view issues
         // .navigationViewStyle(.stack)
    }

    // --- Helper function to load and decode a single JSON file ---
    private func loadStocks(from fileName: String) -> [Stock] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("JSON file not found: \(fileName).json")
            return [] // Return empty array if file not found
        }

        do {
            let data = try Data(contentsOf: url)
            let decodedStocks = try JSONDecoder().decode([Stock].self, from: data)
            print("Successfully loaded \(decodedStocks.count) stocks from \(fileName).json")
            return decodedStocks
        } catch {
            print("Error decoding JSON from \(fileName).json: \(error)")
            return [] // Return empty array on error
        }
    }

    // --- Updated function to load data from multiple files ---
    private func loadAllStockData() {
        print("Loading stock data...")
        // Load stocks from the first file
        let stocks1 = loadStocks(from: primaryJsonFile)

        // Load stocks from the second file
        let stocks2 = loadStocks(from: secondaryJsonFile)

        // Combine the arrays
        // Optional: Add deduplication logic here if needed (e.g., based on symbol)
        self.stocks = stocks1 + stocks2

        // Initialize filtered stocks with all loaded stocks
        self.filteredStocks = self.stocks

        print("Total stocks loaded: \(self.stocks.count)")
        // Optional: Sort the combined list initially if desired
        // self.stocks.sort { $0.symbol < $1.symbol }
        // self.filteredStocks = self.stocks
    }

    // --- Filtering logic remains the same ---
    private func filterStocks(searchText: String) {
        if searchText.isEmpty {
            // If search text is empty, show all stocks
            filteredStocks = stocks
        } else {
            // Filter based on name or symbol containing the search text (case-insensitive)
            let lowercasedQuery = searchText.lowercased()
            filteredStocks = stocks.filter { stock in
                stock.name.lowercased().contains(lowercasedQuery) ||
                stock.symbol.lowercased().contains(lowercasedQuery)
            }
        }
    }
}
