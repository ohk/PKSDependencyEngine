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
    // A dictionary that stores closures returning dependencies, keyed by ObjectIdentifier.
    private var dependencies: [ObjectIdentifier: () -> Any] = [:]
    
    // A concurrent dispatch queue used for thread-safe access to the dependencies dictionary.
    private let queue = DispatchQueue(label: "DependencyEngineQueue", attributes: .concurrent)
    
    // Logger instance for logging various events in the dependency engine.
    private let logger: Logger = Logger(subsystem: "POIKUS", category: "Dependency Engine")
    
    /// The shared singleton instance of `PKSDependencyEngine`.
    public static let shared = PKSDependencyEngine()
    
    /// A private initializer to prevent external instantiation of the class.
    private init() {}

    /// A list of dependencies that should not be destroyed when `removeDependency` is called.
    private var nonDestroyableDependencies: [ObjectIdentifier] = []

    /// Registers a dependency for a given type.
    ///
    /// - Parameters:
    ///   - value: A closure that returns the dependency instance. The closure is marked with `@autoclosure`
    ///            to allow passing the instance directly without explicit closure syntax.
    ///   - interface: The type of the interface or class that the dependency conforms to.
    public func register<Value>(_ value: @autoclosure @escaping () -> Value, for interface: Value.Type) {
        queue.async(flags: .barrier) {
            self.logger.log("Registering dependency for \(interface)")
            self.dependencies[ObjectIdentifier(interface)] = value
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
            guard let value = dependencies[ObjectIdentifier(interface)]?() as? Value else {
                logger.log("Dependency for \(interface) is not found")
                fatalError("Implementation for \(interface) is not found")
            }
            logger.log("Dependency for \(interface) is resolved")
            return value
        }
    }
    
    /// Clears all dependencies from the engine.
    /// 
    /// This method is useful for testing purposes to reset the engine between tests.
    /// - Note: This method is thread-safe.
    /// - Warning: This method will remove all dependencies from the engine. Use with caution in production code.
    public func clearDependencies() {
        queue.async(flags: .barrier) {
            self.logger.log("Clearing all dependencies")
            self.dependencies = [:]
        }
    }

    /// Removes a dependency for a given type.
    /// 
    /// - Parameter interface: The type of the interface or class to remove.
    /// - Note: This method is thread-safe.
    /// - Warning: This method will remove the dependency from the engine. Use with caution in production code.
    /// - Warning: This method will not throw an error if the dependency is not found.
    public func removeDependency<Value>(for interface: Value.Type) {
        queue.async(flags: .barrier) {
            if self.nonDestroyableDependencies.contains(ObjectIdentifier(interface)) {
                self.logger.log("Dependency for \(interface) is non-destroyable")
            } else {
                self.logger.log("Removing dependency for \(interface)")
                self.dependencies.removeValue(forKey: ObjectIdentifier(interface))
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
        queue.async(flags: .barrier) {
            self.logger.log("Adding dependency for \(interface) to non-destroyable list")
            self.nonDestroyableDependencies.append(ObjectIdentifier(interface))
        }
    }
}
