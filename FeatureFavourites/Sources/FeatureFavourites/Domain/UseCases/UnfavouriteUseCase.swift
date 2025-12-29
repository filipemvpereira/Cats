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
        //TODO LIPE
        // On favorites screen, we only remove favorites (toggle to false)
        try await repository.toggleFavourite(breedId: breedId)
    }
}
