import Foundation

struct OpenLibraryService {
    enum ServiceError: Error, LocalizedError {
        case invalidURL
        case decodingFailed
        case serverError(statusCode: Int)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Failed to build the search request."
            case .decodingFailed:
                return "Could not understand the response from the server."
            case .serverError(let statusCode):
                return "Search failed with status code \(statusCode)."
            }
        }
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchWorks(matching query: String) async throws -> [OpenLibraryWork] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        var components = URLComponents(string: "https://openlibrary.org/search.json")
        components?.queryItems = [
            URLQueryItem(name: "q", value: trimmedQuery),
            URLQueryItem(name: "public_scan", value: "true"),
            URLQueryItem(name: "limit", value: "25")
        ]

        guard let url = components?.url else {
            throw ServiceError.invalidURL
        }

        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw ServiceError.serverError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard let payload = try? decoder.decode(OpenLibrarySearchResponse.self, from: data) else {
            throw ServiceError.decodingFailed
        }

        return payload.docs
    }
}
