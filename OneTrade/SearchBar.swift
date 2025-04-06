import SwiftUI

extension UIApplication {
    /// Dismisses the keyboard by finding the key window in the active scene.
    func endEditing(_ force: Bool) {
        // Find the foreground-active window scene
        let scenes = connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }

        // From that scene, find the key window and resign first responder
        scenes
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .endEditing(force)
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // translucent full‑screen tappable layer when searching
            if isSearching {
                Color.black.opacity(0.001) // invisible but catches taps
                    .ignoresSafeArea()
                    .onTapGesture {
                        // dismiss everything
                        isSearching = false
                        isFocused = false
                        UIApplication.shared.endEditing(true)
                    }
            }

            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)

                    TextField("Search Stock…", text: $searchText)
                        .disableAutocorrection(true)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .padding(7)
                        .padding(.horizontal, 2)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .focused($isFocused)           // bind focus state
                        .onTapGesture {
                            // enter searching mode when tapped
                            isSearching = true
                        }

                    // always show clear button if there's text
                    if !searchText.isEmpty {
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
                        isFocused = false
                        UIApplication.shared.endEditing(true)
                    }
                    .padding(.leading, 8)
                    .transition(.move(edge: .trailing))
                    .animation(.default, value: isSearching)
                }
            }
            .padding(.horizontal)
        }
    }
}
