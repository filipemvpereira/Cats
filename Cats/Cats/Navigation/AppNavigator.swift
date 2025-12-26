//
//  AppNavigator.swift
//  Cats
//

import Combine
import CoreUI
import SwiftUI

@MainActor
final class AppNavigator: Navigator {

    @Published var path = NavigationPath()

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }

    @ViewBuilder
    func build(route: AppRoute) -> some View {
        switch route {
        case .breedsList:
            AppDI.breedsListView(navigator: self)

        case .favourites:
            AppDI.favouritesView(navigator: self)

        case .breedDetail(let id):
            AppDI.breedDetailView(id: id, navigator: self)
        }
    }
}
