//
//  ContentView.swift
//  App
//
//  Created by Prachi Gauriar on 3/8/26.
//

import DevConfiguration
import SwiftUI

struct ContentView: View {
    @State var viewModel: ContentViewModel
    @State var isPresentingConfigEditor: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(viewModel.variableValues)
                    .padding()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit Config", systemImage: "gear") {
                        isPresentingConfigEditor = true
                    }
                }
            }
            .sheet(isPresented: $isPresentingConfigEditor) {
                ConfigVariableEditor(
                    reader: viewModel.configVariableReader
                ) {
                    Section("First Section") {
                        Button("Do something") {
                            print("Did something!")
                        }
                    }

                    Section("Second Section") {
                        Button("Do something else", role: .destructive) {
                            print("Did something else!")
                        }
                    }
                } dismiss: { variables in
                    print(variables)
                    isPresentingConfigEditor = false
                }
            }
        }
    }
}

#Preview {
    ContentView(viewModel: ContentViewModel())
}
