//  HHModuleItems.swift
//  Pods
//
//  Created by  XMFraker on 2019/4/8
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      HHModuleItems

import Foundation
import UserNotifications

public struct OpenURLItem {
    
    public var url: URL
    public var options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    public var sourceApplication: String?
    public var annotation: Any?
    
    init(_ url: URL, sourceApplication: String? = nil, options: [UIApplication.OpenURLOptionsKey : Any] = [:], annotation: Any? = nil) {
        self.url = url
        self.sourceApplication = sourceApplication
        self.options = options
        self.annotation = annotation
    }
}

@available(iOS 8.0, *)
public struct UserActivityItem {
    
    public var activityType: String?
    public var activity: NSUserActivity?
    public var restorationHandler: (([UIUserActivityRestoring]?) -> Void)?
    public var error: Error?
    
    init(activityType: String? = nil, activity: NSUserActivity? = nil, restorationHandler: (([UIUserActivityRestoring]?) -> Void)? = nil, error: Error? = nil) {
        self.activityType = activityType
        self.activity = activity
        self.restorationHandler = restorationHandler
        self.error = error
    }
}

public struct NotificationItem {
    
    var deviceToken: Data?
    var error: Error?
    var userInfo: [AnyHashable : Any]?
    var completionHandler: (() -> Void)?
    
    var identifier: String?
    var responseInfo: [AnyHashable : Any]?
    var fetchCompletionHandler: ((UIBackgroundFetchResult) -> Void)?
    
    var localNotification: UILocalNotification?
    
    init(deviceToken token: Data?, error: Error? = nil) {
        self.deviceToken = token
        self.error = error
    }
}

public extension NotificationItem {
    
    init(localNotification notification: UILocalNotification) {
        self.localNotification = notification
    }
    
    init(userInfo: [AnyHashable : Any], fetch completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        self.userInfo = userInfo
        self.fetchCompletionHandler = completionHandler
    }
}

@available(iOS 8.0, *)
public extension NotificationItem {
    init(identifier: String?, userInfo: [AnyHashable : Any], responseInfo: [AnyHashable : Any]? = nil, completionHandler: @escaping (() -> Void)) {
        self.identifier = identifier
        self.userInfo = userInfo
        self.responseInfo = responseInfo
        self.completionHandler = completionHandler
    }
    
    init(identifier: String?, localNotification notificaiton: UILocalNotification, responseInfo: [AnyHashable : Any]? = nil, completionHandler: @escaping (() -> Void)) {
        self.identifier = identifier
        self.localNotification = notificaiton
        self.responseInfo = responseInfo
        self.completionHandler = completionHandler
    }
}

@available(iOS 10.0, *)
public extension NotificationItem {
    
    private struct UNNotificationKey {
        static var center: Int = 100
        static var handler: Int = 101
        static var response: Int = 102
        static var notification: Int = 103
    }
    
    typealias PresentationHandler = (UNNotificationPresentationOptions) -> Void
    
    var center: UNUserNotificationCenter? {
        get { return objc_getAssociatedObject(self, &UNNotificationKey.center) as? UNUserNotificationCenter }
        set { objc_setAssociatedObject(self, &UNNotificationKey.center, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var notification: UNNotification? {
        get { return objc_getAssociatedObject(self, &UNNotificationKey.notification) as? UNNotification }
        set { objc_setAssociatedObject(self, &UNNotificationKey.notification, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var notificationResponse: UNNotificationResponse? {
        get { return objc_getAssociatedObject(self, &UNNotificationKey.response) as? UNNotificationResponse }
        set { objc_setAssociatedObject(self, &UNNotificationKey.response, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var presentationHandler: PresentationHandler? {
        get { return objc_getAssociatedObject(self, &UNNotificationKey.handler) as? PresentationHandler }
        set { objc_setAssociatedObject(self, &UNNotificationKey.handler, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    
    internal init(center: UNUserNotificationCenter, notification: UNNotification, presentationHandler: @escaping PresentationHandler) {
        self.center = center
        self.notification = notification
        self.presentationHandler = presentationHandler
    }
    
    internal init(center: UNUserNotificationCenter, response: UNNotificationResponse, completionHandler: @escaping (() ->Void)) {
        self.center = center
        self.notificationResponse = response
        self.completionHandler = completionHandler
    }
}
