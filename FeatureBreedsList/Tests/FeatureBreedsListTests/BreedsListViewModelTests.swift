//
//  BreedsListViewModelTests.swift
//  FeatureBreedsListTests
//

import CoreBreeds
import XCTest

@testable import FeatureBreedsList

@MainActor
final class BreedsListViewModelTests: XCTestCase {

    private var viewModel: BreedsListViewModel!
    private var mockGetBreedsUseCase: MockGetBreedsUseCase!
    private var mockToggleFavouriteUseCase: MockToggleFavouriteUseCase!
    private var mockLocalizer: MockLocalizedResourcesRepository!

    override func setUp() {
        super.setUp()
        mockGetBreedsUseCase = MockGetBreedsUseCase()
        mockToggleFavouriteUseCase = MockToggleFavouriteUseCase()
        mockLocalizer = MockLocalizedResourcesRepository()

        viewModel = BreedsListViewModel(
            getBreedsUseCase: mockGetBreedsUseCase,
            toggleFavouriteUseCase: mockToggleFavouriteUseCase,
            localizer: mockLocalizer
        )
    }

    override func tearDown() {
        viewModel = nil
        mockGetBreedsUseCase = nil
        mockToggleFavouriteUseCase = nil
        mockLocalizer = nil
        super.tearDown()
    }

    func test_initialize_success_loads_breeds() async throws {
        mockGetBreedsUseCase.mockBreeds = [
            createMockBreed(id: "1"),
            createMockBreed(id: "2")
        ]

        await viewModel.initialize()

        guard case .loaded(let items, _, _, _, _) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].id, "1")
        XCTAssertEqual(items[1].id, "2")
    }

    func test_initialize_error_shows_error_state() async {
        mockGetBreedsUseCase.mockError = NSError(domain: "test", code: 1)

        await viewModel.initialize()

        guard case .error = viewModel.state.content else {
            XCTFail("Expected error state")
            return
        }
    }

    func test_toggle_favourite_updates_breed_in_list() async throws {
        mockGetBreedsUseCase.mockBreeds = [
            createMockBreed(id: "1", isFavourite: false)
        ]

        await viewModel.initialize()

        viewModel.toggleFavourite(breedId: "1")

        try await Task.sleep(for: .milliseconds(100))

        guard case .loaded(let items, _, _, _, _) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(mockToggleFavouriteUseCase.executeCallCount, 1)
        XCTAssertEqual(mockToggleFavouriteUseCase.lastBreedId, "1")
        XCTAssertEqual(items[0].isFavourite, true)
    }

    private func createMockBreed(id: String, isFavourite: Bool = false) -> Breed {
        Breed(
            id: id,
            name: "Test Breed",
            origin: "Test Origin",
            temperament: "Friendly",
            description: "Test Description",
            imageUrl: nil,
            isFavourite: isFavourite
        )
    }
}
