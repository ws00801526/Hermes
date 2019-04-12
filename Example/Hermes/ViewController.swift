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

    var testObject2: TestObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        HHEventBus.on("simple") {
            print("simple \($0?.userInfo)")
        }
        

//        DispatchQueue.global().async {
//            HHEventBus.post("simple", sender: nil, userInfo: ["xxxx" : "asap"], style: .asap, onMain: false)
//        }
        
        HHEventBus.post("simple", sender: nil, userInfo: ["xxxx" : "asap"], style: .asap, coalesceMask: [.none])
        EventBus.on("simple") { print("simple \($0?.userInfo ?? [:])") }.dispose(by: label)
        EventBus.on("simple2") { print("simple2 \($0?.userInfo ?? [:])") }.dispose(by: label)

        EventBus.post("simple", sender: nil, userInfo: ["xxxx" : "asap"], style: .asap, coalesceMask: [.none])
        
        EventBus.post("simple", sender: nil, userInfo: ["xxxx" : "now"], style: .now, coalesceMask: [.none])

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            EventBus.post("simple2", sender: nil, userInfo: ["xxxx" : "asap"], style: .now, coalesceMask: [.none])
            EventBus.post("simple", sender: nil, userInfo: ["xxxx" : "asap"], style: .now, coalesceMask: [.none])
            
            label.removeFromSuperview()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                print("label is removefrom from superView ")
                EventBus.post("simple2", sender: nil, userInfo: ["xxxx" : "asap"], style: .now, coalesceMask: [.none])
                EventBus.post("simple", sender: nil, userInfo: ["xxxx" : "asap"], style: .now, coalesceMask: [.none])
            })
        }
        
//        print("before sleep")
//        sleep(200)
//        print("after sleep")
//        HHEventBus.post("simple", sender: nil, userInfo: ["xxxx" : "now"], style: .now, onMain: false)
//
//        HHEventBus.post("simple", sender: nil, userInfo: ["xxxx" : "whenIdle"], style: .whenIdle, onMain: false)

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
        

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
