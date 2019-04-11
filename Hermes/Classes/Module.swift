//  HHModule.swift
//  Pods
//
//  Created by  XMFraker on 2019/4/4
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      HHModule

import Foundation

public enum Priority: UInt {
    case low = 100
    case `default` = 750
    case `high` = 1000
}

public protocol Module: NSObjectProtocol {
    
    var priority: Priority { get }
    var isAsync : Bool     { get }
    
    ////////////////////////////////////
    // App Life Cycle
    ////////////////////////////////////
    
    func modInit(_ context: Context)
    func modSplash(_ context: Context)
    
    func modWillEnterForeground(_ context: Context)
    func modDidBecomeActive(_ context: Context)
    
    func modWillResignActive(_ context: Context)
    func modDidEnterBackground(_ context: Context)
    
    func modWillTerminate(_ context: Context)
    
    ////////////////////////////////////
    // App Special Events
    ////////////////////////////////////

    func modDidReceiveMemoryWarning(_ context: Context)
    
    func modSignificantTimeChange(_ context: Context)

    func modOpenURL(_ context: Context) -> Bool

    ////////////////////////////////////
    // App User Activity Events
    ////////////////////////////////////

    func modWillContinueUserActivity(_ context: Context) -> Bool
    func modContinueUserActivity(_ context: Context) -> Bool
    func modDidUpdateUserActivity(_ context: Context)
    func modDidFailToContinueUserActivity(_ context: Context)

    ////////////////////////////////////
    // App Notification
    ////////////////////////////////////
    
    func modDidRegisterRemoteNotifications(_ context: Context)
    func modDidFailToRegisterRemoteNotifications(_ context: Context)
    func modDidReceiveRemoteNotification(_ context: Context)
    func modDidReceiveLocalNotification(_ context: Context)
    
    /// Determind notification perform style when application is in foreground
    ///
    /// if you want show notification when application is in foreground, perform handler([.alert, .none])
    ///
    /// if you want do nothing, just perform handler([.none])
    /// - Parameter context: application context
    @available(iOS 10.0, *)
    func modWillPresentNotification(_ context: Context)
    
    /// Called when your app has been activated by the user selecting an action from a notification.
    /// A nil action identifier indicates the default action.
    /// You should call the completion handler as soon as you've finished handling the action.
    ///
    /// - Parameter context: application context
    @available(iOS 8.0, *)
    func modDidReceiveNotificationResponse(_ context: Context)
}

open class AppDelegate: UIResponder, UIApplicationDelegate {
    
    open var window: UIWindow?
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        if #available(iOS 10, *) { UNUserNotificationCenter.current().delegate = self }
        
        ModuleManager.shared.context.applicaiton = application
        ModuleManager.shared.context.launchOptions = launchOptions
        ModuleManager.trigger(.setup)
        
        DispatchQueue.main.async { ModuleManager.trigger(.splash) }
        
