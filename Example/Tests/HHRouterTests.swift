//
//  RouterTests.swift
//  Hermes
//
//  Created by XMFraker on 2019/3/28.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import Hermes

class RouterTests: QuickSpec {
    override func spec() {

        describe("basic usage") {
            
            beforeSuite {
                
                Router.register("irouter://com.xmfraker.router/basic/usage/querys", handler: {
                    expect($0?["sex"] as? String) == "male"
                    expect($0?["name"] as? String) == "FrakerXM"
                })
                
                Router.register("irouter://com.xmfraker.router/basic/usage/paramters", handler: {
                    expect($0?["sex"] as? String) == "male"
                    expect($0?["name"] as? String) == "FrakerXM"
                })
                
                Router.register("irouter://com.xmfraker.router/basic/usage/paramters/override/querys", handler: {
                    expect($0?["sex"] as? String) == "male"
                    expect($0?["name"] as? String) == "FrakerXM"
                })
                
                Router.register("irouter://com.xmfraker.router/basic/usage/completion", handler: {
                    expect($0?["sex"] as? String) == "male"
                    expect($0?["name"] as? String) == "FrakerXM"
                    
                    let info = "\(($0?["name"] as? String) ?? "")-\(($0?["sex"] as? String) ?? "")"
                    if let completion = $0?[RouterCompletionHandlerKey] as? RouterCompletionHandler { completion(info as AnyObject) }
                })
            }
            
            it("simple usage with querys", closure: {
                Router.route("irouter://com.xmfraker.router/basic/usage/querys?name=FrakerXM&sex=male")
            })
            
            it("simple usage with additional paramters", closure: {
                let paramters = ["sex" : "male", "name" : "FrakerXM"]  as [String : AnyObject]
                Router.route("irouter://com.xmfraker.router/basic/usage/paramters", with: paramters)
            })
            
            it("simple usage with paramters override querys", closure: {
                // name in querys will be override by paramters
                let paramters = ["sex" : "male", "name" : "FrakerXM"]  as [String : AnyObject]
                Router.route("irouter://com.xmfraker.router/basic/usage/paramters/override/querys?name=XMFraker", with: paramters)
            })
            
            it("simple usage with completion", closure: {
                Router.route("irouter://com.xmfraker.router/basic/usage/completion?name=FrakerXM&sex=male", completion: {
                    expect($0 as? String) == "FrakerXM-male"
                })
            })
            
            afterSuite {
                Router.unregisterAll()
            }
        }
        
        describe("basic object usage") {
            
            beforeSuite {
                
                Router.register("irouter://basic/object/usage/name", objectHandler: { _ -> AnyObject? in
                    return "FrakerXM" as AnyObject
                })
                
                Router.register("irouter://basic/object/usage/user/sex", objectHandler: { paramters -> AnyObject? in
                    
                    if let user = paramters?["name"] as? String, user == "FrakerXM" { return "male" as AnyObject }
                    else { return "female" as AnyObject }
                })
                
                Router.register("irouter://basic/object/usage/sex", objectHandler: { _ -> AnyObject? in
                    return "male" as AnyObject
                })
            }
            
            it("basic", closure: {
                
                let name = Router.object(with: "irouter://basic/object/usage/name") as? String
                expect(name) == "FrakerXM"
                
                let sex = Router.object(with: "irouter://basic/object/usage/sex") as? String
                expect(sex) == "male"
                
                let sex2 = Router.object(with: "irouter://basic/object/usage/user/sex?name=FrakerXM") as? String
                expect(sex2) == "male"
                
                let sex3 = Router.object(with: "irouter://basic/object/usage/user/sex", paramters: ["name" : "XMFraker"] as [String : AnyObject]) as? String
                expect(sex3) == "female"
            })
            
            afterSuite {
                Router.unregisterAll()
            }
        }
        
        describe("advance usage with wildcard character") {
            
            beforeSuite {
                
                Router.register("irouter://com.xmfraker.router/advance/*/user", handler: {
                    expect($0?["name"] as? String) == "user-after-wildcard"
                })
                
                Router.register("irouter://com.xmfraker.router/advance/*", handler: {
                    expect($0?["name"] as? String) == "wildcard"
                })
                
                Router.register("irouter://com.xmfraker.router/advance/assign/user", handler: {
                    expect($0?["name"] as? String) == "assign"
                })
            }
            
            it("sub path of wildcard will be matched", closure: {
                Router.route("irouter://com.xmfraker.router/advance/unknown/user?name=user-after-wildcard")
            })
            
            it("unknown path will goto wildcard", closure: {
                Router.route("irouter://com.xmfraker.router/advance/unknown/what/sex?name=wildcard")
            })
            
            it("assign path", closure: {
                Router.route("irouter://com.xmfraker.router/advance/assign/user?name=assign")
            })
            
            afterSuite {
                Router.unregisterAll()
            }
        }
        
        describe("rewrite usage") {
            
            beforeSuite {
                Router.register("irouter://search", handler: {
                    expect(($0?["word"] as? String)) == "中国话"
                })
                
                Router.setGlobal(handler: {
                    guard let info = $0 else { return }
                    let url = info[RouterURLKey] as? URL
                    expect(url) == URL(string: "https://www.baidu.com/s?wd=%E4%B8%AD%E5%9B%BD%E8%AF%9D")
                })
            }
            
            it("test rewrite", closure: {
                Router.addRewrite("(?:https://)?www.baidu.com/s\\?wd=(.*)", target: "irouter://search?word=$$1")
                Router.addRewrite("(?:https://)?cn.bing.com/search\\?q=(.*)", target: "irouter://search?word=$1")
                
                Router.route("https://cn.bing.com/search?q=%E4%B8%AD%E5%9B%BD%E8%AF%9D")
                Router.route("https://www.baidu.com/s?wd=中国话")
            })
            
            context("test rewrite after removed", closure: {
                it("test", closure: {
                    Router.removeRewrite("(?:https://)?www.baidu.com/s\\?wd=(.*)")
                    Router.route("https://www.baidu.com/s?wd=中国话")
                })
            })
            
            afterSuite {
                Router.setGlobal(handler: nil)
                Router.unregisterAll()
            }
        }

    }
}
