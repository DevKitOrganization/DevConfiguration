# Testing Guidelines for Claude Code

This file provides specific guidance for Claude Code when creating, updating, and maintaining
tests in this repository.

## Swift Testing Framework

**IMPORTANT**: This project uses **Swift Testing framework**, NOT XCTest. Do not apply XCTest
patterns or conventions.

### Key Differences from XCTest

  - **Use `@Test` attribute** instead of function name conventions
  - **Use `#expect()` and `#require()`** instead of `XCTAssert*()` functions
  - **Use `#expect(throws:)`** for testing error conditions instead of `XCTAssertThrows`
  - **No "test" prefixes** required on function names
  - **Struct-based test organization** instead of class-based

### Test Naming Conventions

  - **No "test" prefixes**: Swift Testing doesn't require "test" prefixes for function names
  - **Descriptive names**: Use clear, descriptive names like `initialLoadingState()` instead of
    `testInitialLoadingState()`
  - **Protocol-specific naming**: For protocols with concrete implementations, name tests after
    the concrete type (e.g., `StandardAuthenticationRemoteNotificationHandlerTests`)

### Unit Test Structure Conventions

Unit tests typically have 3 portions; setup, exercise, and expect.

  - **Setup**: Create the inputs or mocks necessary to exercise the unit under test
  - **Exercise**: Exercise the unit under test, usually by invoking a function using the inputs
    prepared during "Setup".
  - **Expect**: Expect one or more results to be true, using Swift Testing expressions.
  - **IMPORTANT**: Each test should have exactly ONE unit-under-test. Only mark the invocation of
    the unit-under-test with an "// exercise" comment. Additional function calls during setup or
    verification should use "// set up" or "// expect" comments respectively.
  - The beginning of each step should be clearly marked with a code comment, like:
      - // set up the test by preparing a mock authenticator
      - // exercise the test by initializing the data source
      - // expect that the loadUser stub is invoked once
  - If two sections overlap, only mention the most relevant information.

### Mock Testing Strategy

  - **Focus on verification**: Test that mocks are called correctly, not custom mock
    implementations
  - **Verify parameter passing**: Always check that mocks receive expected arguments, not just
    call counts
  - **Use standard mocks**: All tests with injectable dependencies should use the same mock
    types, not custom mock implementations.
  - **Always mock dependencies**: Even when not testing the mocked behavior, always use mocks
    to supply dependencies to objects under test.
  - **Minimal Stubbing**: Only stub functions that are relevant to the code under test, or
    required for the test to execute successfully.
      - Do *NOT* leave comments when stubs are omitted because they are irrelevant.

### ThrowingStub Usage

**CRITICAL**: DevTesting's `ThrowingStub` has very specific initialization patterns that
differ from regular `Stub`. Using incorrect initializers will cause compilation errors.

#### Correct ThrowingStub Patterns:

    // For success cases:
    ThrowingStub(defaultReturnValue: value)

    // For error cases:
    ThrowingStub(defaultError: error)

    // For void return types that not throw:
    ThrowingStub(defaultError: nil)

#### Common Mistakes to Avoid:

  - ❌ `ThrowingStub(throwingError: error)` - This doesn't exist
  - ❌ `ThrowingStub()` with separate configuration - Must provide default in initializer

### Mock Object Patterns

Follow established patterns from `@Documentation/TestMocks.md`:

  - **Stub-based architecture**: Use `Stub<Input, Output>` and `ThrowingStub<Input, Output, Error>`
  - **Thread safety**: Mark stub properties with `nonisolated(unsafe)`
  - **Protocol conformance**: Mock the protocol, not the concrete implementation
  - **Argument structures**: For complex parameters, create dedicated argument structures

Example mock structure:

    final class MockProtocolName: ProtocolName {
        nonisolated(unsafe) var functionStub: Stub<InputType, OutputType>!

        func function(input: InputType) -> OutputType {
            functionStub(input)
        }

        nonisolated(unsafe) var throwingMethodStub: ThrowingStub<InputType, OutputType, any Error>!

        func throwingMethod(input: InputType) throws -> OutputType {
            try throwingMethodStub(input)
        }
    }


