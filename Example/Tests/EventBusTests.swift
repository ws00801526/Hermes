//
//  EventBusTests.swift
//  Hermes
//
//  Created by XMFraker on 2019/4/1.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import Hermes


class Bag {
    
}

class EventBusTests: QuickSpec {
    override func spec() {

        
        describe("basic usage") {
            
            it("basic on & automatic off", closure: {
                
                var basicCount = 0
                var basicAutoCount = 0
                var basicManualCount = 0
                var bag: Bag? = Bag()

                EventBus.on("basic") { _ in
                    // this should receive over one time
                    print("here is basic")
                    basicCount += 1
                }
                
                EventBus.on("basic", offBy: bag) { _ in
                    // this should only receive one time
                    print("here is basic with automatic remove observer")
                    basicAutoCount += 1
                }
                
                let observer = EventBus.on("basic", handler: { _ in
                    print("here is basic with manually remove observer")
                    basicManualCount += 1
                })
                
                EventBus.post("basic")
                
                bag = nil
                NotificationCenter.default.removeObserver(observer)
                EventBus.post("basic")

                expect(basicCount).toEventually(equal(2))
                expect(basicAutoCount).toEventually(equal(1))
                expect(basicManualCount).toEventually(equal(1))
            })
            
            
            context("queue", closure: {
                
                var queue = 0
                afterEach {
                    queue = 0
                }
                
                beforeSuite {
                    EventBus.on("queue", handler: { _ in
                        print("here is queue")
                        queue += 1
                    })
                }
                
                it("test with queue", closure: {
                    for _ in 0...10 {
                        EventBus.post("queue", style: .whenIdle)
                    }
                    expect(queue).toEventually(equal(1))
                })
                
                it("test without queue", closure: {
                    for _ in 0...10 {
                        EventBus.post("queue")
                    }
                    expect(queue).to(equal(11))
                })
                
            })
        }
    }
}
