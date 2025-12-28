//
//  AppCoordinatorView.swift
//  Cats
//

import CoreResources
import CoreUI
import SwiftUI

struct AppCoordinatorView: View {

    @StateObject private var navigator = AppNavigator()
    @State private var selectedTab: TabItem = .breeds
    private let localizer = AppDI.localizer()

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.title(localizer: localizer), systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
    }

    @ViewBuilder
    private func tabContent(for tab: TabItem) -> some View {
        NavigationStack(path: $navigator.path) {
            rootView(for: tab)
                .navigationDestination(for: AppRoute.self) { route in
                    navigator.build(route: route)
                        .toolbar(.hidden, for: .tabBar)
                }
        }
    }

    @ViewBuilder
    private func rootView(for tab: TabItem) -> some View {
        switch tab {
        case .breeds:
            navigator.build(route: .breedsList)
        case .favourites:
            navigator.build(route: .favourites)
        }
    }
}
