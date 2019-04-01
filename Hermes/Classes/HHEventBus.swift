//  HHEventBus.swift
//  Pods
//
//  Created by  XMFraker on 2019/3/28
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      HHEventBus

import Foundation

fileprivate struct CachedObserver {
    let name: String
    let observer: NSObjectProtocol
}

fileprivate var Key: Int = 101
fileprivate class DisposeBag {
    
    let name: String
    weak var observer: NSObjectProtocol?
    
    init(_ name: String, observer: NSObjectProtocol) {
        self.name = name
        self.observer = observer
    }
    
    deinit {
        if let observer = observer { HHEventBus.off(name, observer: observer) }
    }
}

public class HHEventBus {

    fileprivate static let shared = HHEventBus()
    fileprivate let queue = DispatchQueue(label: "com.xmfraker.Hermes.EventBus")
    fileprivate var caches: [UInt : [CachedObserver]] = [:]
}


////////////////////////////////////
// Publish
////////////////////////////////////

public extension HHEventBus {

    
    /// Post a event using NotificationCenter
    ///
    /// - Parameters:
    ///   - name:     event name
    ///   - sender:   event sender
    ///   - onMain:   should post on main thread
    public class func post(_ name: String, sender: Any? = nil, onMain: Bool = false) {
        
        let center = NotificationCenter.default
        let notification = Notification.Name.init(name)
        if onMain { DispatchQueue.main.async { center.post(name: notification, object: sender) } }
        else { center.post(name: notification, object: sender) }
    }

    
    /// Post a event using NotificationCenter
    ///
    /// - Parameters:
    ///   - name:     event name
    ///   - sender:   event sender
    ///   - userInfo: additional paramters
    ///   - onMain:   should post on main thread
    public class func post(_ name: String, sender: Any? = nil, userInfo: [AnyHashable : Any]?, onMain: Bool = false) {
        
        let center = NotificationCenter.default
        let notification = Notification.Name.init(name)
        if onMain { DispatchQueue.main.async { center.post(name: notification, object: sender, userInfo: userInfo) } }
        else { center.post(name: notification, object: sender, userInfo: userInfo) }
    }
    
    
    /// Post a event using NotificationQueue
    ///
    /// - Parameters:
    ///   - name:     event name
    ///   - sender:   event sender
    ///   - userInfo: additional paramters
    ///   - style:    posting style
    ///   - onMain:   should post on main thread
    public class func post(_ name: String, sender: Any? = nil, userInfo: [AnyHashable : Any]?, style: NotificationQueue.PostingStyle = .now, onMain: Bool = false) {
        
        let queue = NotificationQueue.default
        let notification = Notification(name: .init(name), object: sender, userInfo: userInfo)
        if onMain { DispatchQueue.main.async { queue.enqueue(notification, postingStyle: style) } }
        else { queue.enqueue(notification, postingStyle: style) }
    }
}

////////////////////////////////////
// Subscribe
////////////////////////////////////

public extension HHEventBus {
    
    @discardableResult
    public class func on(_ name: String, offBy target: Any? = nil, sender: Any? = nil, queue: OperationQueue? = nil, handler: @escaping ((Notification?) -> Void)) -> NSObjectProtocol {
        
        let id = UInt(bitPattern: ObjectIdentifier(name as AnyObject))
        let notification: Notification.Name = Notification.Name.init(name)
        let observer = NotificationCenter.default.addObserver(forName: notification, object: sender, queue: queue, using: handler)
        let cachedObserver = CachedObserver(name: name, observer: observer)
        
        shared.queue.sync {
            if let cachedObservers = shared.caches[id] {
                shared.caches[id] = cachedObservers + [cachedObserver]
            } else {
                shared.caches[id] = [cachedObserver]
            }
        }
        
        // support automatice remove observer after target is deinit
        if let target = target {
            if let _ = objc_getAssociatedObject(target, &Key) as? DisposeBag { return observer }
            objc_setAssociatedObject(target, &Key, DisposeBag(name, observer: observer), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        return observer
    }
    
    @discardableResult
    public class func onBackground(_ name: String, offBy target: Any? = nil, sender: Any? = nil, handler: @escaping ((Notification?) -> Void)) -> NSObjectProtocol {
        return on(name, offBy: target, sender: sender, queue: OperationQueue(), handler: handler)
    }

    public class func off(_ name: String) {
        let id = UInt(bitPattern: ObjectIdentifier(name as AnyObject))
        let center = NotificationCenter.default
        shared.queue.sync {
            if let cachedObservers = shared.caches.removeValue(forKey: id) {
                for cachedObserver in cachedObservers {
                    center.removeObserver(cachedObserver.observer)
                }
            }
        }
    }
    
    public class func off(_ name: String, observer: NSObjectProtocol) {
        let id = UInt(bitPattern: ObjectIdentifier(name as AnyObject))
        let center = NotificationCenter.default
        shared.queue.sync {
            if let cachedObservers = shared.caches[id] {
                shared.caches[id] = cachedObservers.filter({
                    if $0.observer === observer {
                        center.removeObserver(observer)
                        return false
                    }
                    return true
                })
            }
        }
    }
}

