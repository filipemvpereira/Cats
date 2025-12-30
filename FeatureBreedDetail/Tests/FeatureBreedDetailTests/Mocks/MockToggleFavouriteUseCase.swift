//
//  MockToggleFavouriteUseCase.swift
//  FeatureBreedDetailTests
//

import Foundation

@testable import FeatureBreedDetail

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
