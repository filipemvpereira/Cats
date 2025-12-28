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
        try await repository.toggleFavourite(breedId: breedId)
    }
}