### Random Value Generation with Swift Testing

**IMPORTANT**: Swift Testing uses immutable test structs, but `RandomValueGenerating` requires
`mutating` functions. This creates a specific pattern that must be followed.

#### Correct Pattern for Random Value Generation:

    @MainActor
    struct MyTests: RandomValueGenerating {
        var randomNumberGenerator = makeRandomNumberGenerator()

        @Test
        mutating func myTest() throws {
            let randomValue = randomAlphanumericString()
            // ... test logic
        }
    }

#### Key Requirements:

  - **Test struct must conform to `RandomValueGenerating`**
  - **Include `var randomNumberGenerator = makeRandomNumberGenerator()` property**
  - **Mark test functions as `mutating`** when using random value generation
  - **Test struct can be immutable** for tests that don't use random values

#### Dedicated Random Value Extensions:

  - **Dedicated files**: Create `RandomValueGenerating+[ModuleName].swift` files for random value
    generation
  - **Centralized functions**: Move random value creation functions to these dedicated extension
    files
  - **Consistent patterns**: Follow existing patterns from other modules (e.g.,
    `RandomValueGenerating+AppPlatform.swift`)
  - **Proper imports**: Include necessary `@testable import` statements for modules being
    extended

Example structure:

    import DevTesting
    import Foundation

    @testable import ModuleName

    extension RandomValueGenerating {
        mutating func randomModuleSpecificType() -> ModuleType {
            return ModuleType(
                property: randomAlphanumericString()
            )
        }
    }

## File Organization

### Test Files

  - **Naming pattern**: `[TypeName]Tests.swift` in corresponding Tests directories
  - **Location**: Place in `Tests/[ModuleName]/[Category]/` directories
  - **One test file per type**: Each type should have its own dedicated test file
  - **Organize tests by function**: The tests for the function under test should be organized
    together, preceded by a `// MARK: - [FunctionName]` comment.

### Mock Files

  - **Naming pattern**: `Mock[ProtocolName].swift`
  - **Location**: Place in `Tests/[ModuleName]/Testing Support/` directories
  - **Protocol-based**: Mock the protocol interface, not concrete implementations

### Random Value Extensions

  - **Naming pattern**: `RandomValueGenerating+[ModuleName].swift`
  - **Location**: Place in `Tests/[ModuleName]/Testing Support/` directories
  - **Module-specific**: Create extensions for each module's unique types

### Import Patterns

  - **Testable imports**: Use `@testable import ModuleName` for modules under test
  - **Regular imports**: Use regular imports for testing frameworks and utilities
  - **Specific imports**: Import only what's needed to keep dependencies clear

## Test Coverage Guidelines

### Protocols
  - **Skip protocol-only tests**: Don't test pure protocols with no implementation

### Function Coverage
  - **Each function/getter**: Should have at least one corresponding test function
  - **Multiple scenarios**: Create additional test functions to cover edge cases and error
    conditions
  - **Error paths**: Test both success and failure scenarios for throwing functions

### Error Handling in Tests

**CRITICAL**: Test functions that use `#expect(throws:)` must be marked with `throws`,
otherwise you'll get "Errors thrown from here are not handled" compilation errors.

#### Correct Pattern:

    @Test
    func myTestThatExpectsErrors() throws {
        #expect(throws: SomeError.self) {
            try somethingThatThrows()
        }
    }

#### Common Mistake:

    // ❌ This will cause compilation error
    @Test
    func myTestThatExpectsErrors() {
        #expect(throws: SomeError.self) {
            try somethingThatThrows()
        }
    }

### Main Actor Considerations
  - **Test isolation**: Mark test structs and functions with `@MainActor` when testing
    MainActor-isolated code
  - **Mock conformance**: Ensure mocks properly handle MainActor isolation requirements
  - **Async testing**: Use proper async/await patterns for testing async code

### Dependency Injection Testing
  - **Mock all dependencies**: Create mocks for all injected dependencies to ensure proper
    isolation
  - **Verify interactions**: Test that dependencies are called with correct parameters
  - **State verification**: Check both mock call counts and state changes in the system under
    test

## Common Testing Patterns

