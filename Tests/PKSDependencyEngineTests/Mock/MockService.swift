//
//  MockService.swift
//
//
//  Created by Ömer Hamid Kamışlı on 8/13/24.
//

import Foundation

protocol MockServiceProtocol {
    var id: UUID { get }
    func doSomething() -> String
}

class MockService: MockServiceProtocol {
    var id: UUID = UUID()
    
    func doSomething() -> String {
        return "MockService did something!"
    }
}
