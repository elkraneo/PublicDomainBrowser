import SwiftUI
import Observation

struct ContentView: View {
    @State private var viewModel = SearchViewModel()
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Searching…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let message = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text(message)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Try Again") {
                            viewModel.submitSearch()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.results.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Search millions of titles in the public domain.")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.results) { work in
                        NavigationLink(value: work) {
                            SearchResultRow(work: work)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Public Domain")
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") { isSearchFieldFocused = false }
                }
            }
            .navigationDestination(for: OpenLibraryWork.self) { work in
                WorkDetailView(work: work)
            }
        }
        .searchable(text: $viewModel.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search books, authors, or subjects")
        .onSubmit(of: .search) {
            viewModel.submitSearch()
        }
        .onChange(of: viewModel.query) { _ in
            viewModel.submitSearch()
        }
        .focused($isSearchFieldFocused)
    }
}

private struct SearchResultRow: View {
    let work: OpenLibraryWork

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: work.coverArtURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 60, height: 90)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 90)
                        .clipped()
                        .cornerRadius(6)
                case .failure:
                    CoverPlaceholder()
                @unknown default:
                    CoverPlaceholder()
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(work.title)
                    .font(.headline)
                    .lineLimit(2)
                if let subtitle = work.subtitle?.trimmingCharacters(in: .whitespacesAndNewlines), !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Text(work.displayAuthors)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(work.displayYear)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
}
