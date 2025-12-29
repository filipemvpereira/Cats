//
//  UnfavouriteUseCase.swift
//  FeatureFavourites
//

import CoreBreeds
import Foundation

protocol UnfavouriteUseCase {
    func execute(breedId: String) async throws
}

final class UnfavouriteUseCaseImpl: UnfavouriteUseCase {

    private let repository: BreedRepository

    init(repository: BreedRepository) {
        self.repository = repository
    }

    func execute(breedId: String) async throws {
        let breed = try await repository.getBreedDetail(id: breedId)
        if breed.isFavourite {
            try await repository.setFavorite(breedId: breedId, isFavorite: false)
        }
    }
}
