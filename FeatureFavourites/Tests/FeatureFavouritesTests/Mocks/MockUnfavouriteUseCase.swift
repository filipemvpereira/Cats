//
//  MockUnfavouriteUseCase.swift
//  FeatureFavouritesTests
//

import Foundation

@testable import FeatureFavourites

final class MockUnfavouriteUseCase: UnfavouriteUseCase {

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
