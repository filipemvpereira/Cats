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
        // Get all breeds with large limit to fetch all at once //TODO LIPE
        let allBreeds = try await repository.getBreeds(page: 0, limit: 100)

        // Filter only favourites
        return allBreeds.filter { $0.isFavourite }
    }
}
