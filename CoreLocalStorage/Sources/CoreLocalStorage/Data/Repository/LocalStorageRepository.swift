//
//  LocalStorageRepository.swift
//  CoreLocalStorage
//

import Foundation
import SwiftData

public protocol LocalStorageRepository: Sendable {
    func saveBreeds(_ breeds: [LocalBreed]) async throws
    func getBreeds(limit: Int?, offset: Int?) async throws -> [LocalBreed]
    func getBreed(id: String) async throws -> LocalBreed?
    func searchBreeds(query: String) async throws -> [LocalBreed]
    func getFavoriteBreeds() async throws -> [LocalBreed]
    func setFavorite(breedId: String, isFavorite: Bool) async throws
}

@ModelActor
actor LocalStorageRepositoryImpl: LocalStorageRepository {

    func saveBreeds(_ breeds: [LocalBreed]) async throws {
        let context = modelContext

        do {
            for breed in breeds {
                let breedId = breed.id
                let predicate = #Predicate<BreedEntity> { $0.id == breedId }
                var descriptor = FetchDescriptor<BreedEntity>(predicate: predicate)
                descriptor.fetchLimit = 1

                if let existing = try context.fetch(descriptor).first {
                    existing.name = breed.name
                    existing.origin = breed.origin
                    existing.temperament = breed.temperament
                    existing.breedDescription = breed.description
                    existing.imageUrl = breed.imageUrl
                    existing.isFavorite = breed.isFavorite
                    existing.lastUpdated = Date()
                } else {
                    let entity = BreedEntity.from(breed)
                    context.insert(entity)
                }
            }

            try context.save()
        } catch {
            throw LocalStorageError.saveFailed(error.localizedDescription)
        }
    }

    func getBreeds(limit: Int? = nil, offset: Int? = nil) async throws -> [LocalBreed] {
        let context = modelContext
        var descriptor = FetchDescriptor<BreedEntity>()
        descriptor.sortBy = [SortDescriptor(\.name)]

        if let offset = offset {
            descriptor.fetchOffset = offset
        }
        if let limit = limit {
            descriptor.fetchLimit = limit
        }

        do {
            let breeds = try context.fetch(descriptor)
            return breeds.map { $0.toDomain() }
        } catch {
            throw LocalStorageError.fetchFailed(error.localizedDescription)
        }
    }

    func getBreed(id: String) async throws -> LocalBreed? {
        let context = modelContext

        let predicate = #Predicate<BreedEntity> { $0.id == id }
        var descriptor = FetchDescriptor<BreedEntity>(predicate: predicate)
        descriptor.fetchLimit = 1

        do {
            guard let breed = try context.fetch(descriptor).first else {
                return nil
            }
            return breed.toDomain()
        } catch {
            throw LocalStorageError.fetchFailed(error.localizedDescription)
        }
    }

    func searchBreeds(query: String) async throws -> [LocalBreed] {
        let context = modelContext

        let searchQuery = query.lowercased()
        let predicate = #Predicate<BreedEntity> { breed in
            breed.name.localizedStandardContains(searchQuery)
        }

        var descriptor = FetchDescriptor<BreedEntity>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.name)]

        do {
            let breeds = try context.fetch(descriptor)
            return breeds.map { $0.toDomain() }
        } catch {
            throw LocalStorageError.fetchFailed(error.localizedDescription)
        }
    }

    func getFavoriteBreeds() async throws -> [LocalBreed] {
        let context = modelContext

        let predicate = #Predicate<BreedEntity> { $0.isFavorite == true }
        var descriptor = FetchDescriptor<BreedEntity>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.name)]

        do {
            let breeds = try context.fetch(descriptor)
            return breeds.map { $0.toDomain() }
        } catch {
            throw LocalStorageError.fetchFailed(error.localizedDescription)
        }
    }

    func setFavorite(breedId: String, isFavorite: Bool) async throws {
        let context = modelContext

        let predicate = #Predicate<BreedEntity> { $0.id == breedId }
        var descriptor = FetchDescriptor<BreedEntity>(predicate: predicate)
        descriptor.fetchLimit = 1

        do {
            if let breed = try context.fetch(descriptor).first {
                breed.isFavorite = isFavorite
                breed.lastUpdated = Date()
                try context.save()
            }
        } catch {
            throw LocalStorageError.saveFailed(error.localizedDescription)
        }
    }
}
