//
//  LocalizedKey.swift
//  CoreResources
//

import Foundation

public enum LocalizedKey {
    // Breeds List
    case breedsListTitle
    case breedsListLoading
    case breedsListSearchPlaceholder
    case breedsListErrorMessage
    case breedsListErrorRetry
    case breedsListEmptyMessage

    // Breed Detail
    case breedDetailLoading
    case breedDetailErrorMessage
    case breedDetailErrorRetry
    case breedDetailSectionOrigin
    case breedDetailSectionTemperament
    case breedDetailSectionDescription

    // Favourites
    case favouritesTitle
    case favouritesLoading
    case favouritesEmptyMessage
    case favouritesErrorMessage
    case favouritesErrorRetry

    // Tab Bar
    case tabBreeds
    case tabFavourites

    var stringKey: String {
        switch self {
        // Breeds List
        case .breedsListTitle: return "breeds_list.title"
        case .breedsListLoading: return "breeds_list.loading"
        case .breedsListSearchPlaceholder: return "breeds_list.search.placeholder"
        case .breedsListErrorMessage: return "breeds_list.error.message"
        case .breedsListErrorRetry: return "breeds_list.error.retry"
        case .breedsListEmptyMessage: return "breeds_list.empty.message"

        // Breed Detail
        case .breedDetailLoading: return "breed_detail.loading"
        case .breedDetailErrorMessage: return "breed_detail.error.message"
        case .breedDetailErrorRetry: return "breed_detail.error.retry"
        case .breedDetailSectionOrigin: return "breed_detail.section.origin"
        case .breedDetailSectionTemperament: return "breed_detail.section.temperament"
        case .breedDetailSectionDescription: return "breed_detail.section.description"

        // Favourites
        case .favouritesTitle: return "favourites.title"
        case .favouritesLoading: return "favourites.loading"
        case .favouritesEmptyMessage: return "favourites.empty.message"
        case .favouritesErrorMessage: return "favourites.error.message"
        case .favouritesErrorRetry: return "favourites.error.retry"

        // Tab Bar
        case .tabBreeds: return "tab.breeds"
        case .tabFavourites: return "tab.favourites"
        }
    }
}