**IMPORTANT**: Avoid using `Task.sleep()` for test coordination whenever possible. Instead, use
precise synchronization mechanisms like `AsyncStream`, `confirmation`, mock prologues/epilogues, or
returning tasks. Arbitrary delays make tests slower and less reliable.

### Testing Initialization

    @Test
    func initializationSetsCorrectDefaults() {
        let instance = SystemUnderTest()

        #expect(instance.property == expectedDefault)
    }

### Testing Dependency Calls

    @Test
    mutating func functionCallsDependency() {
        let mock = MockDependency()
        mock.functionStub = Stub()

        let instance = SystemUnderTest(dependency: mock)
        instance.performAction()

        #expect(mock.functionStub.calls.count == 1)
    }

### Testing Error Scenarios

    @Test
    mutating func functionThrowsWhenDependencyFails() {
        let mock = MockDependency()
        let error = MockError(description: "Test error")
        mock.functionStub = ThrowingStub(defaultError: error)

        let instance = SystemUnderTest(dependency: mock)

        #expect(throws: MockError.self) {
            try instance.performAction()
        }
    }

### Testing Async Operations

    @Test
    mutating func asyncMethodCompletesSuccessfully() async throws {
        let mock = MockDependency()
        mock.asyncMethodStub = Stub(defaultReturnValue: expectedResult)

        let instance = SystemUnderTest(dependency: mock)
        let result = await instance.performAsyncAction()

        #expect(result == expectedResult)
        #expect(mock.asyncMethodStub.calls.count == 1)
    }

### Using Confirmation to Verify Callbacks

Swift Testing's `confirmation` API ensures that specific code paths execute. Use it to verify that
callbacks, handlers, or closures are invoked:

    @Test
    mutating func linkedTextInitializationWithCustomUUID() async throws {
        let text = randomBasicLatinString()
        let customID = randomUUID()

        await confirmation { handlerCalled in
            let linkedText = RichTextContent.LinkedText(id: customID, text: text) {
                defer { handlerCalled() }
                return .handled
            }

            #expect(linkedText.text == text)
            #expect(linkedText.id == customID)
            #expect(linkedText.openHandler() == .handled)
        }
    }

**Key points:**

  - Call the confirmation callback (e.g., `handlerCalled()`) when the expected code path executes
  - The test will fail if the callback is never invoked
  - Use `defer` in handlers to ensure confirmation happens even if early returns occur

### Testing Synchronous Interfaces with Asynchronous Work

When testing code with a synchronous interface that performs asynchronous work internally
(e.g., posting to an event bus, dispatching to a queue), use `AsyncStream` to coordinate
test expectations rather than arbitrary sleep durations:

    @Test
    mutating func functionPostsEventAsynchronously() async throws {
        // set up the test with mocks and event observer
        let observer = ContextualBusEventObserver(context: ())
        eventBus.addObserver(observer)

        let instance = SystemUnderTest(eventBus: eventBus)

        // set up signaling mechanism for async completion
        let (signalStream, signaler) = AsyncStream<Void>.makeStream()
        await confirmation("event posted") { confirm in
            observer.addHandler(for: SomeEvent.self) { event, _ in
                // expect the event has correct data
                #expect(event.eventData.value == expectedValue)
                confirm()
                signaler.yield()
            }

            // exercise the test by calling the synchronous function
            instance.performSynchronousMethod()

            // wait for the asynchronous work to complete
            await signalStream.first { _ in true }
        }
    }

#### Key Points for Synchronous Interfaces with Async Work:

  - **Use `AsyncStream.makeStream()`**: Create a signal stream and signaler to coordinate
    completion
  - **Signal after confirmation**: Call `signaler.yield()` after calling `confirm()` in the
    handler
  - **Wait for signal**: Use `await signalStream.first { _ in true }` instead of
    `Task.sleep(for:)`
  - **Avoid arbitrary delays**: This pattern waits precisely for the async work to complete,
    making tests faster and more reliable
  - **Common use cases**: Event bus posting, background queue dispatch, timer-based operations

#### Alternative: Returning Tasks for Testability

