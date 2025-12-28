//
//  TabItem.swift
//  Cats
//

import CoreResources

enum TabItem: Int, CaseIterable {
    case breeds
    case favourites

    func title(localizer: LocalizedResourcesRepository) -> String {
        switch self {
        case .breeds:
            return localizer.getString(.tabBreeds)
        case .favourites:
            return localizer.getString(.tabFavourites)
        }
    }

    var icon: String {
        switch self {
        case .breeds:
            return "list.bullet"
        case .favourites:
            return "star.fill"
        }
    }
}
