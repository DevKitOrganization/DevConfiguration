//
//  ExampleApp.swift
//  App
//
//  Created by Prachi Gauriar on 3/8/26.
//

import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel())
        }
    }
}