When possible, if a function spawns a `Task` and doesn't need to return a value, consider
returning the task itself to simplify testing. Mark the result as `@discardableResult` so
callers can ignore it in production code:

    @discardableResult
    func performBackgroundWork() -> Task<Void, Never> {
        Task {
            // Perform async work...
            await someAsyncOperation()
        }
    }

This allows tests to await the task completion directly without needing stream-based
coordination:

    @Test
    mutating func backgroundWorkCompletes() async throws {
        let instance = SystemUnderTest()

        // exercise the test and await the returned task
        let task = instance.performBackgroundWork()
        await task.value

        // expect the work completed successfully
        #expect(instance.workCompletedFlag == true)
    }

**When to use this pattern:**

  - Function spawns a `Task` internally for background work
  - Return value is not otherwise needed
  - Tests need to verify completion or side effects

**When to use `AsyncStream` instead:**

  - Cannot modify the function signature (e.g., protocol requirements, public API constraints)
  - Function doesn't spawn a task directly (e.g., posts to event bus, uses callbacks)
  - Multiple async operations occur that need individual verification

### Testing Observable Type State Changes

**PREFERRED PATTERN**: When testing `@Observable` types that update asynchronously through internal
tasks, use the `Observations` helper from Swift Foundation. This pattern is simpler and more reliable
than manual observation tracking.

#### Preferred: Using Observations Helper

The `Observations` helper directly observes property changes and waits for specific conditions:

    @Test @MainActor
    mutating func navigationTitleReflectsCurrentChatTitle() async throws {
        // set up the test with a task that the view model will await and use to update its 
        // navigationTitle property
        let pendingTask = Task<Chat.MessageResponse, any Error> {
            return messageResponse
        }

        // exercise: create view model that spawns internal Task observing chat.title
        let viewModel = SearchResultsViewModel(
            dependencies: dependencies,
            pendingMessageResponseTask: pendingTask,
            delegate: mockDelegate
        )

        // wait for internal task to process initial state
        _ = await Observations({ viewModel.navigationTitle }).first { @Sendable _ in true }

        // expect that navigationTitle was updated by internal task
        #expect(viewModel.navigationTitle == "Initial Title")
    }

#### Why Observations is Preferred:

**❌ Wrong Pattern - AsyncStream Signaler:**

This pattern doesn't actually observe state changes. It only continues the pending task but doesn't
ensure the view model's internal observation task has completed its work:

    let (signalStream, signaler) = AsyncStream<Void>.makeStream()
    let pendingTask = Task {
        await signalStream.first { _ in true }
        return response
    }
    // ... create view model ...
    signaler.yield()  // ❌ Only unblocks pendingTask, doesn't observe state change

**✅ Correct Pattern - Observations:**

This pattern actually observes the property and waits for the specific condition to be true:

    _ = await Observations({ viewModel.navigationTitle }).first { @Sendable title in
        title == expectedValue
    }  // ✅ Waits for actual state change

#### Key Points for Observations Pattern:

  - **Use for internal async tasks**: When the type spawns internal `Task`s that update state
  - **Observe the property directly**: Pass a closure that reads the property
  - **Wait for specific conditions**: Use `.first { condition }` to wait for expected state
  - **Mark closure as `@Sendable`**: Required for concurrency safety
  - **Simpler than `withObservationTracking`**: No need for manual stream coordination
  - **More reliable than signalers**: Actually observes state changes rather than just unblocking tasks

#### When to Use Each Pattern:

  - **`Observations` helper**: Testing `@Observable` types with internal async state updates (preferred)
  - **`withObservationTracking`**: When you need manual control over observation lifecycle
  - **`AsyncStream` with signaler**: Testing synchronous interfaces with async work (event bus, etc.)
  - **Returned tasks**: When possible, return tasks from functions for direct awaiting

#### Alternative: Manual Observation Tracking

When you need manual control over the observation lifecycle, use `withObservationTracking`:

    @Test @MainActor
    mutating func observableStateChangesAsynchronously() async throws {
        // set up the test by creating the object and mocked dependencies
        let instance = SystemUnderTest()
        let mockDependency = MockDependency()
        instance.dependency = mockDependency

        // set up observation and confirmation for async state change
        let (signalStream, signaler) = AsyncStream<Void>.makeStream()
        try await confirmation { stateChanged in
            withObservationTracking {
                _ = instance.observableState
            } onChange: {
                stateChanged()
                signaler.yield()
            }

            // exercise the test by triggering the state change
            try instance.performActionThatChangesState()

            // await a signal to know the state change occurred
            await signalStream.first { @MainActor _ in true }
        }

        // expect the final state to be correct
        #expect(instance.observableState == expectedFinalState)
    }

