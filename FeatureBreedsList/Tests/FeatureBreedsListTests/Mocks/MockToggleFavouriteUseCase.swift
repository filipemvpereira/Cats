//
//  MockToggleFavouriteUseCase.swift
//  FeatureBreedsListTests
//

import Foundation

@testable import FeatureBreedsList

final class MockToggleFavouriteUseCase: ToggleFavouriteUseCase {

    var mockError: Error?
    var executeCallCount = 0
    var lastBreedId: String?

    func execute(breedId: String) async throws {
        executeCallCount += 1
        lastBreedId = breedId

        if let error = mockError {
            throw error
        }
    }
}
