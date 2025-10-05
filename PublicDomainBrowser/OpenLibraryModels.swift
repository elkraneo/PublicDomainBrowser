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
    let coverEditionKey: String?

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case subtitle
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case coverID = "cover_i"
        case coverEditionKey = "cover_edition_key"
    }

    var id: String { key }

    var displayAuthors: String {
        guard let names = authorName?.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }).filter({ !$0.isEmpty }), !names.isEmpty else {
            return "Unknown author"
        }
        return names.joined(separator: ", ")
    }

    var displayYear: String {
        guard let year = firstPublishYear else { return "Unknown year" }
        return String(year)
    }

    var workURL: URL? {
        URL(string: "https://openlibrary.org" + key)
    }

    var coverArtURL: URL? {
        if let coverID {
            return URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-M.jpg")
        }
        if let editionKey = coverEditionKey {
            return URL(string: "https://covers.openlibrary.org/b/olid/\(editionKey)-M.jpg")
        }
        return nil
    }
}