        return true
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
        ModuleManager.trigger(.didBecomeActive)
    }
    
    open func applicationWillResignActive(_ application: UIApplication) {
        ModuleManager.trigger(.willResignActive)
    }
    
    open func applicationDidEnterBackground(_ application: UIApplication) {
        ModuleManager.trigger(.didEnterBackground)
    }
    
    open func applicationWillEnterForeground(_ application: UIApplication) {
        ModuleManager.trigger(.willEnterForeground)
    }
    
    open func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        ModuleManager.trigger(.didReceiveMemoryWarning)
    }
    
    open func applicationWillTerminate(_ application: UIApplication) {
        ModuleManager.trigger(.willTerminate)
    }

    open func applicationSignificantTimeChange(_ application: UIApplication) {
        ModuleManager.trigger(.significantTimeChange)
    }
    
    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        ModuleManager.shared.context.notificationItem = NotificationItem(deviceToken: deviceToken)
        ModuleManager.trigger(.willTerminate)
    }
    
    open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        ModuleManager.shared.context.notificationItem = NotificationItem(deviceToken: nil, error: error)
        ModuleManager.trigger(.didFailToRegisterForRemoteNotification)
    }
    
    @available(iOS, introduced: 3.0, deprecated: 10.0)
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        ModuleManager.shared.context.notificationItem = NotificationItem(userInfo: userInfo)
        ModuleManager.trigger(.didReceiveRemoteNotification)
    }
    
    @available(iOS, introduced: 4.0, deprecated: 10.0)
    open func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        ModuleManager.shared.context.notificationItem = NotificationItem(localNotification: notification)
        ModuleManager.trigger(.didReceiveLocalNotification)
    }
    
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        ModuleManager.shared.context.notificationItem = NotificationItem(userInfo: userInfo, fetch: completionHandler)
        ModuleManager.trigger(.didReceiveRemoteNotification)
    }
    
    @available(iOS, introduced: 8.0, deprecated: 10.0)
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {

        ModuleManager.shared.context.notificationItem = NotificationItem(identifier: identifier, localNotification: notification, completionHandler: completionHandler)
        ModuleManager.trigger(.didReceiveNotificationResponse)
    }
    
    @available(iOS, introduced: 9.0, deprecated: 10.0)
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        
        let item = NotificationItem(identifier: identifier, localNotification: notification, responseInfo: responseInfo, completionHandler: completionHandler)
        ModuleManager.shared.context.notificationItem = item
        ModuleManager.trigger(.didReceiveNotificationResponse)
    }
    
    @available(iOS, introduced: 8.0, deprecated: 10.0)
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        ModuleManager.shared.context.notificationItem = NotificationItem(identifier: identifier, userInfo: userInfo, completionHandler: completionHandler)
        ModuleManager.trigger(.didReceiveNotificationResponse)
    }
    
    @available(iOS, introduced: 9.0, deprecated: 10.0)
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        let item = NotificationItem(identifier: identifier, userInfo: userInfo, responseInfo: responseInfo, completionHandler: completionHandler)
        ModuleManager.shared.context.notificationItem = item
        ModuleManager.trigger(.didReceiveNotificationResponse)
    }
    
    @available(iOS, introduced: 2.0, deprecated: 9.0)
    open func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        ModuleManager.shared.context.openURLItem = OpenURLItem(url)
        ModuleManager.trigger(.openURL)
        return true
    }
    
    @available(iOS 9.0, *)
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ModuleManager.shared.context.openURLItem = OpenURLItem(url, options: options)
        ModuleManager.trigger(.openURL)
        return true
    }
    
    @available(iOS, introduced: 4.2, deprecated: 9.0)
    open func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        ModuleManager.shared.context.openURLItem = OpenURLItem(url, sourceApplication: sourceApplication, annotation: annotation)
        if let succ = ModuleManager.trigger(.openURL) as? Bool { return succ }
        return false
    }
    
    @available(iOS 8.0, *)
    open func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        
        ModuleManager.shared.context.userActivityItem = UserActivityItem(activityType: userActivityType)
        if let succ = ModuleManager.trigger(.openURL) as? Bool { return succ }
        return false
    }
    
    @available(iOS 8.0, *)
    open func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
     
        ModuleManager.shared.context.userActivityItem = UserActivityItem(activityType: userActivityType, error: error)
        ModuleManager.trigger(.didFailToContinueUserActivity)
    }
    
    @available(iOS 8.0, *)
    open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        ModuleManager.shared.context.userActivityItem = UserActivityItem(activity: userActivity, restorationHandler: restorationHandler)
        if let succ = ModuleManager.trigger(.openURL) as? Bool { return succ }
        return false
    }
    
    @available(iOS 8.0, *)
    open func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        ModuleManager.shared.context.userActivityItem = UserActivityItem(activity: userActivity)
        ModuleManager.trigger(.didUpdateUserActivity)
    }
}

import UserNotifications
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        ModuleManager.shared.context.notificationItem = NotificationItem(center: center, notification: notification, presentationHandler: completionHandler)
        ModuleManager.trigger(.willPresentNotification)
    }
    
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        ModuleManager.shared.context.notificationItem = NotificationItem(center: center, response: response, completionHandler: completionHandler)
        ModuleManager.trigger(.didReceiveNotificationResponse)
    }
}

public struct Context {
    
    var applicaiton: UIApplication = UIApplication.shared
    var launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    var userInfo: [AnyHashable : Any]?
    
    var openURLItem: OpenURLItem?
    var notificationItem: NotificationItem?

    var userActivityItem: UserActivityItem?
}

public struct Event: RawRepresentable {
    public var rawValue: RawValue
    public typealias RawValue = ([Module], Context) -> Any?
    public init(rawValue: @escaping Event.RawValue) { self.rawValue = rawValue }
    
    public static let openURL: Event = Event { (modules, context) -> Any in
        return modules.reduce(into: false) { $0 = $0 || $1.modOpenURL(context) }
    }
}

public class ModuleManager {
    
    var modules: [Module] = []
    var context: Context = Context()
    public static let shared = ModuleManager()
    
    public class func register(_ module: Module) {
        
        shared.modules.append(module)
        shared.modules.sort(by: { $0.priority.rawValue >= $1.priority.rawValue })
    }
    
