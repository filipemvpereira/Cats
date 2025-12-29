//
//  FavouritesViewModel.swift
//  FeatureFavourites
//

import Combine
import CoreBreeds
import CoreResources
import Foundation

@MainActor
class FavouritesViewModel: ObservableObject {

    @Published private(set) var state: FavouritesViewState = FavouritesViewState(
        title: "",
        content: .loading("")
    )

    nonisolated(unsafe) private let getFavouritesUseCase: GetFavouritesUseCase
    nonisolated(unsafe) private let unfavouriteUseCase: UnfavouriteUseCase
    nonisolated(unsafe) private let localizer: LocalizedResourcesRepository

    nonisolated init(
        getFavouritesUseCase: GetFavouritesUseCase,
        unfavouriteUseCase: UnfavouriteUseCase,
        localizer: LocalizedResourcesRepository
    ) {
        self.getFavouritesUseCase = getFavouritesUseCase
        self.unfavouriteUseCase = unfavouriteUseCase
        self.localizer = localizer
    }

    func initialize() async {
        state = FavouritesViewState(
            title: localizer.getString(.favouritesTitle),
            content: .loading(localizer.getString(.favouritesLoading))
        )

        await loadFavourites()
    }

    func refresh() async {
        await loadFavourites()
    }

    func retry() async {
        await loadFavourites()
    }

    func unfavourite(breedId: String) {
        Task {
            do {
                try await unfavouriteUseCase.execute(breedId: breedId)
                await refresh()
            } catch {
                // Silently fail for unfavourite - could add error handling if needed
            }
        }
    }

    private func loadFavourites() async {
        do {
            let favourites = try await getFavouritesUseCase.execute()

            state = FavouritesViewState(
                title: state.title,
                content: .loaded(
                    favourites.map(mapToViewStateItem),
                    emptyMessage: localizer.getString(.favouritesEmptyMessage)
                )
            )
        } catch {
            state = FavouritesViewState(
                title: state.title,
                content: .error(
                    localizer.getString(.favouritesErrorMessage),
                    retryText: localizer.getString(.favouritesErrorRetry)
                )
            )
        }
    }

    private func mapToViewStateItem(_ breed: CoreBreeds.Breed) -> FavouritesViewState.Item {
        FavouritesViewState.Item(
            id: breed.id,
            name: breed.name,
            origin: breed.origin,
            imageUrl: breed.imageUrl,
            isFavourite: breed.isFavourite
        )
    }
}
