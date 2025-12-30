//
//  MockLocalizedResourcesRepository.swift
//  FeatureFavouritesTests
//

import CoreResources
import Foundation

final class MockLocalizedResourcesRepository: LocalizedResourcesRepository {

    func getString(_ key: LocalizedKey) -> String {
        return "Test String"
    }
}
