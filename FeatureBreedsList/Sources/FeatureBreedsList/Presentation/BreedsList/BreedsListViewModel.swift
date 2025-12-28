//
//  BreedsListViewModel.swift
//  FeatureBreedsList
//

import Combine
import CoreBreeds
import CoreResources
import Foundation

@MainActor
class BreedsListViewModel: ObservableObject {

    @Published private(set) var state: BreedsListViewState = BreedsListViewState(
        title: "",
        content: .loading("")
    )

    nonisolated(unsafe) private let getBreedsUseCase: GetBreedsUseCase
    nonisolated(unsafe) private let toggleFavouriteUseCase: ToggleFavouriteUseCase
    nonisolated(unsafe) private let localizer: LocalizedResourcesRepository

    private var currentPage: Int = 0
    private let pageLimit: Int = 20
    private var canLoadMore: Bool = true
    private var loadedBreeds: [CoreBreeds.Breed] = []
    private var hasInitialized: Bool = false

    nonisolated init(
        getBreedsUseCase: GetBreedsUseCase,
        toggleFavouriteUseCase: ToggleFavouriteUseCase,
        localizer: LocalizedResourcesRepository
    ) {
        self.getBreedsUseCase = getBreedsUseCase
        self.toggleFavouriteUseCase = toggleFavouriteUseCase
        self.localizer = localizer
    }

    func initialize() async {
        guard !hasInitialized else { return }

        state = BreedsListViewState(
            title: localizer.getString(.breedsListTitle),
            content: .loading(localizer.getString(.breedsListLoading))
        )

        currentPage = 0
        canLoadMore = true
        loadedBreeds = []
        await loadBreeds()
        hasInitialized = true
    }

    func refresh() async {
        guard case .loaded(_, let searchText, _, _, _) = state.content else {
            currentPage = 0
            canLoadMore = true
            loadedBreeds = []
            await loadBreeds()
            return
        }

        if !searchText.isEmpty {
            await search(query: searchText)
        } else {
            currentPage = 0
            canLoadMore = true
            loadedBreeds = []
            await loadBreeds()
        }
    }

    func retry() async {
        await loadBreeds()
    }

    func loadMore() async {
        guard canLoadMore, case .loaded(_, let searchText, let searchPlaceholder, let emptyMessage, _) = state.content else {
            return
        }

        guard case .loaded(let items, _, _, _, _) = state.content else {
            return
        }

        state = BreedsListViewState(
            title: state.title,
            content: .loaded(items, searchText: searchText, searchPlaceholder: searchPlaceholder, emptyMessage: emptyMessage, isLoadingMore: true)
        )

        currentPage += 1
        await loadBreeds(append: true)
    }

    func search(query: String) async {
        currentPage = 0
        canLoadMore = query.isEmpty
        loadedBreeds = []

        state = BreedsListViewState(
            title: state.title,
            content: .loading(localizer.getString(.breedsListLoading))
        )

        do {
            let breeds = try await getBreedsUseCase.execute(
                page: currentPage,
                limit: pageLimit,
                searchQuery: query.isEmpty ? nil : query
            )

            loadedBreeds = breeds

            state = BreedsListViewState(
                title: state.title,
                content: .loaded(
                    breeds.map(mapToViewStateItem),
                    searchText: query,
                    searchPlaceholder: localizer.getString(.breedsListSearchPlaceholder),
                    emptyMessage: localizer.getString(.breedsListEmptyMessage),
                    isLoadingMore: false
                )
            )
        } catch {
            state = BreedsListViewState(
                title: state.title,
                content: .error(
                    localizer.getString(.breedsListErrorMessage),
                    retryText: localizer.getString(.breedsListErrorRetry)
                )
            )
        }
    }

    func toggleFavourite(breedId: String) {
        Task {
            do {
                try await toggleFavouriteUseCase.execute(breedId: breedId)
                await refresh()
            } catch {
                // TODO: Handle error
            }
        }
    }

    private func loadBreeds(append: Bool = false) async {
        do {
            let breeds = try await getBreedsUseCase.execute(
                page: currentPage,
                limit: pageLimit,
                searchQuery: nil
            )

            if append {
                loadedBreeds.append(contentsOf: breeds)
            } else {
                loadedBreeds = breeds
            }

            canLoadMore = breeds.count == pageLimit

            state = BreedsListViewState(
                title: state.title,
                content: .loaded(
                    loadedBreeds.map(mapToViewStateItem),
                    searchText: "",
                    searchPlaceholder: localizer.getString(.breedsListSearchPlaceholder),
                    emptyMessage: localizer.getString(.breedsListEmptyMessage),
                    isLoadingMore: false
                )
            )
        } catch {
            state = BreedsListViewState(
                title: state.title,
                content: .error(
                    localizer.getString(.breedsListErrorMessage),
                    retryText: localizer.getString(.breedsListErrorRetry)
                )
            )
        }
    }

    private func mapToViewStateItem(_ breed: CoreBreeds.Breed) -> BreedsListViewState.Item {
        BreedsListViewState.Item(
            id: breed.id,
            name: breed.name,
            origin: breed.origin,
            imageUrl: breed.imageUrl,
            isFavourite: breed.isFavourite
        )
    }
}
