//
//  Promise.swift
//  BDI_iOS
//
//  Created by ControlPoint on 08/04/2016.
//  Copyright © 2016 ControlPointLLP. All rights reserved.
//

public typealias Resolve = (Any?) -> ()
public typealias Reject = (Any?) -> ()

protocol IPromise: class {
    func perform()
    func perform(resultFromPreviousPromise result: Any?)
    func reject(_ error: Any?)
}

public class Promise: IPromise {
    fileprivate var m_object: Any?
    fileprivate var m_promisedTask: (Any?, @escaping Resolve, @escaping Reject) -> ()
    
    // cannot use generics in the protocol due to this part!
    // cannot keep an array the IPromise could have many different generic types
    fileprivate var m_nextPromises = [IPromise]()
    fileprivate var m_reject: Reject?
    
    public init(promisedTask: @escaping (Any?, @escaping Resolve, @escaping Reject) -> ()) {
        m_promisedTask = promisedTask
    }
    
    public func perform() {
        perform(resultFromPreviousPromise: nil)
    }
    
    public func perform(resultFromPreviousPromise result: Any?) {
        if let object = m_object {
            m_nextPromises.forEach({$0.perform(resultFromPreviousPromise: object)})
        }
        else {
            //strong reference to these so even if this promise is deinit we can continue
            let nextPromises = m_nextPromises
            
            m_promisedTask(result, {
                [weak self]
                (taskResult) in
                self?.m_object = taskResult
                nextPromises.forEach({
                    $0.perform(resultFromPreviousPromise: taskResult)
                })
                }, reject)
        }
    }
    
    @discardableResult public func iff(_ predicate: @escaping (Any?) -> Bool) -> ConditionalPromise {
        let promise = ConditionalPromise(predicate: predicate)
        m_nextPromises.append(promise)
        return promise
    }
    
    @discardableResult public func elseIff(_ predicate: @escaping (Any?) -> Bool) -> ConditionalPromise {
        return iff(predicate)
    }
    
    @discardableResult public func then(_ callback: @escaping (Any?, @escaping Resolve, @escaping Reject) -> ()) -> Promise {
        let promise = Promise(promisedTask: callback)
        m_nextPromises.append(promise)
        return promise
    }
    
    @discardableResult public func then(_ promise: Promise) -> Promise {
        m_nextPromises.append(promise)
        return promise
    }
    
    @discardableResult public func error(_ reject: @escaping Reject) -> Promise {
        m_reject = reject
        return self
    }
    
    public func reject(_ error: Any?) {
        if let rejectAction = m_reject {
            rejectAction(error)
        }
        else {
            m_nextPromises.forEach({$0.reject(error)})
        }
    }
}

public class ConditionalPromise: IPromise {
    fileprivate var m_ifPredicate: (Any?) -> Bool
    fileprivate var m_nextPromises = [IPromise]()
    fileprivate var m_reject: Reject?
    
    init(predicate: @escaping (Any?) -> Bool) {
        m_ifPredicate = predicate
    }
    
    @discardableResult public func then(_ callback: @escaping (Any?, @escaping Resolve, @escaping Reject) -> ()) -> Promise {
        let promise = Promise(promisedTask: callback)
        m_nextPromises.append(promise)
        return promise
    }
    
    public func perform() {
        if m_ifPredicate(nil) {
            m_nextPromises.forEach({$0.perform(resultFromPreviousPromise: nil)})
        }
    }
    
    public func perform(resultFromPreviousPromise result: Any?) {
        if m_ifPredicate(result) {
            m_nextPromises.forEach({$0.perform(resultFromPreviousPromise: result)})
        }
    }
    
    @discardableResult public func error(_ reject: @escaping Reject) -> ConditionalPromise {
        m_reject = reject
        return self
    }
    
   public func reject(_ error: Any?) {
        if let rejectAction = m_reject {
            rejectAction(error)
        }
        else {
            m_nextPromises.forEach({$0.reject(error)})
        }
    }
}
