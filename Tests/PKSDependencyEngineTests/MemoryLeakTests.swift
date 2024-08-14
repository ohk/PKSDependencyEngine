//
//  MemoryLeakTests.swift
//
//
//  Created by Ömer Hamid Kamışlı on 8/13/24.
//

import XCTest
@testable import PKSDependencyEngine

final class MemoryLeakTests: XCTestCase {
    let depencyEngine = PKSDependencyEngine()
    
    func trackForMemoryLeak(
        instance: Any?,
        file: StaticString = #filePath,
        line: UInt = #line,
        expectedLeak: Bool = false
    ) {
        guard instance != nil, let instance = instance as? AnyObject else {
            return // If instance is not a class instance, no need to track it for memory leaks
        }
        
        
        addTeardownBlock { [weak instance] in
            if expectedLeak {
                XCTAssertNotNil(
                    instance,
                    "Expected instance to still exist, but it has been deallocated. Check if the instance is being properly retained. Instance: \(String(describing: instance))",
                    file: file,
                    line: line
                )
            } else {
                XCTAssertNil(
                    instance,
                    "Instance should have been deallocated. Possible memory leak. \(String(describing: instance))",
                    file: file,
                    line: line
                )
            }
        }
    }
    
    func testPKSDependencyMemoryLeak() {
        var service: MockServiceProtocol? = MockService()
        var service2: MockServiceProtocol? = MockService()
        let service3: MockServiceProtocol? = MockService()
        
        
        @PKSRegisterDependency(engine: depencyEngine) var resolvedService: MockServiceProtocol = service!
        
        resolvedService = service2! // Re-assign to trigger the setter
        resolvedService = service3! // Set to nil if your setter logic allows
        
        service = nil
        service2 = nil
        
        trackForMemoryLeak(instance: service)
        trackForMemoryLeak(instance: service2)
        trackForMemoryLeak(instance: service3, expectedLeak: true)
    }
}
