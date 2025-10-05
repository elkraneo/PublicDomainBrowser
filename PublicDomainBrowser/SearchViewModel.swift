import Foundation
import Observation

@MainActor
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
            cancelOngoingSearch()
            isLoading = false
            errorMessage = trimmed.isEmpty ? nil : "Keep typing to narrow your search."
            results = []
            return
        }

        cancelOngoingSearch()

        searchTask = Task { [weak self] in
            guard let self else { return }
            await self.performSearch(with: trimmed)
        }
    }

    private func cancelOngoingSearch() {
        searchTask?.cancel()
        searchTask = nil
    }

    private func performSearch(with query: String) async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let response = try await service.searchWorks(matching: query)
            guard !Task.isCancelled else { return }
            results = response
        } catch {
            guard !Task.isCancelled else { return }
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Something went wrong."
            results = []
        }
    }
}
