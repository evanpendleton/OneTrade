import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)

                TextField("Search Stock…", text: $searchText)
                    .disableAutocorrection(true)            // iOS 15 compatibility
                    .autocorrectionDisabled(true)           // iOS 16+
                    .textInputAutocapitalization(.never)
                    .padding(7)
                    .padding(.horizontal, 2)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                if isSearching && !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(8)

            if isSearching {
                Button("Cancel") {
                    isSearching = false
                    searchText = ""
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
                .padding(.leading, 8)
                .transition(.move(edge: .trailing))
                .animation(.default, value: isSearching)
            }
        }
        .padding(.horizontal)
    }
}
