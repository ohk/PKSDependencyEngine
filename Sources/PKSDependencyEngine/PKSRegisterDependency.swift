//
//  PKSRegisterDependency.swift
//
//
//  Created by Ömer Hamid Kamışlı on 8/13/24.
//

import Foundation

/// A property wrapper that registers a dependency with the `PKSDependencyEngine`.
///
/// `PKSRegisterDependency` allows you to automatically register a dependency when it is initialized.
/// This is useful for ensuring that dependencies are available in the `PKSDependencyEngine` as soon as your app starts.
///
/// Example usage:
///
///     @PKSRegisterDependency var myService: MyServiceProtocol = MyService()
///
/// The dependency will be registered when the wrapper is initialized.
@propertyWrapper
public class PKSRegisterDependency<Value> {
    // The dependency value that is being registered.
    private var value: Value
    
    // The engine responsible for registering dependencies.
    private let engine: PKSDependencyEngine
    
    /// Initializes a `PKSRegisterDependency` and registers the provided dependency.
    ///
    /// - Parameters:
    ///   - wrappedValue: The dependency instance to be registered.
    ///   - engine: The dependency engine to use for registration. Defaults to the shared instance.
    public init(wrappedValue: Value, engine: PKSDependencyEngine = .shared) {
        self.value = wrappedValue
        self.engine = engine
        self.engine.register(wrappedValue, for: Value.self)
    }
    
    /// The registered dependency value.
    ///
    /// - Returns: The registered dependency instance.
    public var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            engine.register(self.value, for: Value.self)
        }
    }
}
