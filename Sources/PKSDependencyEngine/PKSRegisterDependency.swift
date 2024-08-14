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
    
    // The type that defines how the dependency should be destroyed.
    private var destroyType: DependencyDestroyType

    /// Initializes a `PKSRegisterDependency` and registers the provided dependency.
    ///
    /// - Parameters:
    ///   - destroyType: The type defining how the dependency should be destroyed.
    ///   - wrappedValue: The dependency instance to be registered.
    ///   - engine: The dependency engine to use for registration. Defaults to the shared instance.
    public init(wrappedValue: Value, _ destroyType: DependencyDestroyType = .notConfigured, engine: PKSDependencyEngine = .shared) {
        self.value = wrappedValue
        self.engine = engine
        self.destroyType = destroyType
        self.engine.register(wrappedValue, for: Value.self)

        if destroyType == .never {
            self.engine.addNonDestroyableDependency(for: Value.self)
        }
    }

    /// Deinitializes the dependency and removes it from the `PKSDependencyEngine`.
    /// 
    /// If the destroy type is set to `.onRelease`, the dependency will be removed when the wrapper is deinitialized.
    deinit {
        if destroyType == .onRelease {
            engine.removeDependency(for: Value.self)
        }
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

    /// The destroy type configuration.
    ///
    /// - Returns: The destroy type associated with this dependency.
    public var destroyTypeConfig: DependencyDestroyType {
        get { destroyType }
    }
}
