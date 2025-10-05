import SwiftUI

struct WorkDetailView: View {
    let work: OpenLibraryWork

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: work.coverArtURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12)
                    case .failure:
                        CoverPlaceholder(width: 180, height: 270)
                            .frame(maxWidth: .infinity)
                    @unknown default:
                        CoverPlaceholder(width: 180, height: 270)
                            .frame(maxWidth: .infinity)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(work.title)
                        .font(.title)
                        .bold()
                    if let subtitle = work.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    Text("By \(work.displayAuthors)")
                        .font(.headline)
                    Text("First published: \(work.displayYear)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let url = work.workURL {
                    Link("View on Open Library", destination: url)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Book details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WorkDetailView(work: OpenLibraryWork(
            key: "/works/OL66554W",
            title: "Pride and Prejudice",
            subtitle: "A novel",
            authorName: ["Jane Austen"],
            firstPublishYear: 1813,
            coverID: 8231851
        ))
    }
}
