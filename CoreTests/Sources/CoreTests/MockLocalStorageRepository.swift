//
//  MockLocalStorageRepository.swift
//  CoreTests
//

import CoreLocalStorage
import Foundation

public final class MockLocalStorageRepository: LocalStorageRepository, @unchecked Sendable {

    public var savedBreeds: [LocalBreed] = []
    public var favoriteUpdates: [String: Bool] = [:]

    public init() {}

    public func saveBreeds(_ breeds: [LocalBreed]) async throws {
        for breed in breeds {
            if let index = savedBreeds.firstIndex(where: { $0.id == breed.id }) {
                savedBreeds[index] = breed
            } else {
                savedBreeds.append(breed)
            }
        }
    }

    public func getBreeds(limit: Int?, offset: Int?) async throws -> [LocalBreed] {
        let startIndex = offset ?? 0
        let endIndex = min(startIndex + (limit ?? savedBreeds.count), savedBreeds.count)
        return Array(savedBreeds[startIndex..<endIndex])
    }

    public func getBreed(id: String) async throws -> LocalBreed? {
        return savedBreeds.first(where: { $0.id == id })
    }

    public func searchBreeds(query: String) async throws -> [LocalBreed] {
        return savedBreeds.filter { $0.name.lowercased().contains(query.lowercased()) }
    }

    public func getFavoriteBreeds() async throws -> [LocalBreed] {
        return savedBreeds.filter { $0.isFavorite }
    }

    public func setFavorite(breedId: String, isFavorite: Bool) async throws {
        favoriteUpdates[breedId] = isFavorite
        if let index = savedBreeds.firstIndex(where: { $0.id == breedId }) {
            let breed = savedBreeds[index]
            savedBreeds[index] = LocalBreed(
                id: breed.id,
                name: breed.name,
                origin: breed.origin,
                temperament: breed.temperament,
                description: breed.description,
                imageUrl: breed.imageUrl,
                isFavorite: isFavorite,
                lastUpdated: breed.lastUpdated
            )
        }
    }
}
