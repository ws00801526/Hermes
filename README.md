# Hermes

[![Build Status](https://travis-ci.com/ws00801526/Hermes.svg?branch=master)](https://travis-ci.com/ws00801526/Hermes)
[![Version](https://img.shields.io/cocoapods/v/Hermes.svg?style=flat)](https://cocoapods.org/pods/Hermes)
[![License](https://img.shields.io/cocoapods/l/Hermes.svg?style=flat)](https://cocoapods.org/pods/Hermes)
[![Platform](https://img.shields.io/cocoapods/p/Hermes.svg?style=flat)](https://cocoapods.org/pods/Hermes)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

###  Event Bus

```swift

func basic() {

// subscribe event with name
HHEventBus.on("event name") { note in
// here is notification handler
}.dispose(by: someTarget)

// subscribe event with name and handler will be executed in background
HHEventBus.onBackground("event name") { note in

}.dispose(by: someTarget)

// post a note with name
HHEventBus.post("event name")

// post a note with name, if you dont need handler executed immediately
// default coalesceMask = [.onName, .onSender]
// so if you post a notification many times, its handler may be executed once

// this may be send many times, but handler may be executed once
HHEventBus.post("event name", style: .whenIdle)

// same as HHEventBus.post("event name")
// .now        post immediately
// .asap       post after notifications is coalesced
// .whenIdle   only post when current runloop is idle
HHEventBus.post("event name", style: .now)

}
}
```


### Router

#### Basic

```swift
    func basicUsage() {

        HHRouter.register(with: "irouter://com.xmfraker.router/path/do", handler: {
            print("this is registered handler \($0 ?? [:])")
            if let completion = $0?[HHRouterCompletionHandlerKey] as? HHRouterCompletionHandler { completion(nil) }
        })

        // simple usage
        HHRouter.route("irouter://com.xmfraker.router/path/do")
        // simple usage with querys
        HHRouter.route("irouter://com.xmfraker.router/path/do?name=FrakerXM&sex=male")
        // simple usage with addtional paramters
        let paramters = ["sex" : "male", "name" : "FrakerXM", "avatar" : UIImage(named: "what") as AnyObject]  as [String : AnyObject]
        HHRouter.route("irouter://com.xmfraker.router/path/do", with: paramters)

        // simple usage with completion
        HHRouter.route("irouter://com.xmfraker.router/path/do") { _ in
            print("this is completion handler")
        }
        HHRouter.unregisterAll()
    }

    func basicObjectUsage() {

        HHRouter.register(with: "irouter://com.xmfraker/router/user", objectHandler: { _ -> AnyObject? in
            return ["name" : "FrakerXM"] as AnyObject
        })
        let object = HHRouter.object(with: "irouter://com.xmfraker/router/user")
    }
```



#### Rewrite

```swift
    func rewriteUsage() {

        // register custom search route url
        HHRouter.register(with: "irouter://action/search", handler: {
            print("will search kw \(($0?["kw"] as? String) ?? "")")
        })

        // add rewrite rule for search
        HHRouter.addRewriteRule("(?:https://)?www.baidu.com/s\\?wd=(.*)", target: "irouter://action/search?kw=$$1")
        HHRouter.addRewriteRule("(?:https://)?cn.bing.com/search\\?q=(.*)", target: "irouter://action/search?kw=$$1")

        // route origin search url, will route the rewrite url
        HHRouter.route("https://cn.bing.com/search?q=%E4%B8%AD%E5%9B%BD%E8%AF%9D")
        HHRouter.route("https://www.baidu.com/s?wd=中国话")
    }
```

**more usage see [Test Cases](https://github.com/ws00801526/Hermes/blob/master/Example/Tests/HHRouterTests.swift)**



### Module

```swift

/// implement youd appdelegate inherited from Hermes.AppDelegate
@UIApplicationMain
class AppDelegate: Hermes.AppDelegate {

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {

        // register your module before called super.application(application, didFinishLaunchingWithOptions: launchOptions)
        ModuleManager.register(ModuleImpl())
        let boolean =  super.application(application, didFinishLaunchingWithOptions: launchOptions)
        ModuleManager.trigger(.doWhat)
        // unregister module if needed
        ModuleManager.unregister(moduleA)
        return boolean
    }
}

class ModuleA: Hermes.Module {
    
    // implement func if you needed
    func modInit(_ context: Context) {
        // will be called in applicationDidFinishLaunched
    }
}

// if you need some more mod func
protocol NewModule: Module {
    // declare a new method
    func newModuleFunc() -> Void
}

// provid default implementation of newModuleFunc
public extension NewModule {
    func newModuleFunc() -> Void { print("\(function) in NewModule extension")}
}

public extension Event {
    static let newEvent: Event  = Event { modules, context -> Any? in
        modules.forEach {
            // cast $0 from Module to NewModule 
            guard let module = $0 as? NewModule else { return }
            module.newModuleFunc(context)
        }
    }
}

```



## Installation

Hermes is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Hermes' // use all sub specs such as router,event bus
pod 'Hermes/EventBus' // just use eventbus
pod 'Hermes/Router'   // just use router
pod 'Hermes/Module'   // just use module
```

## Author

ws00801526, 3057600441@qq.com

## License

Hermes is available under the MIT license. See the LICENSE file for more info.