    public class func unregister(_ module: Module) {
        shared.modules.removeAll(where:  { $0.isEqual(module) })
    }

    @discardableResult
    public class func trigger(_ event: Event, userInfo: [AnyHashable : Any]? = nil) -> Any? {
        
        var context = shared.context
        context.userInfo = userInfo
        return event.rawValue(shared.modules, context) as Any
    }
}

public extension Event {

    static let setup: Event = Event(rawValue: { (modules, context) -> Any? in
        modules.filter { !$0.isAsync }.forEach { $0.modInit(context) }
        DispatchQueue.main.async { modules.filter { $0.isAsync }.forEach { $0.modInit(context) } }
        return nil
    })
    
    static let splash: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modSplash(context) }
        return nil
    }
    
    static let didBecomeActive: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modDidBecomeActive(context) }
        return nil
    }

    static let willResignActive: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modWillResignActive(context) }
        return nil
    }

    static let didEnterBackground: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modDidEnterBackground(context) }
        return nil
    }

    static let willEnterForeground: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modWillEnterForeground(context) }
        return nil
    }

    static let willTerminate: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modWillTerminate(context) }
        return nil
    }

    static let didReceiveMemoryWarning: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modDidReceiveMemoryWarning(context) }
        return nil
    }

    static let significantTimeChange: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modSignificantTimeChange(context) }
        return nil
    }
}

public extension Event {

    static let didRegisterRemoteNotification: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modDidRegisterRemoteNotifications(context) }
        return nil
    }
    
    static let didFailToRegisterForRemoteNotification: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modDidFailToRegisterRemoteNotifications(context) }
        return nil
    }

    static let didReceiveRemoteNotification: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modDidReceiveRemoteNotification(context) }
        return nil
    }
    
    static let didReceiveLocalNotification: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modDidReceiveLocalNotification(context) }
        return nil
    }

    @available(iOS 10.0, *)
    static let willPresentNotification: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modWillPresentNotification(context) }
        return nil
    }
    
    @available(iOS 8.0, *)
    static let didReceiveNotificationResponse: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modDidReceiveNotificationResponse(context) }
        return nil
    }
}

public extension Event {
    
    static let willContinueUserActivity: Event = Event { (modules, context) -> Any? in
        return modules.reduce(into: false) { $0 = $0 || $1.modWillContinueUserActivity(context) }
    }
    
    static let continueUserActivity: Event = Event { (modules, context) -> Any? in
        return modules.reduce(into: false) { $0 = $0 || $1.modContinueUserActivity(context) }
    }

    static let didFailToContinueUserActivity: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modDidFailToContinueUserActivity(context) }
        return nil
    }

    static let didUpdateUserActivity: Event = Event { (modules, context) -> Any? in
        modules.forEach { $0.modDidUpdateUserActivity(context) }
        return nil
    }
}

/// using extension to implementation optional methods
public extension Module {
    
    var isAsync:  Bool { return false }
    var priority: Priority { return .default }

    ////////////////////////////////////
    // App Life Cycle
    ////////////////////////////////////
    
    func modInit(_ context: Context) {}
    func modSplash(_ context: Context) {}
    
    func modWillEnterForeground(_ context: Context) {}
    func modDidBecomeActive(_ context: Context) {}
    
    func modWillResignActive(_ context: Context) {}
    func modDidEnterBackground(_ context: Context) {}
     
    func modWillTerminate(_ context: Context) {}
    func modDidReceiveMemoryWarning(_ context: Context) {}
    func modSignificantTimeChange(_ context: Context) {}
    
    ////////////////////////////////////
    // App Special Events
    ////////////////////////////////////
    
    func modOpenURL(_ context: Context) -> Bool  { return false }
    func modWillContinueUserActivity(_ context: Context) -> Bool { return false }
    func modContinueUserActivity(_ context: Context) -> Bool { return false }
    func modDidUpdateUserActivity(_ context: Context) {}
    func modDidFailToContinueUserActivity(_ context: Context) {}

    ////////////////////////////////////
    // App Notification
    ////////////////////////////////////
    
    func modDidRegisterRemoteNotifications(_ context: Context) {}
    func modDidFailToRegisterRemoteNotifications(_ context: Context) {}
    func modDidReceiveRemoteNotification(_ context: Context) {}
    func modDidReceiveLocalNotification(_ context: Context) {}
    
    @available(iOS 10.0, *)
    func modWillPresentNotification(_ context: Context) { }
    @available(iOS 8.0, *)
    func modDidReceiveNotificationResponse(_ context: Context) {}
}
