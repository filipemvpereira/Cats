//
//  BreedDetailViewModelTests.swift
//  FeatureBreedDetailTests
//

import CoreBreeds
import XCTest

@testable import FeatureBreedDetail

@MainActor
final class BreedDetailViewModelTests: XCTestCase {

    private var viewModel: BreedDetailViewModel!
    private var mockGetBreedDetailUseCase: MockGetBreedDetailUseCase!
    private var mockToggleFavouriteUseCase: MockToggleFavouriteUseCase!
    private var mockLocalizer: MockLocalizedResourcesRepository!

    override func setUp() {
        super.setUp()
        mockGetBreedDetailUseCase = MockGetBreedDetailUseCase()
        mockToggleFavouriteUseCase = MockToggleFavouriteUseCase()
        mockLocalizer = MockLocalizedResourcesRepository()

        viewModel = BreedDetailViewModel(
            breedId: "test-123",
            getBreedDetailUseCase: mockGetBreedDetailUseCase,
            toggleFavouriteUseCase: mockToggleFavouriteUseCase,
            localizer: mockLocalizer
        )
    }

    override func tearDown() {
        viewModel = nil
        mockGetBreedDetailUseCase = nil
        mockToggleFavouriteUseCase = nil
        mockLocalizer = nil
        super.tearDown()
    }

    func test_initialize_success_loads_breed_detail() async throws {
        mockGetBreedDetailUseCase.mockBreed = createMockBreed(id: "test-123")

        await viewModel.initialize()

        guard case .loaded(let detail) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(detail.id, "test-123")
        XCTAssertEqual(mockGetBreedDetailUseCase.executeCallCount, 1)
    }

    func test_initialize_error_shows_error_state() async {
        mockGetBreedDetailUseCase.mockError = NSError(domain: "test", code: 1)

        await viewModel.initialize()

        guard case .error = viewModel.state.content else {
            XCTFail("Expected error state")
            return
        }
    }

    func test_toggle_favourite_updates_favourite_status() async throws {
        mockGetBreedDetailUseCase.mockBreed = createMockBreed(id: "test-123", isFavourite: false)

        await viewModel.initialize()

        viewModel.toggleFavourite()

        try await Task.sleep(for: .milliseconds(100))

        guard case .loaded(let detail) = viewModel.state.content else {
            XCTFail("Expected loaded state")
            return
        }

        XCTAssertEqual(mockToggleFavouriteUseCase.executeCallCount, 1)
        XCTAssertEqual(mockToggleFavouriteUseCase.lastBreedId, "test-123")
        XCTAssertEqual(detail.isFavourite, true)
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
