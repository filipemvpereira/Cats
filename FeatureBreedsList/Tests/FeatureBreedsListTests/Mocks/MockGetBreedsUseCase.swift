//
//  MockGetBreedsUseCase.swift
//  FeatureBreedsListTests
//

import CoreBreeds
import Foundation

@testable import FeatureBreedsList

final class MockGetBreedsUseCase: GetBreedsUseCase {

    var mockBreeds: [Breed] = []
    var mockError: Error?

    func execute(page: Int, limit: Int, searchQuery: String?) async throws -> [Breed] {
        if let error = mockError {
            throw error
        }
        return mockBreeds
    }
}
