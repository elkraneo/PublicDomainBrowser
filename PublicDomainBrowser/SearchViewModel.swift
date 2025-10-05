import Foundation
import Observation

@Observable
final class SearchViewModel {
    var query: String = ""
    private(set) var results: [OpenLibraryWork] = []
    private(set) var isLoading: Bool = false
    var errorMessage: String?

    @ObservationIgnored private let service: OpenLibraryService
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    init(service: OpenLibraryService = OpenLibraryService()) {
        self.service = service
    }

    func submitSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            searchTask?.cancel()
            isLoading = false
            errorMessage = trimmed.isEmpty ? nil : "Keep typing to narrow your search."
            results = []
            return
        }

        searchTask?.cancel()

        searchTask = Task { [weak self] in
            guard let self else { return }
            await performSearch(with: trimmed)
        }
    }

    func performSearch(with query: String) async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let response = try await service.searchWorks(matching: query)
            results = response
        } catch {
            if Task.isCancelled { return }
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Something went wrong."
            results = []
        }
    }
}
