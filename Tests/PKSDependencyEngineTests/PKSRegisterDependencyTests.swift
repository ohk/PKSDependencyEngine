//
//  PKSRegisterDependency.swift
//  
//
//  Created by Ömer Hamid Kamışlı on 8/13/24.
//

import XCTest
@testable import PKSDependencyEngine

final class PKSRegisterDependencyTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Clear the dependency engine before each test
        PKSDependencyEngine.shared.clearDependencies()
    }

    func testRegisterDependencyAutomatically() {
        // Given
        @PKSRegisterDependency var service: MockServiceProtocol = MockService()
        
        // When
        let resolvedService: MockServiceProtocol = PKSDependencyEngine.shared.read(for: MockServiceProtocol.self)
        
        // Then
        XCTAssertEqual(resolvedService.doSomething(), service.doSomething())
    }
    
    func testUpdateRegisteredDependency() {
        // Given
        @PKSRegisterDependency var service: MockServiceProtocol = MockService()
        let newService = MockService()
        
        XCTAssertNotEqual(service.id, newService.id)
        
        // When
        service = newService
        
        // Then
        let resolvedService: MockServiceProtocol = PKSDependencyEngine.shared.read(for: MockServiceProtocol.self)
        XCTAssertEqual(resolvedService.doSomething(), newService.doSomething())
    }
}
