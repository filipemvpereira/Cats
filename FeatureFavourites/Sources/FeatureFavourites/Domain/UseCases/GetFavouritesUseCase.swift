//
//  GetFavouritesUseCase.swift
//  FeatureFavourites
//

import CoreBreeds
import Foundation

protocol GetFavouritesUseCase {
    func execute() async throws -> [Breed]
}

final class GetFavouritesUseCaseImpl: GetFavouritesUseCase {

    private let repository: BreedRepository

    init(repository: BreedRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Breed] {
        try await repository.getFavoriteBreeds()
    }
}
