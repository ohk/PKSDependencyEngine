//
//  PKSDependencyEngine.swift
//
//
//  Created by Ömer Hamid Kamışlı on 8/13/24.
//

import OSLog

/// A singleton class responsible for managing and providing dependencies throughout the application.
///
/// The `PKSDependencyEngine` class provides a centralized way to register and resolve dependencies.
/// Dependencies are stored in a dictionary with their type's `ObjectIdentifier` as the key.
/// This ensures that each dependency is registered and resolved by its specific type.
///
/// Example usage:
///
///     // Registering a dependency
///     PKSDependencyEngine.shared.register(MyService() as MyServiceProtocol)
///
///     // Resolving a dependency
///     let service: MyServiceProtocol = PKSDependencyEngine.shared.read(for: MyServiceProtocol.self)
///
///     // Alternative Registering a dependency
///     @PKSRegisterDependency var myService: MyServiceProtocol = MyService()
///
///     // Alternative Resolving a dependency
///     @PKSDependency var resolvedService: MyServiceProtocol
///
///
/// The class is thread-safe due to the use of a concurrent queue with barrier flags.
///
/// - Note: If a dependency is not found during resolution, the app will crash with a `fatalError`.
public final class PKSDependencyEngine {
    // Dictionary for eager registrations
    private var dependencies: [ObjectIdentifier: Any] = [:]
    
    // Dictionary for lazy registrations
    private var lazyDependencies: [ObjectIdentifier: () -> Any] = [:]
    
    // A concurrent dispatch queue used for thread-safe access to the dependencies dictionary.
    private let queue = DispatchQueue(label: "DependencyEngineQueue", attributes: .concurrent)
    
    // Logger instance for logging various events in the dependency engine.
    private let logger: Logger = Logger(subsystem: "POIKUS", category: "Dependency Engine")
    
    /// The shared singleton instance of `PKSDependencyEngine`.
    public static let shared = PKSDependencyEngine()

    /// A list of dependencies that should not be destroyed when `removeDependency` is called.
    private var nonDestroyableDependencies: [ObjectIdentifier] = []

    /// Registers a dependency for a given type.
    ///
    /// - Parameters:
    ///   - instance: The dependency instance to register.
    ///   - interface: The type of the interface or class that the dependency conforms to.
    public func register<Value>(_ instance: Value, for interface: Value.Type) {
        queue.async(flags: .barrier) {
            self.logger.log("Registering dependency for \(interface)")
            self.dependencies[ObjectIdentifier(interface)] = instance
        }
    }

    /// Registers a lazy dependency for a given type.
    ///
    /// - Parameters:
    ///   - factory: A closure that creates the dependency instance.
    ///   - interface: The type of the interface or class that the dependency conforms to.
    public func registerLazy<Value>(_ factory: @escaping () -> Value, for interface: Value.Type) {
        queue.async(flags: .barrier) {
            self.logger.log("Registering lazy dependency for \(interface)")
            self.lazyDependencies[ObjectIdentifier(interface)] = factory
        }
    }
    
    /// Resolves and returns a dependency for a given type.
    ///
    /// - Parameter interface: The type of the interface or class to resolve.
    /// - Returns: The resolved dependency instance.
    /// - Throws: A `fatalError` if no dependency is found for the specified type.
    public func read<Value>(for interface: Value.Type) -> Value {
        logger.log("Resolving dependency for \(interface)")
        return queue.sync {
            let key = ObjectIdentifier(interface)
            
            if let instance = dependencies[key] as? Value {
                return instance
            }
            
            if let factory = lazyDependencies[key], let instance = factory() as? Value {
                dependencies[key] = instance
                lazyDependencies.removeValue(forKey: key)
                return instance
            }
            
            logger.log("Dependency for \(interface) is not found")
            fatalError("Implementation for \(interface) is not found")
        }
    }
    
    /// Clears all dependencies from the engine.
    public func clearDependencies() {
        queue.sync(flags: .barrier) {
            self.logger.log("Clearing all dependencies")
            self.dependencies = [:]
            self.lazyDependencies = [:]
        }
    }

    /// Removes a dependency for a given type.
    public func removeDependency<Value>(for interface: Value.Type) {
        queue.sync(flags: .barrier) {
            let key = ObjectIdentifier(interface)
            if self.nonDestroyableDependencies.contains(key) {
                self.logger.log("Dependency for \(interface) is non-destroyable")
            } else {
                self.logger.log("Removing dependency for \(interface)")
                self.dependencies.removeValue(forKey: key)
                self.lazyDependencies.removeValue(forKey: key)
            }
        }
    }

    /// Adds a dependency to the non-destroyable list.
    /// 
    /// - Parameter interface: The type of the interface or class to add to the non-destroyable list.
    /// - Note: This method is thread-safe.
    /// - Warning: This method will add the dependency to the non-destroyable list. Use with caution in production code.
    /// - Warning: This method will not throw an error if the dependency is already in the non-destroyable list.
    /// - Warning: This method will not throw an error if the dependency is not found.
    /// 
    public func addNonDestroyableDependency<Value>(for interface: Value.Type) {
        queue.sync(flags: .barrier) {
            self.logger.log("Adding dependency for \(interface) to non-destroyable list")
            self.nonDestroyableDependencies.append(ObjectIdentifier(interface))
        }
    }
}
