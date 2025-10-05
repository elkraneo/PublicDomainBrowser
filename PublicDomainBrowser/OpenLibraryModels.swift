import Foundation

struct OpenLibrarySearchResponse: Decodable {
    let docs: [OpenLibraryWork]
}

struct OpenLibraryWork: Decodable, Identifiable, Hashable {
    let key: String
    let title: String
    let subtitle: String?
    let authorName: [String]?
    let firstPublishYear: Int?
    let coverID: Int?

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case subtitle
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case coverID = "cover_i"
    }

    var id: String { key }

    var displayAuthors: String {
        authorName?.joined(separator: ", ") ?? "Unknown author"
    }

    var displayYear: String {
        guard let year = firstPublishYear else { return "Unknown year" }
        return String(year)
    }

    var workURL: URL? {
        URL(string: "https://openlibrary.org" + key)
    }

    var coverArtURL: URL? {
        guard let coverID else { return nil }
        return URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-M.jpg")
    }
}
