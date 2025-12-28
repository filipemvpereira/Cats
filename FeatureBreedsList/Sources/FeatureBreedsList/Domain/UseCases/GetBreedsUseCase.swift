//
//  GetBreedsUseCase.swift
//  FeatureBreedsList
//

import CoreBreeds
import Foundation

protocol GetBreedsUseCase {
    func execute(page: Int, limit: Int, searchQuery: String?) async throws -> [Breed]
}

final class GetBreedsUseCaseImpl: GetBreedsUseCase {

    private let repository: BreedRepository

    init(repository: BreedRepository) {
        self.repository = repository
    }

    func execute(page: Int, limit: Int, searchQuery: String?) async throws -> [Breed] {
        if let searchQuery, !searchQuery.isEmpty {
            return try await repository.searchBreeds(query: searchQuery)
        } else {
            return try await repository.getBreeds(page: page, limit: limit)
        }
    }
}
