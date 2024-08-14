//
//  PKSDependencyTests.swift
//  
//
//  Created by Ömer Hamid Kamışlı on 8/13/24.
//

import XCTest
@testable import PKSDependencyEngine


final class PKSDependencyTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Clear the dependency engine before each test
        PKSDependencyEngine.shared.clearDependencies()
    }

    func testResolveDependencyAutomatically() {
        // Given
        let service = MockService()
        PKSDependencyEngine.shared.register(service as MockServiceProtocol, for: MockServiceProtocol.self)
        
        // When
        @PKSDependency var resolvedService: MockServiceProtocol
        
        // Then
        XCTAssertEqual(resolvedService.doSomething(), service.doSomething())
    }
    
    func testSetDependencyManually() {
        // Given
        @PKSDependency var resolvedService: MockServiceProtocol
        let service = MockService()
        
        // When
        resolvedService = service
        
        // Then
        XCTAssertEqual(resolvedService.doSomething(), service.doSomething())
    }
}
