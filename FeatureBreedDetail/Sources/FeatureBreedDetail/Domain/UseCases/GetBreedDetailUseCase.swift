//
//  GetBreedDetailUseCase.swift
//  FeatureBreedDetail
//

import CoreBreeds
import Foundation

protocol GetBreedDetailUseCase {
    func execute(id: String) async throws -> Breed
}

final class GetBreedDetailUseCaseImpl: GetBreedDetailUseCase {

    private let repository: BreedRepository

    init(repository: BreedRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws -> Breed {
        return try await repository.getBreedDetail(id: id)
    }
}