**When to use `withObservationTracking`:**

  - Need to verify observation behavior itself (not just state changes)
  - Need precise control over when observation starts/stops
  - Testing custom observation mechanisms

**Otherwise, prefer `Observations` helper** for simpler, more focused tests.

### Testing with Mock Prologue and Epilogue Closures

When testing code that calls mock functions, you can use prologue and epilogue closures to control
execution timing. Prologues execute before the stub, epilogues execute after. See
`@Documentation/TestMocks.md` for the mock implementation patterns.

#### Pattern: Blocking Mock Execution

    @Test
    mutating func testIntermediateStateWhileSending() async throws {
        // set up the test with a blocking prologue
        let (signalStream, signaler) = AsyncStream<Void>.makeStream()
        mockClient.sendEventsPrologue = {
            await signalStream.first(where: { _ in true })
        }
        mockClient.sendEventsStub = ThrowingStub(defaultResult: .success(.init()))

        let instance = SystemUnderTest(client: mockClient)

        // exercise the test by triggering the async operation
        instance.performAction()

        // expect intermediate state while mock is blocked
        await #expect(instance.isProcessing == true)
        await #expect(instance.queuedItems.count == 5)

        // signal completion to unblock the mock
        signaler.yield()

        // allow async processing to complete
        try await Task.sleep(for: .milliseconds(100))

        // expect final state after mock completes
        await #expect(instance.isProcessing == false)
        await #expect(instance.queuedItems.isEmpty)
    }

#### Pattern: Adding Controlled Delays

    @Test
    mutating func testTimeoutBehavior() async throws {
        // set up the test with a delay in the mock
        mockClient.sendEventsPrologue = {
            try await Task.sleep(for: .milliseconds(200))
        }
        mockClient.sendEventsStub = ThrowingStub(defaultResult: .success(.init()))

        let instance = SystemUnderTest(client: mockClient, timeout: .milliseconds(100))

        // exercise the test
        instance.performActionWithTimeout()

        // expect timeout occurred before mock completed
        try await Task.sleep(for: .milliseconds(150))
        await #expect(instance.didTimeout == true)
    }

#### Pattern: Signaling Completion with Epilogue

    @Test
    mutating func testEventHandlerLogsToTelemetry() async throws {
        // set up the test with epilogue for coordination
        let telemetryLogger = MockTelemetryEventLogger()
        telemetryLogger.logEventStub = Stub()

        let (signalStream, signaler) = AsyncStream<Void>.makeStream()
        telemetryLogger.logEventEpilogue = {
            signaler.yield()
        }

        // exercise the test by posting event
        eventBus.post(SomeEvent())

        // wait for async handler to complete logging
        await signalStream.first { _ in true }

        // expect the event was logged
        #expect(telemetryLogger.logEventStub.calls.count == 1)
    }

#### Key Points

  - **Prologues execute before stub**: Control timing before mock processes input
  - **Epilogues execute after stub**: Signal completion or coordinate post-execution state
  - **Eliminates arbitrary delays**: Replace `Task.sleep` with precise synchronization
  - **Test intermediate states**: Verify system behavior at different execution phases
  - **Optional by default**: Tests can ignore if timing control isn't needed
  - **Separate concerns**: Prologue/epilogue handle timing, stub handles return values/errors


## Integration with Existing Documentation

This testing documentation supplements the main project documentation:

  - **Test Mocks**: See `@Documentation/TestMocks.md` for detailed mock object patterns
  - **Dependency Injection**: See `@Documentation/DependencyInjection.md` for dependency
    patterns
  - **MVVM Testing**: See `@Documentation/MVVMForSwiftUI.md` for view model testing approaches

When in doubt, follow existing patterns from similar tests in the codebase and reference the
established documentation for architectural guidance.
