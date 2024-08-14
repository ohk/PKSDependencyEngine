//
//  PKSDependencyTests.swift
//  
//
//  Created by Ömer Hamid Kamışlı on 8/13/24.
//

import XCTest
@testable import PKSDependencyEngine


final class PKSDependencyTests: XCTestCase {
    let depencyEngine = PKSDependencyEngine()
    
    override func setUp() {
        super.setUp()
        // Clear the dependency engine before each test
        depencyEngine.clearDependencies()
    }

    func testResolveDependencyAutomatically() {
        // Given
        let service = MockService()
        depencyEngine.register(service as MockServiceProtocol, for: MockServiceProtocol.self)
        
        // When
        @PKSDependency(engine: depencyEngine) var resolvedService: MockServiceProtocol
        
        // Then
        XCTAssertEqual(resolvedService.doSomething(), service.doSomething())
    }
    
    func testSetDependencyManually() {
        // Given
        @PKSDependency(engine: depencyEngine) var resolvedService: MockServiceProtocol
        let service = MockService()
        
        // When
        resolvedService = service
        
        // Then
        XCTAssertEqual(resolvedService.doSomething(), service.doSomething())
    }
}
