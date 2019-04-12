//  HHModuleItems.swift
//  Pods
//
//  Created by  XMFraker on 2019/4/8
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      HHModuleItems

import Foundation
import UserNotifications

public struct OpenURLItem {
    
    /// the url is opened
    public var url: URL
    /// the options of opened url
    public var options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    /// the sourceApplicaiton of opened url
    public var sourceApplication: String?
    
    init(_ url: URL, sourceApplication: String? = nil, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) {
        self.url = url
        self.sourceApplication = sourceApplication
        self.options = options
    }
}

@available(iOS 8.0, *)
public struct UserActivityItem {
    
    /// The requested activity type.
    public var activityType: String?
    /// The activity object containing the data associated with the task the user was performing. Use the data to continue the user's activity in your iOS app.
    public var activity: NSUserActivity?
    
    /// A block to execute if your app creates objects to perform the task. Calling this block is optional and you can copy this block and call it at a later time. When calling a saved copy of the block, you must call it from the app’s main thread. This block has no return value and takes the following parameter:
    ///
    /// `restorableObjects`
    ///
    /// An array of UIResponder objects representing objects you created or fetched in order to perform the operation. The system calls the restoreUserActivityState: method of each object in the array to give it a chance to perform the operation.
    public var restorationHandler: (([UIUserActivityRestoring]?) -> Void)?
    /// An error object indicating the reason for the failure.
    public var error: Error?
    
    init(activityType: String? = nil, activity: NSUserActivity? = nil, restorationHandler: (([UIUserActivityRestoring]?) -> Void)? = nil, error: Error? = nil) {
        self.activityType = activityType
        self.activity = activity
        self.restorationHandler = restorationHandler
        self.error = error
    }
}

public struct NotificationItem {
    
    
    /// A globally unique token that identifies this device to APNs. Send this token to the server that you use to generate remote notifications. Your server must pass this token unmodified back to APNs when sending those remote notifications.
    var deviceToken: Data?
    /// An NSError object that encapsulates information why registration did not succeed. The app can choose to display this information to the user.
    var error: Error?
    /// A dictionary that contains information related to the remote notification, potentially including a badge number for the app icon, an alert sound, an alert message to display to the user, a notification identifier, and custom data. 
    var userInfo: [AnyHashable : Any]?
    /// A block that you must call when you are finished performing the action.
    var completionHandler: (() -> Void)?

    /// The identifier associated with the custom action. This string corresponds to the identifier from the UILocalNotificationAction object that was used to configure the action in the local notification.
    var identifier: String?
    /// The data dictionary sent by the action.
    var responseInfo: [AnyHashable : Any]?
    /// The block to execute when the download operation is complete. When calling this block, pass in the fetch result value that best describes the results of your download operation. You must call this handler and should do so as soon as possible. For a list of possible values, see the UIBackgroundFetchResult type.
    var fetchCompletionHandler: ((UIBackgroundFetchResult) -> Void)?
    /// The local notification sent by the action
    var localNotification: UILocalNotification?
    
    init(deviceToken token: Data?, error: Error? = nil) {
        self.deviceToken = token
        self.error = error
    }
}

internal extension NotificationItem {
    
    init(localNotification notification: UILocalNotification) {
        self.localNotification = notification
    }
    
    init(userInfo: [AnyHashable : Any], fetch completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        self.userInfo = userInfo
        self.fetchCompletionHandler = completionHandler
    }
}

@available(iOS 8.0, *)
internal extension NotificationItem {
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
    /// The central object for managing notification-related activities for your app or app extension.
    var center: UNUserNotificationCenter? {
        get { return objc_getAssociatedObject(self, &UNNotificationKey.center) as? UNUserNotificationCenter }
        set { objc_setAssociatedObject(self, &UNNotificationKey.center, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    /// The notification that is about to be delivered. Use the information in this object to determine an appropriate course of action. For example, you might use the information to update your app’s interface.
    var notification: UNNotification? {
        get { return objc_getAssociatedObject(self, &UNNotificationKey.notification) as? UNNotification }
        set { objc_setAssociatedObject(self, &UNNotificationKey.notification, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// The user’s response to the notification. This object contains the original notification and the identifier string for the selected action. If the action allowed the user to provide a textual response, this parameter contains a UNTextInputNotificationResponse object.
    var notificationResponse: UNNotificationResponse? {
        get { return objc_getAssociatedObject(self, &UNNotificationKey.response) as? UNNotificationResponse }
        set { objc_setAssociatedObject(self, &UNNotificationKey.response, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// The block to execute with the presentation option for the notification. Always execute this block at some point during your implementation of this method. Use the options parameter to specify how you want the system to alert the user, if at all. This block has no return value and takes the following parameter:
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
