//
//  CatsApp.swift
//  Cats
//
//  Created by Filipe Pereira on 26/12/2025.
//

import SwiftUI

@main
struct CatsApp: App {

    init() {
        AppDI.setup()
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
        }
    }
}
