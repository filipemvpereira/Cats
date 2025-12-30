//
//  MockGetFavouritesUseCase.swift
//  FeatureFavouritesTests
//

import CoreBreeds
import Foundation

@testable import FeatureFavourites

final class MockGetFavouritesUseCase: GetFavouritesUseCase {

    var mockBreeds: [Breed] = []
    var mockError: Error?
    var executeCallCount = 0

    func execute() async throws -> [Breed] {
        executeCallCount += 1

        if let error = mockError {
            throw error
        }

        return mockBreeds
    }
}
