//
//  FavouritesViewState.swift
//  FeatureFavourites
//

import Foundation

struct FavouritesViewState {
    let title: String
    let content: Content

    init(title: String, content: Content) {
        self.title = title
        self.content = content
    }

     enum Content: Equatable {
        case loading(String)
        case loaded([Item], emptyMessage: String)
        case error(String, retryText: String)
    }

     struct Item: Identifiable, Hashable {
         let id: String
         let name: String
         let origin: String
         let imageUrl: String?
         let isFavourite: Bool

         init(id: String, name: String, origin: String, imageUrl: String?, isFavourite: Bool) {
            self.id = id
            self.name = name
            self.origin = origin
            self.imageUrl = imageUrl
            self.isFavourite = isFavourite
        }
    }
}
