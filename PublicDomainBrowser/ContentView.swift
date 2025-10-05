import SwiftUI
import Observation

struct ContentView: View {
    @State private var viewModel = SearchViewModel()
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
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: SearchLayout.gridSpacing) {
                            ForEach(viewModel.results) { work in
                                NavigationLink(value: work) {
                                    SearchResultCard(work: work)
                                }
                                .buttonStyle(.plain)
                                .hoverEffect(.lift)
                            }
                        }
                    }
                    .contentMargins(.horizontal, SearchLayout.horizontalPadding)
                    .contentMargins(.vertical, SearchLayout.verticalPadding, for: .scrollContent)
                }
            }
            .navigationTitle("Public Domain")
            .navigationDestination(for: OpenLibraryWork.self) { work in
                WorkDetailView(work: work)
            }
        }
        .scenePadding()
        .searchable(text: $viewModel.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search books, authors, or subjects")
        .onSubmit(of: .search) {
            viewModel.submitSearch()
        }
        .onChange(of: viewModel.query) { _ in
            viewModel.submitSearch()
        }
    }
}

private enum SearchLayout {
    static let coverSize = CGSize(width: 220, height: 320)
    static let cardCornerRadius: CGFloat = 28
    static let coverCornerRadius: CGFloat = 20
    static let gridSpacing: CGFloat = 32
    static let horizontalPadding: CGFloat = 48
    static let verticalPadding: CGFloat = 32
    static let minimumCardWidth: CGFloat = 280
    static let maximumCardWidth: CGFloat = 360
}

private let gridColumns: [GridItem] = [
    GridItem(
        .adaptive(
            minimum: SearchLayout.minimumCardWidth,
            maximum: SearchLayout.maximumCardWidth
        ),
        spacing: SearchLayout.gridSpacing,
        alignment: .top
    )
]

private struct SearchResultCard: View {
    let work: OpenLibraryWork

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            AsyncImage(url: work.coverArtURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: SearchLayout.coverSize.width, height: SearchLayout.coverSize.height)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: SearchLayout.coverSize.width, height: SearchLayout.coverSize.height)
                        .clipShape(RoundedRectangle(cornerRadius: SearchLayout.coverCornerRadius, style: .continuous))
                case .failure:
                    CoverPlaceholder(width: SearchLayout.coverSize.width, height: SearchLayout.coverSize.height)
                        .clipShape(RoundedRectangle(cornerRadius: SearchLayout.coverCornerRadius, style: .continuous))
                @unknown default:
                    CoverPlaceholder(width: SearchLayout.coverSize.width, height: SearchLayout.coverSize.height)
                        .clipShape(RoundedRectangle(cornerRadius: SearchLayout.coverCornerRadius, style: .continuous))
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(work.title)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                if let subtitle = work.subtitle?.trimmingCharacters(in: .whitespacesAndNewlines), !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Text(work.displayAuthors)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(work.displayYear)
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: SearchLayout.cardCornerRadius, style: .continuous)
                .fill(.thinMaterial)
                .shadow(radius: 4, y: 6)
        }
        .glassBackgroundEffect(in: .rect(cornerRadius: SearchLayout.cardCornerRadius))
    }
}

#Preview {
    ContentView()
}
