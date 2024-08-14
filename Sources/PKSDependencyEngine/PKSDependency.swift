//
//  PKSDependency.swift
//
//
//  Created by Ömer Hamid Kamışlı on 8/13/24.
//

import Foundation

/// A property wrapper that provides dependency injection capabilities.
///
/// `PKSDependency` allows you to automatically resolve dependencies using the `PKSDependencyEngine`.
/// It can be used to inject dependencies into properties of your classes or structs.
///
/// Example usage:
///
///     @PKSDependency var myService: MyServiceProtocol
///
/// The dependency will be resolved when the property is first accessed.
///
/// - Note: The `PKSDependencyEngine` will be used to resolve the dependency if it has not been manually set.
@propertyWrapper
public class PKSDependency<Value> {
    // The resolved value of the dependency.
    private var value: Value?
    
    // The engine responsible for resolving dependencies.
    private let engine: PKSDependencyEngine
    
    /// Initializes a `PKSDependency` with an optional initial value and a dependency engine.
    ///
    /// - Parameters:
    ///   - value: An optional initial value for the dependency.
    ///   - engine: The dependency engine to use for resolving the dependency. Defaults to the shared instance.
    public init(value: Value? = nil, engine: PKSDependencyEngine = .shared) {
        self.value = value
        self.engine = engine
    }
    
    /// Initializes a `PKSDependency` without an initial value.
    ///
    /// The dependency will be resolved when the property is first accessed.
    ///
    /// - Parameter engine: The dependency engine to use for resolving the dependency. Defaults to the shared instance.
    public init(engine: PKSDependencyEngine = .shared) {
        self.engine = engine
    }
    
    /// The resolved dependency value.
    ///
    /// - Returns: The resolved dependency instance. If the value has not been set manually, it will be resolved
    ///            using the `PKSDependencyEngine` when first accessed.
    public var wrappedValue: Value {
        get {
            if let value {
                return value
            } else {
                let value: Value = engine.read(for: Value.self)
                self.value = value
                return value
            }
        }
        
        set {
            value = newValue
        }
    }
}

