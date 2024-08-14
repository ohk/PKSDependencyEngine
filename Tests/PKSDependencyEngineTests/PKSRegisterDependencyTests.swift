//
//  PKSRegisterDependency.swift
//  
//
//  Created by Ömer Hamid Kamışlı on 8/13/24.
//

import XCTest
@testable import PKSDependencyEngine

final class PKSRegisterDependencyTests: XCTestCase {
    let depencyEngine = PKSDependencyEngine()
    
    override func setUp() {
        super.setUp()
        // Clear the dependency engine before each test
        depencyEngine.clearDependencies()
    }

    func testRegisterDependencyAutomatically() {
        // Given
        @PKSRegisterDependency(engine: depencyEngine) var service: MockServiceProtocol = MockService()
        
        // When
        let resolvedService: MockServiceProtocol = depencyEngine.read(for: MockServiceProtocol.self)
        
        // Then
        XCTAssertEqual(resolvedService.doSomething(), service.doSomething())
    }
    
    func testUpdateRegisteredDependency() {
        // Given
        @PKSRegisterDependency(engine: depencyEngine) var service: MockServiceProtocol = MockService()
        let newService = MockService()
        
        XCTAssertNotEqual(service.id, newService.id)
        
        // When
        service = newService
        
        // Then
        let resolvedService: MockServiceProtocol = depencyEngine.read(for: MockServiceProtocol.self)
        XCTAssertEqual(resolvedService.doSomething(), newService.doSomething())
    }

    func testRegisterNonDestroyableDependency() {
        // Given
        @PKSRegisterDependency(.never, engine: depencyEngine) var service: MockServiceProtocol = MockService()
        
        service = MockService()
        
        // When
        depencyEngine.removeDependency(for: MockServiceProtocol.self)
        
        // Then
        let resolvedService: MockServiceProtocol = depencyEngine.read(for: MockServiceProtocol.self)

        XCTAssertEqual(resolvedService.doSomething(), "MockService did something!")
    }
    
    func testRegisterDependencyWithDestroyType() {
        // Given
        @PKSRegisterDependency(.onRelease, engine: depencyEngine) var service: MockServiceProtocol = MockService()
        
        // When
        depencyEngine.removeDependency(for: MockServiceProtocol.self)
        
        // Then
        let expectedFatalErrorMessage = "Implementation for MockServiceProtocol is not found"
        
        expectFatalError(expectedMessage: expectedFatalErrorMessage) {
            _ = PKSDependencyEngine.shared.read(for: MockServiceProtocol.self)
        }
    }

    func testRegisterDependecyDestroyOnRelease() {
        // Given
        @PKSRegisterDependency(.onRelease, engine: depencyEngine) var service: MockServiceProtocol = MockService()
        
        // Then
        addTeardownBlock {
            let expectedFatalErrorMessage = "Implementation for MockServiceProtocol is not found"
                    
            self.expectFatalError(expectedMessage: expectedFatalErrorMessage) {
                _ = PKSDependencyEngine.shared.read(for: MockServiceProtocol.self)
            }
        }
    }
}
