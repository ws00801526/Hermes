//
//  HHRouterTests.swift
//  Hermes
//
//  Created by XMFraker on 2019/3/28.
//Copyright © 2019 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import Hermes

class HHRouterTests: QuickSpec {
    override func spec() {

        describe("basic usage") {
            
            beforeSuite {
                
                HHRouter.register("irouter://com.xmfraker.router/basic/usage/querys", handler: {
                    expect($0?["sex"] as? String) == "male"
                    expect($0?["name"] as? String) == "FrakerXM"
                })
                
                HHRouter.register("irouter://com.xmfraker.router/basic/usage/paramters", handler: {
                    expect($0?["sex"] as? String) == "male"
                    expect($0?["name"] as? String) == "FrakerXM"
                })
                
                HHRouter.register("irouter://com.xmfraker.router/basic/usage/paramters/override/querys", handler: {
                    expect($0?["sex"] as? String) == "male"
                    expect($0?["name"] as? String) == "FrakerXM"
                })
                
                HHRouter.register("irouter://com.xmfraker.router/basic/usage/completion", handler: {
                    expect($0?["sex"] as? String) == "male"
                    expect($0?["name"] as? String) == "FrakerXM"
                    
                    let info = "\(($0?["name"] as? String) ?? "")-\(($0?["sex"] as? String) ?? "")"
                    if let completion = $0?[HHRouterCompletionHandlerKey] as? HHRouterCompletionHandler { completion(info as AnyObject) }
                })
            }
            
            it("simple usage with querys", closure: {
                HHRouter.route("irouter://com.xmfraker.router/basic/usage/querys?name=FrakerXM&sex=male")
            })
            
            it("simple usage with additional paramters", closure: {
                let paramters = ["sex" : "male", "name" : "FrakerXM"]  as [String : AnyObject]
                HHRouter.route("irouter://com.xmfraker.router/basic/usage/paramters", with: paramters)
            })
            
            it("simple usage with paramters override querys", closure: {
                // name in querys will be override by paramters
                let paramters = ["sex" : "male", "name" : "FrakerXM"]  as [String : AnyObject]
                HHRouter.route("irouter://com.xmfraker.router/basic/usage/paramters/override/querys?name=XMFraker", with: paramters)
            })
            
            it("simple usage with completion", closure: {
                HHRouter.route("irouter://com.xmfraker.router/basic/usage/completion?name=FrakerXM&sex=male", completion: {
                    expect($0 as? String) == "FrakerXM-male"
                })
            })
            
            afterSuite {
                HHRouter.unregisterAll()
            }
        }
        
        describe("basic object usage") {
            
            beforeSuite {
                
                HHRouter.register("irouter://basic/object/usage/name", objectHandler: { _ -> AnyObject? in
                    return "FrakerXM" as AnyObject
                })
                
                HHRouter.register("irouter://basic/object/usage/user/sex", objectHandler: { paramters -> AnyObject? in
                    
                    if let user = paramters?["name"] as? String, user == "FrakerXM" { return "male" as AnyObject }
                    else { return "female" as AnyObject }
                })
                
                HHRouter.register("irouter://basic/object/usage/sex", objectHandler: { _ -> AnyObject? in
                    return "male" as AnyObject
                })
            }
            
            it("basic", closure: {
                
                let name = HHRouter.object(with: "irouter://basic/object/usage/name") as? String
                expect(name) == "FrakerXM"
                
                let sex = HHRouter.object(with: "irouter://basic/object/usage/sex") as? String
                expect(sex) == "male"
                
                let sex2 = HHRouter.object(with: "irouter://basic/object/usage/user/sex?name=FrakerXM") as? String
                expect(sex2) == "male"
                
                let sex3 = HHRouter.object(with: "irouter://basic/object/usage/user/sex", paramters: ["name" : "XMFraker"] as [String : AnyObject]) as? String
                expect(sex3) == "female"
            })
            
            afterSuite {
                HHRouter.unregisterAll()
            }
        }
        
        describe("advance usage with wildcard character") {
            
            beforeSuite {
                
                HHRouter.register("irouter://com.xmfraker.router/advance/*/user", handler: {
                    expect($0?["name"] as? String) == "user-after-wildcard"
                })
                
                HHRouter.register("irouter://com.xmfraker.router/advance/*", handler: {
                    expect($0?["name"] as? String) == "wildcard"
                })
                
                HHRouter.register("irouter://com.xmfraker.router/advance/assign/user", handler: {
                    expect($0?["name"] as? String) == "assign"
                })
            }
            
            it("sub path of wildcard will be matched", closure: {
                HHRouter.route("irouter://com.xmfraker.router/advance/unknown/user?name=user-after-wildcard")
            })
            
            it("unknown path will goto wildcard", closure: {
                HHRouter.route("irouter://com.xmfraker.router/advance/unknown/what/sex?name=wildcard")
            })
            
            it("assign path", closure: {
                HHRouter.route("irouter://com.xmfraker.router/advance/assign/user?name=assign")
            })
            
            afterSuite {
                HHRouter.unregisterAll()
            }
        }
        
        describe("rewrite usage") {
            
            beforeSuite {
                HHRouter.register("irouter://search", handler: {
                    expect(($0?["word"] as? String)) == "中国话"
                })
                
                HHRouter.setGlobal(handler: {
                    guard let info = $0 else { return }
                    let url = info[HHRouterURLKey] as? URL
                    expect(url) == URL(string: "https://www.baidu.com/s?wd=%E4%B8%AD%E5%9B%BD%E8%AF%9D")
                })
            }
            
            it("test rewrite", closure: {
                HHRouter.addRewrite("(?:https://)?www.baidu.com/s\\?wd=(.*)", target: "irouter://search?word=$$1")
                HHRouter.addRewrite("(?:https://)?cn.bing.com/search\\?q=(.*)", target: "irouter://search?word=$1")
                
                HHRouter.route("https://cn.bing.com/search?q=%E4%B8%AD%E5%9B%BD%E8%AF%9D")
                HHRouter.route("https://www.baidu.com/s?wd=中国话")
            })
            
            context("test rewrite after removed", closure: {
                it("test", closure: {
                    HHRouter.removeRewrite("(?:https://)?www.baidu.com/s\\?wd=(.*)")
                    HHRouter.route("https://www.baidu.com/s?wd=中国话")
                })
            })
            
            afterSuite {
                HHRouter.setGlobal(handler: nil)
                HHRouter.unregisterAll()
            }
        }

    }
}
