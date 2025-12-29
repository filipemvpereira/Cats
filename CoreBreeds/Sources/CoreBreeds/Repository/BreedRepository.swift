//
//  BreedRepository.swift
//  CoreBreeds
//

import Foundation
import Network

public protocol BreedRepository {
    func getBreeds(page: Int, limit: Int) async throws -> [Breed]
    func searchBreeds(query: String) async throws -> [Breed]
    func getBreedDetail(id: String) async throws -> Breed
    func toggleFavourite(breedId: String) async throws
}

final class BreedRepositoryImpl: BreedRepository {

    private let networkService: NetworkService
    private let configuration: CoreBreedsConfiguration
    private let decoder: JSONDecoder
    private var favouriteIds: Set<String> = []

    init(
        networkService: NetworkService,
        configuration: CoreBreedsConfiguration,
        decoder: JSONDecoder
    ) {
        self.networkService = networkService
        self.configuration = configuration
        self.decoder = decoder
    }

    func getBreeds(page: Int, limit: Int) async throws -> [Breed] {
        let url = configuration.breedsURL(limit: limit, page: page)
        let request = NetworkRequest(method: .get, url: url)
        let response = try await networkService.request(request: request)

        let breedsDTO = try decoder.decode([BreedDTO].self, from: response.body)

        return breedsDTO.map { dto in
            dto.toDomain(isFavourite: favouriteIds.contains(dto.id))
        }
    }

    func searchBreeds(query: String) async throws -> [Breed] {
        let url = configuration.breedSearchURL(query: query)
        let request = NetworkRequest(method: .get, url: url)
        let response = try await networkService.request(request: request)

        let breedsDTO = try decoder.decode([BreedDTO].self, from: response.body)

        return breedsDTO.map { dto in
            dto.toDomain(isFavourite: favouriteIds.contains(dto.id))
        }
    }

    func getBreedDetail(id: String) async throws -> Breed {
        let url = configuration.breedDetailURL(id: id)
        let request = NetworkRequest(method: .get, url: url)
        let response = try await networkService.request(request: request)

        let breedDTO = try decoder.decode(BreedDTO.self, from: response.body)

        return breedDTO.toDomain(isFavourite: favouriteIds.contains(id))
    }

    func toggleFavourite(breedId: String) async throws {
        //TODO LIPE
        if favouriteIds.contains(breedId) {
            favouriteIds.remove(breedId)
        } else {
            favouriteIds.insert(breedId)
        }
    }
}
