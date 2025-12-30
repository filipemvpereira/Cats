//
//  FavouritesViewModelTests.swift
//  FeatureFavouritesTests
//

import CoreBreeds
import XCTest

@testable import FeatureFavourites

@MainActor
final class FavouritesViewModelTests: XCTestCase {

    private var viewModel: FavouritesViewModel!
    private var mockGetFavouritesUseCase: MockGetFavouritesUseCase!
    private var mockUnfavouriteUseCase: MockUnfavouriteUseCase!
    private var mockLocalizer: MockLocalizedResourcesRepository!

    override func setUp() {
        super.setUp()
        mockGetFavouritesUseCase = MockGetFavouritesUseCase()
        mockUnfavouriteUseCase = MockUnfavouriteUseCase()
        mockLocalizer = MockLocalizedResourcesRepository()

        viewModel = FavouritesViewModel(
            getFavouritesUseCase: mockGetFavouritesUseCase,
            unfavouriteUseCase: mockUnfavouriteUseCase,
            localizer: mockLocalizer
        )
    }

    override func tearDown() {
        viewModel = nil
        mockGetFavouritesUseCase = nil
        mockUnfavouriteUseCase = nil
        mockLocalizer = nil
        super.tearDown()
    }

    func test_initialize_success_loads_favourites() async throws {
        mockGetFavouritesUseCase.mockBreeds = [
            createMockBreed(id: "1", isFavourite: true),
            createMockBreed(id: "2", isFavourite: true)
        ]

        await viewModel.initialize()

        guard case .loaded(let items, _) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].id, "1")
        XCTAssertEqual(items[1].id, "2")
    }

    func test_initialize_error_shows_error_state() async {
        mockGetFavouritesUseCase.mockError = NSError(domain: "test", code: 1)

        await viewModel.initialize()

        guard case .error = viewModel.state.content else {
            XCTFail("Expected error state")
            return
        }
    }

    func test_unfavourite_removes_from_list() async throws {
        mockGetFavouritesUseCase.mockBreeds = [
            createMockBreed(id: "1", isFavourite: true),
            createMockBreed(id: "2", isFavourite: true)
        ]

        await viewModel.initialize()

        mockGetFavouritesUseCase.mockBreeds = [
            createMockBreed(id: "2", isFavourite: true)
        ]

        viewModel.unfavourite(breedId: "1")

        try await Task.sleep(for: .milliseconds(100))

        guard case .loaded(let items, _) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(mockUnfavouriteUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUnfavouriteUseCase.lastBreedId, "1")
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].id, "2")
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
