//
//  TabItem.swift
//  Cats
//

enum TabItem: Int, CaseIterable {
    case breeds
    case favourites

    var title: String {
        switch self {
        case .breeds:
            return "Cat List"
        case .favourites:
            return "Favourites"
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
