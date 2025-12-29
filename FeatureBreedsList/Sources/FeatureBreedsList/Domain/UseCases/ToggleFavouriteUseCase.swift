//
//  ToggleFavouriteUseCase.swift
//  FeatureBreedsList
//

import CoreBreeds
import Foundation

protocol ToggleFavouriteUseCase {
    func execute(breedId: String) async throws
}

final class ToggleFavouriteUseCaseImpl: ToggleFavouriteUseCase {

    private let repository: BreedRepository

    init(repository: BreedRepository) {
        self.repository = repository
    }

    func execute(breedId: String) async throws {
        let breed = try await repository.getBreedDetail(id: breedId)
        try await repository.setFavorite(breedId: breedId, isFavorite: !breed.isFavourite)
    }
}
