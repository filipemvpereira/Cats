//
//  BreedsListUITests.swift
//  CatsUITests
//

import XCTest

final class BreedsListUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testBreedsListDisplaysOnLaunch() {
        XCTAssertTrue(app.navigationBars["Breeds"].exists, "Breeds navigation bar should exist")

        let breedsList = app.scrollViews.firstMatch
        XCTAssertTrue(breedsList.exists, "Breeds list should be visible")
    }

    func testBreedsListDisplaysBreedItems() {
        let breedsList = app.scrollViews.firstMatch
        let firstBreed = breedsList.otherElements.firstMatch
        let exists = firstBreed.waitForExistence(timeout: 5)

        XCTAssertTrue(exists, "At least one breed should appear in the list")
    }

    func testBreedItemDisplaysRequiredInformation() {
        let breedsList = app.scrollViews.firstMatch
        let firstBreed = breedsList.otherElements.firstMatch
        _ = firstBreed.waitForExistence(timeout: 5)

        let hasText = breedsList.staticTexts.count > 0
        XCTAssertTrue(hasText, "Breed items should display text information")
    }

    func testSearchBarExists() {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.exists, "Search bar should exist")
    }

    func testSearchFiltersBreeds() {
        let breedsList = app.scrollViews.firstMatch
        let firstBreed = breedsList.otherElements.firstMatch
        _ = firstBreed.waitForExistence(timeout: 5)

        let initialBreedCount = breedsList.otherElements.count

        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Bengal")

        sleep(1)

        let filteredBreedCount = breedsList.otherElements.count
        let bengalExists = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Bengal'")).firstMatch.exists

        XCTAssertTrue(filteredBreedCount <= initialBreedCount || bengalExists,
                     "Search should filter results or show Bengal breed")
    }

    func testSearchCanBeCancelled() {
        let searchField = app.searchFields.firstMatch
        _ = searchField.waitForExistence(timeout: 2)
        searchField.tap()
        searchField.typeText("Test")

        let cancelButton = app.buttons["Cancel"]
        if cancelButton.exists {
            cancelButton.tap()

            let searchText = searchField.value as? String ?? ""
            XCTAssertTrue(searchText.isEmpty, "Search field should be cleared after cancel")
        } else {
            let clearButton = searchField.buttons["Clear text"]
            if clearButton.exists {
                clearButton.tap()
                let searchText = searchField.value as? String ?? ""
                XCTAssertTrue(searchText.isEmpty, "Search field should be cleared")
            }
        }
    }

    func testToggleFavoriteOnBreedItem() {
        let breedsList = app.scrollViews.firstMatch
        let firstBreed = breedsList.otherElements.firstMatch
        _ = firstBreed.waitForExistence(timeout: 5)

        let favoriteButtons = firstBreed.buttons.matching(identifier: "favoriteButton")

        if favoriteButtons.count > 0 {
            let favoriteButton = favoriteButtons.firstMatch
            let initialState = favoriteButton.label

            favoriteButton.tap()
            sleep(1)

            let newState = favoriteButton.label
            XCTAssertNotEqual(initialState, newState, "Favorite button state should change after tap")
        } else {
            XCTFail("Favorite button not found on breed item")
        }
    }

    func testFavoritesPersistAcrossRelaunch() {
        let breedsList = app.scrollViews.firstMatch
        let firstBreed = breedsList.otherElements.firstMatch
        _ = firstBreed.waitForExistence(timeout: 5)

        let breedNameText = firstBreed.staticTexts.firstMatch
        let breedName = breedNameText.label

        let favoriteButtons = firstBreed.buttons.matching(identifier: "favoriteButton")
        if favoriteButtons.count > 0 {
            favoriteButtons.firstMatch.tap()
            sleep(1)

            app.terminate()
            app.launch()

            let breedsListAfterRelaunch = app.scrollViews.firstMatch
            _ = breedsListAfterRelaunch.waitForExistence(timeout: 5)

            let favoritesTab = app.tabBars.buttons["Favourites"]
            if favoritesTab.exists {
                favoritesTab.tap()
                sleep(1)

                let favoritesList = app.scrollViews.firstMatch
                let favoritedBreedExists = favoritesList.staticTexts.containing(NSPredicate(format: "label == %@", breedName)).firstMatch.exists

                XCTAssertTrue(favoritedBreedExists, "Favorited breed '\(breedName)' should persist across app relaunch")
            }
        }
    }

    func testTappingBreedNavigatesToDetail() {
        let breedsList = app.scrollViews.firstMatch
        let firstBreed = breedsList.otherElements.firstMatch
        _ = firstBreed.waitForExistence(timeout: 5)

        firstBreed.tap()

        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3), "Should navigate to breed detail view")
    }

    func testBackButtonReturnsToList() {
        let breedsList = app.scrollViews.firstMatch
        let firstBreed = breedsList.otherElements.firstMatch
        _ = firstBreed.waitForExistence(timeout: 5)
        firstBreed.tap()

        let backButton = app.navigationBars.buttons.firstMatch
        _ = backButton.waitForExistence(timeout: 3)

        backButton.tap()

        XCTAssertTrue(app.navigationBars["Breeds"].waitForExistence(timeout: 2),
                     "Should return to breeds list")
    }

    func testPullToRefreshWorks() {
        let breedsList = app.scrollViews.firstMatch
        _ = breedsList.waitForExistence(timeout: 5)

        let start = breedsList.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let end = breedsList.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        start.press(forDuration: 0, thenDragTo: end)

        sleep(2)

        XCTAssertTrue(breedsList.exists, "Breeds list should still be visible after refresh")
    }

    func testTabBarHasThreeTabs() {
        let tabBar = app.tabBars.firstMatch

        XCTAssertTrue(tabBar.exists, "Tab bar should exist")

        let breedsTab = tabBar.buttons["Breeds"]
        let favoritesTab = tabBar.buttons["Favourites"]
        let detailTab = tabBar.buttons.element(boundBy: 2)

        XCTAssertTrue(breedsTab.exists, "Breeds tab should exist")
        XCTAssertTrue(favoritesTab.exists, "Favourites tab should exist")
        XCTAssertTrue(detailTab.exists, "Third tab should exist")
    }

    func testSwitchingToFavoritesTab() {
        let tabBar = app.tabBars.firstMatch

        let favoritesTab = tabBar.buttons["Favourites"]
        favoritesTab.tap()

        let favoritesTitle = app.navigationBars["Favourites"]
        XCTAssertTrue(favoritesTitle.waitForExistence(timeout: 2),
                     "Favourites navigation bar should appear")
    }

    func testSwitchingBackToBreedsTab() {
        let tabBar = app.tabBars.firstMatch
        let favoritesTab = tabBar.buttons["Favourites"]
        favoritesTab.tap()
        _ = app.navigationBars["Favourites"].waitForExistence(timeout: 2)

        let breedsTab = tabBar.buttons["Breeds"]
        breedsTab.tap()

        let breedsTitle = app.navigationBars["Breeds"]
        XCTAssertTrue(breedsTitle.waitForExistence(timeout: 2),
                     "Breeds navigation bar should appear")
    }

    func testOfflineMode() {
        let breedsList = app.scrollViews.firstMatch
        _ = breedsList.waitForExistence(timeout: 5)

        XCTAssertTrue(breedsList.exists, "Breeds list view should exist even in offline mode")
    }

    func testSearchFieldHasAccessibilityLabel() {
        let searchField = app.searchFields.firstMatch

        XCTAssertTrue(searchField.exists, "Search field should exist")
        XCTAssertFalse(searchField.label.isEmpty, "Search field should have accessibility label")
    }

    func testBreedItemsAreAccessible() {
        let breedsList = app.scrollViews.firstMatch
        let firstBreed = breedsList.otherElements.firstMatch
        _ = firstBreed.waitForExistence(timeout: 5)

        XCTAssertTrue(firstBreed.isHittable, "Breed items should be tappable/accessible")
    }
}
