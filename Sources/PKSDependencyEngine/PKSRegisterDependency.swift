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
    private var factory: () -> Value
    private let engine: PKSDependencyEngine
    private var destroyType: DependencyDestroyType
    private let isLazy: Bool

    /// Initializes a `PKSRegisterDependency` and registers the provided dependency.
    ///
    /// - Parameters:
    ///   - destroyType: The type defining how the dependency should be destroyed.
    ///   - wrappedValue: The dependency instance to be registered.
    ///   - engine: The dependency engine to use for registration. Defaults to the shared instance.
    ///   - lazy: Whether to register the dependency lazily. Defaults to `false`.
    public init(wrappedValue: @autoclosure @escaping () -> Value, _ destroyType: DependencyDestroyType = .notConfigured, lazy: Bool = false, engine: PKSDependencyEngine = .shared) {
        self.factory = wrappedValue
        self.engine = engine
        self.destroyType = destroyType
        self.isLazy = lazy
        
        if isLazy {
            self.engine.registerLazy(self.factory, for: Value.self)
        } else {
            self.engine.register(self.factory(), for: Value.self)
        }

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
        get { engine.read(for: Value.self) }
        set {
            factory = { newValue }
            if isLazy {
                engine.registerLazy(self.factory, for: Value.self)
            } else {
                engine.register(newValue, for: Value.self)
            }
            
            if destroyType == .never {
                self.engine.addNonDestroyableDependency(for: Value.self)
            }
        }
    }
}
