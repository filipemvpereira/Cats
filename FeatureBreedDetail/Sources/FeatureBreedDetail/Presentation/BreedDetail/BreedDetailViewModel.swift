//
//  BreedDetailViewModel.swift
//  FeatureBreedDetail
//

import Combine
import CoreBreeds
import CoreResources
import Foundation

@MainActor
class BreedDetailViewModel: ObservableObject {

    @Published private(set) var state: BreedDetailViewState = BreedDetailViewState(
        content: .loading("")
    )

    nonisolated(unsafe) private let getBreedDetailUseCase: GetBreedDetailUseCase
    nonisolated(unsafe) private let toggleFavouriteUseCase: ToggleFavouriteUseCase
    nonisolated(unsafe) private let localizer: LocalizedResourcesRepository
    private let breedId: String

    nonisolated init(
        breedId: String,
        getBreedDetailUseCase: GetBreedDetailUseCase,
        toggleFavouriteUseCase: ToggleFavouriteUseCase,
        localizer: LocalizedResourcesRepository
    ) {
        self.breedId = breedId
        self.getBreedDetailUseCase = getBreedDetailUseCase
        self.toggleFavouriteUseCase = toggleFavouriteUseCase
        self.localizer = localizer
    }

    func initialize() async {
        state = BreedDetailViewState(
            content: .loading(localizer.getString(.breedDetailLoading))
        )
        await loadBreedDetail()
    }

    func retry() async {
        state = BreedDetailViewState(
            content: .loading(localizer.getString(.breedDetailLoading))
        )
        await loadBreedDetail()
    }

    func toggleFavourite() {
        Task {
            do {
                if case .loaded(let detail) = state.content {
                    try await toggleFavouriteUseCase.execute(breedId: detail.id)

                    state = BreedDetailViewState(
                        content: .loaded(
                            BreedDetailViewState.Detail(
                                id: detail.id,
                                name: detail.name,
                                origin: detail.origin,
                                temperament: detail.temperament,
                                description: detail.description,
                                imageUrl: detail.imageUrl,
                                isFavourite: !detail.isFavourite,
                                sectionOriginTitle: detail.sectionOriginTitle,
                                sectionTemperamentTitle: detail.sectionTemperamentTitle,
                                sectionDescriptionTitle: detail.sectionDescriptionTitle
                            )
                        )
                    )
                }
            } catch {
                // Silently fail for toggle - could add error handling if needed
            }
        }
    }

    private func loadBreedDetail() async {
        do {
            let breed = try await getBreedDetailUseCase.execute(id: breedId)

            state = BreedDetailViewState(
                content: .loaded(mapToViewStateDetail(breed))
            )
        } catch {
            state = BreedDetailViewState(
                content: .error(
                    localizer.getString(.breedDetailErrorMessage),
                    retryText: localizer.getString(.breedDetailErrorRetry)
                )
            )
        }
    }

    private func mapToViewStateDetail(_ breed: Breed) -> BreedDetailViewState.Detail {
        BreedDetailViewState.Detail(
            id: breed.id,
            name: breed.name,
            origin: breed.origin,
            temperament: breed.temperament,
            description: breed.description,
            imageUrl: breed.imageUrl,
            isFavourite: breed.isFavourite,
            sectionOriginTitle: localizer.getString(.breedDetailSectionOrigin),
            sectionTemperamentTitle: localizer.getString(.breedDetailSectionTemperament),
            sectionDescriptionTitle: localizer.getString(.breedDetailSectionDescription)
        )
    }
}
