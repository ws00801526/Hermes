//
//  AppDelegate.swift
//  Hermes
//
//  Created by ws00801526 on 03/28/2019.
//  Copyright (c) 2019 ws00801526. All rights reserved.
//

import UIKit
import Hermes

@UIApplicationMain
class AppDelegate: Hermes.AppDelegate {

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        
        let moduleA = ModuleA()
        let moduleB = ModuleB()
        
        // register modules before call super.didFinishLaunching
        ModuleManager.register(moduleA)
        ModuleManager.register(moduleB)
        let boolean =  super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // trigger some events
        ModuleManager.trigger(.doWhat)
        
        // unregister some modules
        ModuleManager.unregister(moduleA)
        
        ModuleManager.trigger(.doWhat)
        
        
        print("moduleA \(moduleA) moduleB \(moduleB)")
        return boolean
    }
}


fileprivate extension Event {
    static let doWhat: Event = Event { (modules, context) -> Any? in
        modules.forEach {
            guard let xx = $0 as? NewModule else { return }
            xx.modDoWhat(context)
        }
        return nil
    }
}

public protocol NewModule: Module {
    func modDoWhat(_ context: Context) -> Void
}

public extension NewModule {
    func modDoWhat(_ context: Context) -> Void {
        print("modDoWhat in NewModule extension \(self)")
    }
}

class ModuleB: NSObject, Hermes.Module {
    
    var priority: Priority { return .high }
    
    func modSetup(_ context: Context) {
        print("mod setup in  \(self)")
    }
    
    func modDoWhat(_ context: Context) {
         print("modDoWhat in \(self)")
    }
}


class ModuleA: NSObject, NewModule {
    
    var isAsync: Bool { return false }
    
    func modSetup(_ context: Context) {
        print("mod setup in  \(self)")
    }

    func modDoWhat(_ context: Context) {
        print("modDoWhat in \(self)")
    }
    
}
