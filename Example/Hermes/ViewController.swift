//
//  ViewController.swift
//  Hermes
//
//  Created by ws00801526 on 03/28/2019.
//  Copyright (c) 2019 ws00801526. All rights reserved.
//

import UIKit
import Hermes

class TestObject: NSObject {
    deinit {
        print("i am testobject deinit")
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        HHEventBus.post("xxxx")
//
////        HHEventBus.on(self, name: "xxxx") {
////            print("i subscribe xxxx event \($0?.userInfo) on thread \(Thread.current)")
////        }
//
//        HHEventBus.onBackground(self, name: "xxxx") {
//            print("i subscribe xxxx event on background \($0?.userInfo) on thread \(Thread.current)")
//        }
//
////        HHEventBus.post("xxxx")
//        HHEventBus.post("xxxx", userInfo: ["from" : "eventBus"])
//
//        let name = Notification.Name.init("xxxx")
//
//        for _ in 0...10 {
//            let notification = Notification(name: name, userInfo: ["from" : "whenIdle"])
//            NotificationQueue.default.enqueue(notification, postingStyle: .whenIdle)
//        }
//
////        DispatchQueue.main.async {
////            let notification = Notification(name: name, userInfo: ["from" : "asap on main queue"])
////            NotificationQueue.default.enqueue(notification, postingStyle: .now)
////        }
//
//        DispatchQueue.global().async {
//            let notification = Notification(name: name, userInfo: ["from" : "now on global queue"])
//            NotificationQueue.default.enqueue(notification, postingStyle: .now)
//        }
        
        let testObject = TestObject()
        
        HHEventBus.on("xxxx") { _ in
            print("here is testObject ")
        }
        
        HHEventBus.on("xxxx", offBy: testObject, sender: nil, queue: nil) { _ in
            print("here is testObject with test")
        }

        HHEventBus.post("xxxx")
        
//        NotificationCenter.default.removeObserver(observer)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            HHEventBus.post("xxxx")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
