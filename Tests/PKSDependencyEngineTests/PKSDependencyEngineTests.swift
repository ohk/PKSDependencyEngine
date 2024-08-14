import XCTest
@testable import PKSDependencyEngine

final class PKSDependencyEngineTests: XCTestCase {
    let depencyEngine = PKSDependencyEngine()

    override func setUp() {
        super.setUp()
        // Clear the dependency engine before each test
        depencyEngine.clearDependencies()
    }

    func testRegisterAndResolveDependency() {
        // Given
        let service = MockService()
        
        // When
        depencyEngine.register(service as MockServiceProtocol, for: MockServiceProtocol.self)
        let resolvedService: MockServiceProtocol = depencyEngine.read(for: MockServiceProtocol.self)
        
        // Then
        XCTAssertEqual(resolvedService.doSomething(), service.doSomething())
    }
    
    func testResolveMissingDependencyThrowsFatalError() {
        // Given
        let expectedFatalErrorMessage = "Implementation for MockServiceProtocol is not found"
        
        // When / Then
        expectFatalError(expectedMessage: expectedFatalErrorMessage) {
            _ = PKSDependencyEngine.shared.read(for: MockServiceProtocol.self)
        }
    }
}

extension XCTestCase {
    func expectFatalError(expectedMessage: String, testcase: @escaping () -> Void) {

        // arrange
        let expectation = self.expectation(description: "expectingFatalError")
        var assertionMessage: String? = nil

        // override fatalError. This will pause forever when fatalError is called.
        FatalErrorUtil.replaceFatalError { message, _, _ in
            assertionMessage = message
            expectation.fulfill()
            unreachable()
        }

        // act, perform on separate thead because a call to fatalError pauses forever
        DispatchQueue.global(qos: .userInitiated).async(execute: testcase)

        waitForExpectations(timeout: 0.1) { _ in
            // assert
            XCTAssertEqual(assertionMessage, expectedMessage)

            // clean up
            FatalErrorUtil.restoreFatalError()
        }
    }
}
