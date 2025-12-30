//
//  BreedRepositoryTests.swift
//  CoreBreedsTests
//

import CoreLocalStorage
import CoreTests
import Network
import XCTest

@testable import CoreBreeds

final class BreedRepositoryTests: XCTestCase {

    private var repository: BreedRepositoryImpl!
    private var mockNetworkService: MockNetworkService!
    private var mockLocalStorage: MockLocalStorageRepository!
    private var configuration: CoreBreedsConfiguration!
    private var decoder: JSONDecoder!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockLocalStorage = MockLocalStorageRepository()
        configuration = CoreBreedsConfiguration(baseURL: "https://api/v1")
        decoder = JSONDecoder()

        repository = BreedRepositoryImpl(
            networkService: mockNetworkService,
            configuration: configuration,
            decoder: decoder,
            localStorage: mockLocalStorage
        )
    }

    override func tearDown() {
        repository = nil
        mockNetworkService = nil
        mockLocalStorage = nil
        configuration = nil
        decoder = nil
        super.tearDown()
    }

    func test_get_breeds_success_returns_breeds() async throws {
        let expectedBreeds = [
            createMockBreedDTO(id: "1"),
            createMockBreedDTO(id: "2")
        ]
        let jsonData = createMockBreedsJSON(breeds: expectedBreeds)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)

        let breeds = try await repository.getBreeds(page: 0, limit: 10)

        XCTAssertEqual(breeds.count, 2)
        XCTAssertEqual(breeds[0].id, "1")
        XCTAssertEqual(breeds[1].id, "2")
    }

    func test_get_breeds_success_saves_breeds_to_database() async throws {
        let expectedBreeds = [createMockBreedDTO(id: "1")]
        let jsonData = createMockBreedsJSON(breeds: expectedBreeds)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)

        _ = try await repository.getBreeds(page: 0, limit: 10)

        XCTAssertEqual(mockLocalStorage.savedBreeds.count, 1)
        XCTAssertEqual(mockLocalStorage.savedBreeds[0].id, "1")
    }

    func test_get_breeds_with_favorites_returns_breeds_with_correct_favorite_status() async throws {
        let expectedBreeds = [
            createMockBreedDTO(id: "1"),
            createMockBreedDTO(id: "2")
        ]
        let jsonData = createMockBreedsJSON(breeds: expectedBreeds)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)

        mockLocalStorage.savedBreeds = [createMockLocalBreed(id: "1", isFavorite: true)]

        let breeds = try await repository.getBreeds(page: 0, limit: 10)

        XCTAssertTrue(breeds[0].isFavourite)
        XCTAssertFalse(breeds[1].isFavourite)
    }

    func test_get_breeds_network_error_falls_back_to_cached_data() async throws {
        mockNetworkService.mockError = NetworkError.noData
        mockLocalStorage.savedBreeds = [
            createMockLocalBreed(id: "1", isFavorite: false)
        ]

        let breeds = try await repository.getBreeds(page: 0, limit: 10)

        XCTAssertEqual(breeds.count, 1)
        XCTAssertEqual(breeds[0].id, "1")
    }

    func test_get_breeds_empty_response_returns_empty_array() async throws {
        let jsonData = createMockBreedsJSON(breeds: [])
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)

        let breeds = try await repository.getBreeds(page: 0, limit: 10)

        XCTAssertTrue(breeds.isEmpty)
    }

    func test_get_breeds_invalid_json_falls_back_to_cache() async throws {
        let invalidJSON = Data("invalid json".utf8)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: invalidJSON)

        let breeds = try await repository.getBreeds(page: 0, limit: 10)

        XCTAssertTrue(breeds.isEmpty)
    }

    func test_search_breeds_success_returns_matching_breeds() async throws {
        let expectedBreeds = [createMockBreedDTO(id: "1")]
        let jsonData = createMockBreedsJSON(breeds: expectedBreeds)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)

        let breeds = try await repository.searchBreeds(query: "bengal")

        XCTAssertEqual(breeds.count, 1)
        XCTAssertEqual(breeds[0].id, "1")
    }

    func test_search_breeds_network_error_falls_back_to_cached_search() async throws {
        mockNetworkService.mockError = NetworkError.noData
        mockLocalStorage.savedBreeds = [
            createMockLocalBreed(id: "1", isFavorite: false, name: "bengal")
        ]

        let breeds = try await repository.searchBreeds(query: "bengal")

        XCTAssertEqual(breeds.count, 1)
        XCTAssertEqual(breeds[0].id, "1")
    }

    func test_get_breed_detail_success_returns_breed_detail() async throws {
        let expectedBreed = createMockBreedDTO(id: "123")
        let jsonData = try! JSONEncoder().encode(expectedBreed)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)

        let breed = try await repository.getBreedDetail(id: "123")

        XCTAssertEqual(breed.id, "123")
    }

    func test_get_breed_detail_with_favorite_returns_breed_with_favorite_status() async throws {
        let expectedBreed = createMockBreedDTO(id: "123")
        let jsonData = try! JSONEncoder().encode(expectedBreed)
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, body: jsonData)

        mockLocalStorage.savedBreeds = [createMockLocalBreed(id: "123", isFavorite: true)]

        let breed = try await repository.getBreedDetail(id: "123")

        XCTAssertTrue(breed.isFavourite)
    }

    func test_get_breed_detail_network_error_falls_back_to_cached_breed() async throws {
        mockNetworkService.mockError = NetworkError.noData
        mockLocalStorage.savedBreeds = [createMockLocalBreed(id: "123", isFavorite: false)]

        let breed = try await repository.getBreedDetail(id: "123")

        XCTAssertEqual(breed.id, "123")
    }

    func test_get_breed_detail_network_error_and_no_cache_throws_error() async {
        mockNetworkService.mockError = NetworkError.noData
        mockLocalStorage.savedBreeds = []

        do {
            _ = try await repository.getBreedDetail(id: "123")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }

    func test_set_favorite_to_true_updates_database() async throws {
        try await repository.setFavorite(breedId: "123", isFavorite: true)

        XCTAssertEqual(mockLocalStorage.favoriteUpdates["123"], true)
    }

    func test_set_favorite_to_false_updates_database() async throws {
        try await repository.setFavorite(breedId: "123", isFavorite: false)

        XCTAssertEqual(mockLocalStorage.favoriteUpdates["123"], false)
    }

    func test_get_favorite_breeds_returns_favorited_breeds() async throws {
        mockLocalStorage.savedBreeds = [
            createMockLocalBreed(id: "1", isFavorite: true),
            createMockLocalBreed(id: "2", isFavorite: true),
            createMockLocalBreed(id: "3", isFavorite: false)
        ]

        let favorites = try await repository.getFavoriteBreeds()

        XCTAssertEqual(favorites.count, 2)
        XCTAssertTrue(favorites.allSatisfy { $0.isFavourite })
    }

    func test_get_favorite_breeds_no_favorites_returns_empty_array() async throws {
        mockLocalStorage.savedBreeds = []

        let favorites = try await repository.getFavoriteBreeds()

        XCTAssertTrue(favorites.isEmpty)
    }

    private func createMockBreedDTO(id: String, name: String = "") -> BreedDTO {
        BreedDTO(
            id: id,
            name: name,
            origin: "Test Origin",
            temperament: "Friendly, Playful",
            description: "A lovely breed",
            referenceImageId: "test123",
            image: BreedDTO.ImageDTO(url: "https://example.com/image.jpg")
        )
    }

    private func createMockLocalBreed(id: String, isFavorite: Bool, name: String = "") -> LocalBreed {
        LocalBreed(
            id: id,
            name: name,
            origin: "Test Origin",
            temperament: "Friendly, Playful",
            description: "A lovely breed",
            imageUrl: "https://example.com/image.jpg",
            isFavorite: isFavorite,
            lastUpdated: Date()
        )
    }

    private func createMockBreedsJSON(breeds: [BreedDTO]) -> Data {
        try! JSONEncoder().encode(breeds)
    }
}
