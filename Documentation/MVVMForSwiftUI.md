# MVVM for SwiftUI

This document defines the MVVM (model-view-view model) architecture pattern we use to write
SwiftUI code in the DevConfiguration codebase. For more background on this MVVM pattern, see
[MVVMForSwiftUIBackground.md](MVVMForSwiftUIBackground.md).


## Overview

Our SwiftUI architecture is composed of thrre related types: a \*View, a \*ViewModeling, a
and \*ViewModel. Screens in the app will often have each of these three types, though it 
depends on the screen’s complexity and requirements. Additional types for dependency 
injection are also common.

The following sections will demonstrate the types we would create for a "ItemList" screen:


### ItemListViewModeling

We begin by defining a protocol that describes the minimal interface for the view to perform its
function. In this case, we want the view to display a list of items. We use the `Observable`
protocol to allow the view to react to changes in the view model.

    @MainActor
    protocol ItemListViewModeling: Observable {
        var items: [ListItem] { get }
        func addRow()
    }


### ItemListView

Next we define the view, which has no business logic and simply reflects the state of its single
property, `viewModel`. The view uses a generic parameter named `ViewModel` that conforms to the
`ItemListViewModeling` protocol. The `viewModel` property is marked as `@State` so that the view
can react to changes in the view model.

    struct ItemListView<ViewModel>: View where ViewModel: ItemListViewModeling {
        @State var viewModel: ViewModel

        var body: some View {
            List {
                ForEach(viewModel.items) { item in
                    Text(item.name)
                }
            }
        }
    }


### ItemListViewModel

Finally, we create a concrete representation of our view model by implementing the
`ItemListViewModeling` protocol. This is the type that will be used by the view to display the
list of items.

**Note**: We must declare our view model as `@Observable` to enable Swift’s property observation
mechanism. Protocols may declare `Observable` conformance as a convenience for consuming code, but
it does not confer any special behavior on conforming type itself.

    @Observable
    final class ItemListViewModel: ItemListViewModeling {
        var items: [ListItem]
    }


### ItemListViewModelDependencyProviding/Provider

If the view model requires dependencies to perform its function, we follow the guidance in the
[Dependency Injection](DependencyInjection.md) guide. In this case, the view model requires a data
source to fetch the list of items. The Dependencies Struct pattern would be appropriate for this
case.

    @Observable
    final class ItemListViewModel: ItemListViewModeling {
        struct Dependencies {
            let itemFetcher: any ItemFetching
        }

        var items: [ListItem]

        init(dependencies: Dependencies) {
            self.items = dependencies.itemFetcher.fetchItems()
        }
    }


### Putting It All Together

Typically, a parent view is responsible for creating the child view, using the parent view model to
create the child view model. The parent view model creates the child view model by instantiating it
with a dependency provider.

We see this below with the `HomeView`/`HomeViewModel` pair.

    @MainActor
    protocol HomeViewModeling: Observable {
        associatedtype SomeItemListViewModel: ItemListViewModeling
        func makeItemListViewModel() -> SomeItemListViewModel
    }


    @Observable
    struct HomeViewModel: HomeViewModeling {
        func makeItemListViewModel() -> ItemListViewModel {
            return ItemListViewModel(
                dependencies: .init(
                    itemFetcher: StandardItemFetcher()
                )
            )
        }
    }


    struct HomeView<ViewModel>: View where ViewModel: HomeViewModeling {
        @State var viewModel: ViewModel

        var body: some View {
            ItemListView(viewModel: viewModel.makeItemListViewModel())
        }
    }


### Making State Changes

View models are responsible for managing changes to the application’s state. Typically, they do so
by providing parameterless functions that the view can call to trigger state changes.

    @Observable
    final class ItemListViewModel: ItemListViewModeling {
        var items: [ListItem]


        init(items: [ListItem]) {
            self.items = items
        }


        func addRow() {
            items.append(ListItem(name: "New Item"))
        }
    }

The view can then call the `addRow` function to add a new row to the list.

    struct ItemListView<ViewModel>: View where ViewModel: ItemListViewModeling {
        @State var viewModel: ViewModel


        var body: some View {
            List {
                ForEach(viewModel.items) { item in
                    Text(item.name)
                }
            }
            .toolbar {
                Button {
                    viewModel.addRow()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }


## Misc. Instructions for AI

### Import Requirements

  - Always include `import SwiftUI` in view files.
