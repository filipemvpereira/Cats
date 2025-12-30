//
//  BreedRepository.swift
//  CoreBreeds
//

import CoreLocalStorage
import Foundation
import Network

public protocol BreedRepository {
    func getBreeds(page: Int, limit: Int) async throws -> [Breed]
    func searchBreeds(query: String) async throws -> [Breed]
    func getBreedDetail(id: String) async throws -> Breed
    func setFavorite(breedId: String, isFavorite: Bool) async throws
    func getFavoriteBreeds() async throws -> [Breed]
}

public final class BreedRepositoryImpl: BreedRepository {

    nonisolated(unsafe) private let networkService: NetworkService
    nonisolated(unsafe) private let configuration: CoreBreedsConfiguration
    nonisolated(unsafe) private let decoder: JSONDecoder
    nonisolated(unsafe) private let localStorage: LocalStorageRepository

    public nonisolated init(
        networkService: NetworkService,
        configuration: CoreBreedsConfiguration,
        decoder: JSONDecoder,
        localStorage: LocalStorageRepository
    ) {
        self.networkService = networkService
        self.configuration = configuration
        self.decoder = decoder
        self.localStorage = localStorage
    }

    public func getBreeds(page: Int, limit: Int) async throws -> [Breed] {
        do {
            let url = configuration.breedsURL(limit: limit, page: page)
            let request = NetworkRequest(method: .get, url: url)
            let response = try await networkService.request(request: request)

            let breedsDTO = try decoder.decode([BreedDTO].self, from: response.body)
            let breeds = await mapBreedDTOs(breedsDTO)

            try? await saveBreedsDatabase(breeds)

            return breeds
        } catch {
            let cachedBreeds = try await localStorage.getBreeds(limit: limit, offset: page * limit)
            return cachedBreeds.map(mapLocalBreedToDomain)
        }
    }

    public func searchBreeds(query: String) async throws -> [Breed] {
        do {
            let url = configuration.breedSearchURL(query: query)
            let request = NetworkRequest(method: .get, url: url)
            let response = try await networkService.request(request: request)

            let breedsDTO = try decoder.decode([BreedDTO].self, from: response.body)
            let breeds = await mapBreedDTOs(breedsDTO)

            try? await saveBreedsDatabase(breeds)

            return breeds
        } catch {
            let cachedBreeds = try await localStorage.searchBreeds(query: query)
            return cachedBreeds.map(mapLocalBreedToDomain)
        }
    }

    public func getBreedDetail(id: String) async throws -> Breed {
        do {
            let url = configuration.breedDetailURL(id: id)
            let request = NetworkRequest(method: .get, url: url)
            let response = try await networkService.request(request: request)

            let breedDTO = try decoder.decode(BreedDTO.self, from: response.body)
            let isFavorite = (try? await localStorage.getBreed(id: id))?.isFavorite ?? false
            let breed = breedDTO.toDomain(isFavourite: isFavorite)

            try? await saveBreedsDatabase([breed])

            return breed
        } catch {
            guard let localBreed = try await localStorage.getBreed(id: id) else {
                throw error
            }

            return mapLocalBreedToDomain(localBreed)
        }
    }

    public func setFavorite(breedId: String, isFavorite: Bool) async throws {
        try await localStorage.setFavorite(breedId: breedId, isFavorite: isFavorite)
    }

    public func getFavoriteBreeds() async throws -> [Breed] {
        let favoriteBreeds = try await localStorage.getFavoriteBreeds()
        return favoriteBreeds.map(mapLocalBreedToDomain)
    }

    private func mapBreedDTOs(_ dtos: [BreedDTO]) async -> [Breed] {
        var breeds: [Breed] = []
        for dto in dtos {
            let isFavorite = (try? await localStorage.getBreed(id: dto.id))?.isFavorite ?? false
            breeds.append(dto.toDomain(isFavourite: isFavorite))
        }
        return breeds
    }

    private func mapLocalBreedToDomain(_ localBreed: LocalBreed) -> Breed {
        Breed(
            id: localBreed.id,
            name: localBreed.name,
            origin: localBreed.origin,
            temperament: localBreed.temperament,
            description: localBreed.description,
            imageUrl: localBreed.imageUrl,
            isFavourite: localBreed.isFavorite
        )
    }

    private func saveBreedsDatabase(_ breeds: [Breed]) async {
        let localBreeds = breeds.map { breed in
            LocalBreed(
                id: breed.id,
                name: breed.name,
                origin: breed.origin,
                temperament: breed.temperament,
                description: breed.description,
                imageUrl: breed.imageUrl,
                isFavorite: breed.isFavourite,
                lastUpdated: Date()
            )
        }
        try? await localStorage.saveBreeds(localBreeds)
    }
}
