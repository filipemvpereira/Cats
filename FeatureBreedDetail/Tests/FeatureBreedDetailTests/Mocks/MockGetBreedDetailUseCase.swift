//
//  MockGetBreedDetailUseCase.swift
//  FeatureBreedDetailTests
//

import CoreBreeds
import Foundation

@testable import FeatureBreedDetail

final class MockGetBreedDetailUseCase: GetBreedDetailUseCase {

    var mockBreed: Breed?
    var mockError: Error?
    var executeCallCount = 0
    var lastId: String?

    func execute(id: String) async throws -> Breed {
        executeCallCount += 1
        lastId = id

        if let error = mockError {
            throw error
        }

        guard let breed = mockBreed else {
            throw NSError(domain: "test", code: 404)
        }

        return breed
    }
}
