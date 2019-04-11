//  EventBus.swift
//  Pods
//
//  Created by  XMFraker on 2019/3/28
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      EventBus

import Foundation

fileprivate struct CachedObserver {
    let name: String
    let observer: NSObjectProtocol
}

fileprivate var Key: Int = 101
public class DisposeBag {
    
    let name: String
    weak var observer: NSObjectProtocol?
    
    init(_ name: String, observer: NSObjectProtocol) {
        self.name = name
        self.observer = observer
    }
    
    public func dispose() {
        if let observer = observer { EventBus.off(name, observer: observer) }
    }
    
    deinit {
        dispose()
    }
}

public class EventBus {

    fileprivate static let shared = EventBus()
    fileprivate let queue = DispatchQueue(label: "com.xmfraker.Hermes.EventBus")
    fileprivate var caches: [UInt : [CachedObserver]] = [:]
}


////////////////////////////////////
// Publish
////////////////////////////////////

public extension EventBus {
    
    /// Post a event using NotificationQueue
    ///
    /// - Parameters:
    ///   - name:     event name
    ///   - sender:   event sender
    ///   - userInfo: additional paramters
    class func post(_ name: String, sender: Any? = nil, userInfo: [AnyHashable : Any]?) {
        post(name, sender: sender, userInfo: userInfo, style: .now)
    }
    
    /// Post a event using NotificationQueue
    ///
    /// - Parameters:
    ///   - name:     event name
    ///   - style:    posting style
    class func post(_ name: String, style: NotificationQueue.PostingStyle = .now) {
        post(name, sender: nil, userInfo: nil, style: style)
    }

    /// Post a event using NotificationQueue
    ///
    /// - Parameters:
    ///   - name:   event name
    ///   - sender: event sender
    ///   - userInfo: additional paramters
    ///   - style: posting style.
    ///   - coalesceMask: default is [.onName, .onSender]
    ///   - modes: default is [.defaultRunLoopMode]
    class func post(_ name: String, sender: Any?, userInfo: [AnyHashable : Any]?, style: NotificationQueue.PostingStyle, coalesceMask: NotificationQueue.NotificationCoalescing = [.onName, .onSender], forModes modes: [RunLoop.Mode]? = nil) {

        let queue = NotificationQueue.default
        let notification = Notification(name: .init(name), object: sender, userInfo: userInfo)
        queue.enqueue(notification, postingStyle: style, coalesceMask: coalesceMask, forModes: modes)
    }
}

////////////////////////////////////
// Subscribe
////////////////////////////////////

public extension EventBus {
    
    
    /// Subscribe a event notfication
    ///
    /// - Parameters:
    ///   - name:       notification name
    ///   - target:     observer will be disposed by object
    ///   - sender:     notification sender
    ///   - queue:      the queue will execute the handler. If you pass nil, the block is run synchronously on the posting thread.
    ///   - handler:    the handler
    /// - Returns: the dispose bag, call bag.dispose() will remove observer
    @discardableResult
    class func on(_ name: String, offBy target: Any? = nil, sender: Any? = nil, queue: OperationQueue? = nil, handler: @escaping ((Notification?) -> Void)) -> DisposeBag {
        
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
        
        let disposeBag = DisposeBag(name, observer: observer)
        // support automatice remove observer after target is deinit
        if let target = target {
            let pointer = withUnsafePointer(to: &Key) { $0 }
            if let bag = objc_getAssociatedObject(target, pointer) as? DisposeBag { return bag }
            objc_setAssociatedObject(target, &Key, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        return disposeBag
    }
    
    
    /// Subscribe a event and handler will be executed in background thread
    ///
    /// - Parameters:
    ///   - name:       notification name
    ///   - target:     observer will be disposed by object
    ///   - sender:     notification sender
    ///   - handler:    the handler
    /// - Returns: the dispose bag, call bag.dispose() will remove observer
    @discardableResult
    class func onBackground(_ name: String, offBy target: Any? = nil, sender: Any? = nil, handler: @escaping ((Notification?) -> Void)) -> DisposeBag {
        return on(name, offBy: target, sender: sender, queue: OperationQueue(), handler: handler)
    }
    
    /// unsubscribe event by name
    /// will unsubscribe all observers with the same name
    /// - Parameter name: the name of event
    class func off(_ name: String) {
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
    
    
    /// unsubscribe event by name and observer
    ///
    /// - Parameters:
    ///   - name:       the name of event
    ///   - observer:   he subscribed observer
    class func off(_ name: String, observer: NSObjectProtocol) {
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

