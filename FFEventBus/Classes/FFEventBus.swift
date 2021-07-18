//
//  EventBus.swift
//  DangJi
//
//  Created by fans on 2021/7/8.
//  Copyright © 2021 Glority. All rights reserved.
//

import Foundation

public typealias FFEventBusParams = [String: Any]
public typealias FFEventBusInClosure = (_ param: FFEventBusParams) -> Void
public typealias FFEventBusClosure = (_ then: @escaping FFEventBusInClosure, _ end: @escaping FFEventBusInClosure, _ param: FFEventBusParams) -> Void

/**
 Multi threading is not supported for now
 */
public class FFEventBus {
    
    private var headEvent: Event? = nil
    private var tailEvent: Event? = nil
    private let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    @discardableResult
    public func begin(_ event: @escaping FFEventBusClosure) -> Self {
        let eventObj = Event(name: name) { [weak self] (_) -> Void in
            if let obj = self {
                event(obj.thenClosure, obj.endClosure, [:])
            }
        }
        self.headEvent = eventObj
        self.tailEvent = nil
        return self
    }
    
    @discardableResult
    public func then(_ event: @escaping FFEventBusClosure) -> Self {
        guard let head = self.headEvent else {
            return begin(event)
        }
        let eventObj = Event(name: name) { [weak self] (param: FFEventBusParams) -> Void in
            if let obj = self {
                event(obj.thenClosure, obj.endClosure, param)
            }
        }
        if head.next == nil {
            head.next = eventObj
            self.tailEvent = eventObj
        } else {
            self.tailEvent?.next = eventObj
            self.tailEvent = eventObj
        }
        return self
    }
    
    public func end(_ event: @escaping FFEventBusInClosure) {
        let eventObj = Event(name: name) { [weak self] (param: FFEventBusParams) -> Void in
            event(param)
            self?.headEvent = nil
            self?.tailEvent = nil
        }
        if self.headEvent == nil {
            self.headEvent = eventObj
        } else if self.tailEvent == nil {
            self.tailEvent = eventObj
            self.headEvent?.next = eventObj
        } else {
            self.tailEvent?.next = eventObj
            self.tailEvent = eventObj
        }
        self.headEvent?.action([:])
    }
    
    private var thenClosure: FFEventBusInClosure {
        return { [weak self] (param: FFEventBusParams) -> Void in
            let next = self?.headEvent?.next
            self?.headEvent = next
            next?.action(param)
        }
    }
    
    private var endClosure: FFEventBusInClosure {
        return { [weak self] (param: FFEventBusParams) -> Void in
            self?.tailEvent?.action(param)
        }
    }
}

fileprivate class Event {
    var next: Event? = nil
    
    let event: FFEventBusInClosure
    let name: String
    
    init(name: String, event: @escaping FFEventBusInClosure) {
        self.name = name
        self.event = event
    }
    
    func action(_ param: FFEventBusParams) {
        event(param)
    }
    
    deinit {
        debugPrint("[\(name)-Event] deinit")
    }
}
