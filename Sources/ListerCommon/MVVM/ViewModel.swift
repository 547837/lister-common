//
//  ViewModel.swift
//
//  Created by 李斯特 on 2020/12/28.
//

import Combine
import Foundation

public protocol ViewModel: ObservableObject where ObjectWillChangePublisher.Output == Void {
    
    associatedtype State
    associatedtype Input
    
    var state: State { get }
    func apply(_ input: Input)
}

extension AnyViewModel: Identifiable where State: Identifiable {
    public var id: State.ID {
        state.id
    }
}

@dynamicMemberLookup
public final class AnyViewModel<State, Input>: ViewModel {
    
    // MARK: Stored properties
    
    private let wrappedObjectWillChange: () -> AnyPublisher<Void, Never>
    private let wrappedState: () -> State
    private let wrappedTrigger: (Input) -> Void
    
    // MARK: Computed properties
    
    public var objectWillChange: AnyPublisher<Void, Never> {
        wrappedObjectWillChange()
    }
    
    public var state: State {
        get {
            wrappedState()
        }
    }
    
    
    // MARK: Methods
    
    public func apply(_ input: Input) {
        wrappedTrigger(input)
    }
    
    public subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
        state[keyPath: keyPath]
    }
    
    // MARK: Initialization
    public init<V: ViewModel>(_ viewModel: V) where V.State == State, V.Input == Input {
        self.wrappedObjectWillChange = { viewModel.objectWillChange.eraseToAnyPublisher() }
        self.wrappedState = { viewModel.state }
        self.wrappedTrigger = viewModel.apply
    }
    
}

