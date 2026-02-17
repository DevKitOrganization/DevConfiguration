# MVVM for SwiftUI

SwiftUI is a great way to build great looking apps for Apple platforms. Unfortunately, Apple’s
example code doesn’t demonstrate good architecture. In this doc, we’ll outline some of our thoughts
on how to use the MVVM (model-view-view model) architecture in SwiftUI applications.


## Architectural Goals

Before we begin, let’s discuss our goals. We’re interested in writing code that is:

  - *Correct*: the code should implement requirements with as few bugs as possible.
  - *Robust*: the code should handle unexpected situations gracefully.
  - *Adaptable*: within reason, we should be able to adapt our code for use in situations that we
    didn’t know about when we originally wrote it.
  - *Maintainable*: code is more often read than written, and thus should be easy to understand and
    reason about. It should be relatively easy to make a change without introducing bugs.
  - *Testable*: building correct, adaptable, and maintainable code is very difficult without a large
    suite of automated tests. Thus we need to architect our code so that it is easy to test using
    standard unit and integration testing techniques.
  - *Portable*: while we primarily write apps that target iOS, that may not always be the case. We
    may support other Apple platforms—tvOS, watchOS, or macOS—or we may ship different kinds of
    apps, e.g., iMessage extensions or command-line tools for testing. Our code should be portable
    enough to enable these use cases.
  - *Efficient*: our code should always aim to efficiently use a device’s resources. We should avoid
    using any more CPU, memory, battery, or network data allocations than is needed.

Any architectural pattern that we use should support these goals. The portability goal in particular
is one that the iOS community doesn’t often emphasize, but that we believe is very important. When
reasoning about MVVM, you will make better architectural decisions if you don’t make assumptions
about the types of UIs your code will support. Keep that in mind as you read this document.

## A Quick Overview of MVVM

It’s helpful to do a quick refresher of MVVM to make sure we all understand the roles of different
components in the architecture.

  - *Models* represent your application’s concepts and operations. That is, they “model” the problem
    domain of your app, independent of any particular UI representation. The model layer is where
    the real work of your app happens. Because it’s independent of the UI, it should be largely
    reusable and portable. For example, the business logic involved in performing a restaurant
    search, fetching a menu, and adding a menu item to a cart should work the same, regardless of
    what your UI looks like.
  - *Views* represent the user interface of your application. While this obviously includes
    traditional parts of your UI, like buttons and screens, it also includes non-visual UI, like
    speech and textual interfaces. It could go so far as to include a scripting interface since that
    is just a way to interface with your application. The big idea here is that the views present
    information to users and receive user input. They provide an interface for users to interact
    with your model layer and reflect application state.
  - *View Models* mediate between models and views. They have properties for view state, which the
    view uses to render its information. When a view model receives a change from the model layer,
    it translates the change into a view state change, which triggers a re-rendering of the view.
    View models also have functions that are used by the view to trigger business logic in response
    to user input.

## SwiftUI and MVVM

The core challenge with SwiftUI is that views are very difficult to test. They are structs that
produce a view body using a declarative DSL, making them hard to test and unsuitable for complex
logic. As such, we must make logic inside of views simple, with minimal branching, data
transformations, etc. View models should be the central location for view logic. Models in MVVM are
no different than models in (correct) MVC: they should contain all UI-agnostic logic.

In SwiftUI, a view has a reference to one or more view models, which in turn have references to one
or more models. View models do not have a reference to their views, and models do not have a
reference to their view models. To propagate information from a model to a view model, models can
either return values from properties or functions (manual propagation) or publish them via Combine
Publishers, Async Streams, Notifications, or Delegate protocols (automatic propagation). View
models propagate information to views almost entirely through published properties. View models
should very rarely have functions exposed to views that return a value.

Views use generic parameters to specify their view model types, avoiding existential types for
better performance and type safety. Child view models within view modeling protocols are represented
as associated types rather than protocol existentials.

In our SwiftUI app architecture, each view is composed of three related types: a \*View, a
\*ViewModeling, and a \*ViewModel. The \*ViewModel type will often have either a nested Dependencies
struct or nested DependencyProviding and DependencyProvider types. See our
[Dependency Injection](DependencyInjection.md) guide for more details.

  - *View*: The view code. The view has no business logic and simply reflects the state of its view
    model, which is a generic parameter named `ViewModel` that conforms to the \*ViewModeling protocol.
  - *ViewModeling*: A protocol that contains the minimal interface for the \*View to perform its
    function. Each contains properties that are used to store the view’s state, as well as enums
    that govern the view’s modals and alerts.

    All properties of a view are either simple data types with no behavior or associated types that
    represent child view models. Any child view models are defined as associated types (named
    `Some*ViewModel`) that conform to their corresponding `*ViewModeling` protocol, rather than
    using existential types.

    Functions defined on the view model typically take no parameters. These functions either perform
    some action using the view model’s underlying model and/or update a state variable to, e.g.,
    show a modal or an alert.

    Where possible, these protocols and their supporting types are modeled such that impossible
    states do not compile. That is, if a button should only appear when a view is in a particular
    state, that action function for that button should only be available when the view is in that
    state. This can be achieved using algebraic data types (enums with associated values).
  - *ViewModel*: A concrete implementation of the \*ViewModeling protocol. Often, these view models
    have delegate protocols that are used to communicate changes between parent and child views
    models.
