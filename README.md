# Hermes

[![CI Status](https://img.shields.io/travis/ws00801526/Hermes.svg?style=flat)](https://travis-ci.org/ws00801526/Hermes)
[![Version](https://img.shields.io/cocoapods/v/Hermes.svg?style=flat)](https://cocoapods.org/pods/Hermes)
[![License](https://img.shields.io/cocoapods/l/Hermes.svg?style=flat)](https://cocoapods.org/pods/Hermes)
[![Platform](https://img.shields.io/cocoapods/p/Hermes.svg?style=flat)](https://cocoapods.org/pods/Hermes)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


### Router

```swift
    
    func basic() {
        
        // subscribe event with name
        HHEventBus.on("event name") { note in
            // here is notification handler
        }
        
        // subscribe event with name and handler will be executed in background
        HHEventBus.onBackground("event name") { note in
        
        }
        
        // post a note with name
        HHEventBus.post("event name")
        
        // post a note with name, if you dont need handler executed immediately
        // default coalesceMask = [.onName, .onSender]
        // so if you post a notification many times, its handler may be executed once
        
        // this may be send many times, but handler may be executed once
        HHEventBus.post("event name", style: .whenIdle)
        
        // same as HHEventBus.post("event name")
        // .now        post immediately
        // .asap       post when current scope is over
        // .whenIdle   only post when current runloop is idle
        HHEventBus.post("event name", style: .now)
        
        }
}
```

#### Basic

```swift
    func basicUsage() {

        MMRouter.register(with: "irouter://com.xmfraker.router/path/do", handler: {
            print("this is registered handler \($0 ?? [:])")
            if let completion = $0?[MMRouterCompletionHandlerKey] as? MMRouterCompletionHandler { completion(nil) }
        })

        // simple usage
        MMRouter.route("irouter://com.xmfraker.router/path/do")
        // simple usage with querys
        MMRouter.route("irouter://com.xmfraker.router/path/do?name=FrakerXM&sex=male")
        // simple usage with addtional paramters
        let paramters = ["sex" : "male", "name" : "FrakerXM", "avatar" : UIImage(named: "what") as AnyObject]  as [String : AnyObject]
        MMRouter.route("irouter://com.xmfraker.router/path/do", with: paramters)

        // simple usage with completion
        MMRouter.route("irouter://com.xmfraker.router/path/do") { _ in
            print("this is completion handler")
        }
        MMRouter.unregisterAll()
    }

    func basicObjectUsage() {

        MMRouter.register(with: "irouter://com.xmfraker/router/user", objectHandler: { _ -> AnyObject? in
            return ["name" : "FrakerXM"] as AnyObject
        })
        let object = MMRouter.object(with: "irouter://com.xmfraker/router/user")
    }
```



#### Rewrite

```swift
    func rewriteUsage() {

        // register custom search route url
        MMRouter.register(with: "irouter://action/search", handler: {
            print("will search kw \(($0?["kw"] as? String) ?? "")")
        })

        // add rewrite rule for search
        MMRouter.addRewriteRule("(?:https://)?www.baidu.com/s\\?wd=(.*)", target: "irouter://action/search?kw=$$1")
        MMRouter.addRewriteRule("(?:https://)?cn.bing.com/search\\?q=(.*)", target: "irouter://action/search?kw=$$1")

        // route origin search url, will route the rewrite url
        MMRouter.route("https://cn.bing.com/search?q=%E4%B8%AD%E5%9B%BD%E8%AF%9D")
        MMRouter.route("https://www.baidu.com/s?wd=中国话")
    }
```

**more usage see [Test Cases](https://github.com/ws00801526/Hermes/blob/master/Example/Tests/HHRouterTests.swift)**


## Installation

Hermes is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Hermes' // use all sub specs such as router,event bus
pod 'Hermes/EventBus' // just use event bus 
pod 'Hermes/Router'   // just use router
```

## Author

ws00801526, 3057600441@qq.com

## License

Hermes is available under the MIT license. See the LICENSE file for more info.
