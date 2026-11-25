---
description: The View/ViewModeling/ViewModel MVVM pattern used for SwiftUI screens in this codebase
read-when: Creating or reviewing a new SwiftUI screen’s View, ViewModeling protocol, and ViewModel
---

# MVVM for SwiftUI

This document defines the MVVM (model-view-view model) architecture pattern we use to write
SwiftUI code in the codebase. For more background on this MVVM pattern, see
[MVVMForSwiftUIBackground.md](MVVMForSwiftUIBackground.md).


## Overview

Our SwiftUI architecture is composed of three related types: a \*View, a \*ViewModeling, and a
\*ViewModel. Screens in the app will often have each of these three types, though it
depends on the screen’s complexity and requirements. Additional types for dependency
injection are also common.

The following sections will demonstrate the types we would create for an “ItemList” screen:


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
`ItemListViewModeling` protocol. The view holds `viewModel` with `let` because its parent owns it;
see [Who Owns the View Model](#who-owns-the-view-model).

    struct ItemListView<ViewModel>: View where ViewModel: ItemListViewModeling {
        let viewModel: ViewModel

        var body: some View {
            List {
                ForEach(viewModel.items) { item in
                    Text(item.name)
                }
            }
        }
    }


### Who Owns the View Model

How a view holds its view model depends on who owns it and what the view does with it:

  - **`@State`** when the view owns its view model.
  - **`@Bindable var`** when a parent owns it and the view needs bindings to its properties. The
    `*ViewModeling` protocol must then be `AnyObject, Observable`.
  - **A plain `let`** when a parent owns it and the view only reads it or passes it along. The
    view still updates when a property its `body` reads changes. Observation tracks those reads
    without a property wrapper.

`@State` keeps the first value it’s given and ignores values passed through `init` on later
rebuilds. A view whose parent may replace its view model must not hold it in `@State`. Since
Xcode 27, `@State` evaluates a default value at its declaration only once. A value passed through
`init` is still built on every rebuild and then discarded.


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

A parent view model provides its child view models. It can create one up front or when it’s
needed, such as when the person navigates somewhere, but it creates each one once and keeps it
while it’s shown. A view’s `body` never creates a view model, because `body` runs every time the
view is rebuilt. In the example below, `HomeViewModel` creates its item list view model up front.

    @MainActor
    protocol HomeViewModeling: Observable {
        associatedtype SomeItemListViewModel: ItemListViewModeling
        var itemListViewModel: SomeItemListViewModel { get }
    }


    @Observable
    final class HomeViewModel: HomeViewModeling {
        let itemListViewModel: ItemListViewModel


        init() {
            self.itemListViewModel = ItemListViewModel(
                dependencies: .init(itemFetcher: StandardItemFetcher())
            )
        }
    }


    struct HomeView<ViewModel>: View where ViewModel: HomeViewModeling {
        @State var viewModel: ViewModel

        var body: some View {
            ItemListView(viewModel: viewModel.itemListViewModel)
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
        let viewModel: ViewModel


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

### File Organization

When creating MVVM files, place them in a dedicated directory structure under the appropriate
parent folder.

### Import Requirements

  - Always include `import SwiftUI` in view files.

### ViewModeling Protocol Conventions

  - Group properties together logically (e.g. by the content they represent, or by the feature
    area they support), and list functions after all properties.
  - Skip doc comments on `*ViewModeling` properties by default — the property name should carry
    the meaning. Only add one when the property’s behavior is genuinely unusual or requires
    special handling that a reader wouldn’t otherwise expect (e.g. a flag that exists specifically
    to drive a delayed side effect, or a value whose invalidation rule isn’t obvious from its
    name).

### ViewModel Property Organization

Declare a view model’s stored properties in blank-line-separated groups, ordered from the most
externally visible to the most internal:

  1. **Dependencies and configuration**: `dependencies` and any navigation data or other
     parameters the view model was created with.
  2. **`*ViewModeling` state**: the `private(set)` properties that satisfy the protocol.
  3. **Internal state**: private properties, subdivided by function, one group per concern.

Within the internal groups, keep a property next to the others that serve the same purpose. For
example, a feed and its renderer sit together, and a task sits with its cancellation identifier and
the objects it operates on. Don’t order by access level or by `let` versus `var`.

    @Observable
    final class ExampleViewModel: ExampleViewModeling {
        let dependencies: Dependencies
        let navigationData: ExampleNavigationData

        private(set) var error: StandardContentErrorViewModel?
        private(set) var isRefreshing = false

        private var feed: Feed?
        private(set) var moduleListRenderer: ExampleModuleListRenderer?

        let loadingGroup = ExecutionGroup()
        private var loadTask: Task<Void, Never>?
    }
