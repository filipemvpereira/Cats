//
//  BreedsListIntegrationTests.swift
//  FeatureBreedsListTests
//

import CoreBreeds
import CoreLocalStorage
import CoreTests
import Network
import XCTest

@testable import FeatureBreedsList

@MainActor
final class BreedsListIntegrationTests: XCTestCase {

    private var viewModel: BreedsListViewModel!
    private var mockNetworkService: MockNetworkService!
    private var mockLocalStorage: MockLocalStorageRepository!
    private var repository: BreedRepository!
    private var getBreedsUseCase: GetBreedsUseCase!
    private var toggleFavouriteUseCase: ToggleFavouriteUseCase!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockLocalStorage = MockLocalStorageRepository()

        repository = BreedRepositoryImpl(
            networkService: mockNetworkService,
            configuration: CoreBreedsConfiguration(baseURL: "https://api.thecatapi.com/v1"),
            decoder: JSONDecoder(),
            localStorage: mockLocalStorage
        )

        getBreedsUseCase = GetBreedsUseCaseImpl(repository: repository)
        toggleFavouriteUseCase = ToggleFavouriteUseCaseImpl(repository: repository)

        viewModel = BreedsListViewModel(
            getBreedsUseCase: getBreedsUseCase,
            toggleFavouriteUseCase: toggleFavouriteUseCase,
            localizer: MockLocalizedResourcesRepository()
        )
    }

    override func tearDown() {
        viewModel = nil
        getBreedsUseCase = nil
        toggleFavouriteUseCase = nil
        repository = nil
        mockNetworkService = nil
        mockLocalStorage = nil
        super.tearDown()
    }

    func test_end_to_end_load_breeds_success() async throws {
        let jsonString = """
        [
            {
                "id": "1",
                "name": "Abyssinian",
                "origin": "Egypt",
                "temperament": "Active",
                "description": "A lovely breed",
                "reference_image_id": "img1"
            },
            {
                "id": "2",
                "name": "Bengal",
                "origin": "United States",
                "temperament": "Alert",
                "description": "Another lovely breed",
                "reference_image_id": "img2"
            }
        ]
        """
        mockNetworkService.mockResponse = NetworkResponse(
            statusCode: 200,
            body: jsonString.data(using: .utf8)!
        )

        await viewModel.initialize()

        guard case .loaded(let items, _, _, _, _) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].id, "1")
        XCTAssertEqual(items[0].name, "Abyssinian")
        XCTAssertEqual(items[1].id, "2")
        XCTAssertEqual(items[1].name, "Bengal")
        XCTAssertEqual(mockLocalStorage.savedBreeds.count, 2)
    }

    func test_end_to_end_load_breeds_network_error_falls_back_to_cache() async throws {
        mockLocalStorage.savedBreeds = [
            LocalBreed(
                id: "1",
                name: "Cached Breed",
                origin: "Test",
                temperament: "Friendly",
                description: "Test",
                imageUrl: nil,
                isFavorite: false,
                lastUpdated: Date()
            )
        ]
        mockNetworkService.mockError = NetworkError.noData

        await viewModel.initialize()

        guard case .loaded(let items, _, _, _, _) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].id, "1")
        XCTAssertEqual(items[0].name, "Cached Breed")
    }

    func test_end_to_end_toggle_favourite_updates_ui_and_persists() async throws {
        let jsonString = """
        [
            {
                "id": "1",
                "name": "Test Breed",
                "origin": "Test Origin",
                "temperament": "Friendly",
                "description": "A test breed",
                "reference_image_id": "test123"
            }
        ]
        """
        mockNetworkService.mockResponse = NetworkResponse(
            statusCode: 200,
            body: jsonString.data(using: .utf8)!
        )

        await viewModel.initialize()

        guard case .loaded(var items, _, _, _, _) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertFalse(items[0].isFavourite)

        viewModel.toggleFavourite(breedId: "1")

        try await Task.sleep(for: .milliseconds(100))

        guard case .loaded(let updatedItems, _, _, _, _) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertTrue(updatedItems[0].isFavourite)
        XCTAssertEqual(mockLocalStorage.favoriteUpdates["1"], true)
    }

    func test_end_to_end_search_loads_from_network() async throws {
        let jsonString = """
        [
            {
                "id": "1",
                "name": "Bengal",
                "origin": "United States",
                "temperament": "Alert",
                "description": "Bengal cat",
                "reference_image_id": "bengal123"
            }
        ]
        """
        mockNetworkService.mockResponse = NetworkResponse(
            statusCode: 200,
            body: jsonString.data(using: .utf8)!
        )

        await viewModel.search(query: "bengal")

        guard case .loaded(let items, let searchText, _, _, _) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].name, "Bengal")
        XCTAssertEqual(searchText, "bengal")
    }
}
