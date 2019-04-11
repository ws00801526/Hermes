//  Router.swift
//  Pods
//
//  Created by  XMFraker on 2019/3/28
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      Router

public typealias RouterHandler = ([String : AnyObject]?) -> Void
public typealias RouterObjectHandler = ([String : AnyObject]?) -> AnyObject?
public typealias RouterCompletionHandler = (AnyObject?) -> Void


/// get URL from handler.userInfo. the object Class should be URL or NSURL
public let RouterURLKey                 = "RouterURLKey"
/// get completion handler from handler.userInfo
public let RouterCompletionHandlerKey   = "RouterCompletionHandlerKey"
public let RouterURLWildcardCharacter   = "*"

class Route {
    
    var path: String?
    var handler: RouterHandler?
    var objectHandler: RouterObjectHandler?
    weak var parent: Route?
    var subRoutes: [String : Route] = [:]
    
    init(path: String? = nil, parent route: Route? = nil) {
        self.path = path
        self.parent = route
    }
    
    func clear() {
        // the route has not subroutes, we should consider remove it
        if subRoutes.isEmpty, let path = path, let parent = parent {
            parent.subRoutes.removeValue(forKey: path)
        }
    }
}

public class Router {
    
    public static let shared = Router()
    
    // using concurrent barrier for thread safe
    let queue = DispatchQueue.init(label: "com.xmfraker.Hermes.Router", attributes: .concurrent)
    lazy var rules: [String : String] = [:]
    lazy var routes: Route = Route()
    
    func addRoute(with url: URL, handler: @escaping RouterHandler) {
        
        // just using barrier for write opeation
        queue.async(flags: .barrier) { [unowned self] in
            guard let route = self.createRoutes(of: url) else { return }
            route.handler = handler
        }
    }
    
    func addObjectRoute(with url: URL, handler: @escaping RouterObjectHandler) {
        
        // just using barrier for write opeation
        queue.async(flags: .barrier) { [unowned self] in
            guard let route = self.createRoutes(of: url)   else { return }
            route.objectHandler = handler
        }
    }
    
    func getRoutes() -> Route? {
        return queue.sync { routes }
    }
    
    func removeRoute(with url: URL) {
        
        queue.async(flags: .barrier) { [unowned self] in
            guard let route = self.createRoutes(of: url)   else { return }
            route.handler = nil
            route.objectHandler = nil
            
            // clear subRoutes if needed
            var parent: Route? = route
            while parent != nil {
                parent?.clear()
                parent = parent?.parent
            }
        }
    }
    
    func removeRoutes() {
        queue.async(flags: .barrier) { [unowned self] in
            self.routes.subRoutes.removeAll()
        }
    }
    
    func addRewrite(rule: String, target: String) {
        
        guard rule.count > 0   else { return }
        guard target.count > 0 else { return }
        
        queue.async(flags: .barrier) { [unowned self] in
            self.rules[rule] = target
        }
    }
    
    func removeRewrite(rule: String) {
        guard rule.count > 0 else { return }
        queue.async(flags: .barrier) { [unowned self] in
            self.rules.removeValue(forKey: rule)
        }
    }
}


extension Router {
    
    func mergeQueryItems(of url: URL, with paramters: [String : AnyObject]) -> [String : AnyObject] {
        
        var result: [String : AnyObject] = [RouterURLKey : url as AnyObject]
        
        // parse querys from url.query
        if let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in items {
                if let value = item.value { result[item.name] = value as AnyObject }
            }
        }
        
        // merge querts & paramters
        result.merge(paramters) { return $1 }
        
        return result
    }
    
    func getRoutePaths(of url: URL) -> [String] {
        
        var components: [String] = []
        
        if let scheme = url.scheme, scheme.count > 0 { components.append(scheme) }
        // make sure host is always exists, if not using bundle identifier insteaded
        if let host = url.host ?? Bundle.main.bundleIdentifier { components.append(host) }
        // support different port
        if let port = url.port { components.append("\(port)") }
        // append path components
        components.append(contentsOf: url.pathComponents.filter { $0.count > 0 && $0 != "/" })
        
        return components
    }
    
    func createRoutes(of url: URL? = nil) -> Route? {
        
        guard let url = url else { return routes }
        
        let paths = getRoutePaths(of: url)
        guard !paths.isEmpty else { return routes }
        
        var route: Route? = routes
        for path in paths {
            // create sub route if not exists
            if route?.subRoutes[path] == nil {
                route?.subRoutes[path] = Route(path: path, parent: route)
            }
            route = route?.subRoutes[path]
        }
        return route
    }
    
    func getRoute(of url: URL) -> Route? {
        
        guard var route = getRoutes() else { return nil }
        let paths = getRoutePaths(of: url)
        guard !paths.isEmpty          else { return route }
        
        for path in paths {
            // find route using path
            if let tempRoute = route.subRoutes[path] { route = tempRoute }
                // find wildcard route.handler to handle
            else if let tempRoute = route.subRoutes[RouterURLWildcardCharacter] { route = tempRoute }
                // if it is a wildcard route, using it
            else if let path = route.path, path ==  RouterURLWildcardCharacter { break }
                // giveup find next route, using global route
            else { route = getRoutes()!; break }
        }
        return route
    }
    
    func getRules() -> [String : String] {
        return queue.sync { rules }
    }
}


////////////////////////////////////
// Route
////////////////////////////////////

public extension Router {
    
    
    /// Set a global handler for unregistered url
    ///
    /// - Parameter handler: handler will be excuted after routed
    class func setGlobal(handler: RouterHandler?) {
        shared.queue.sync { shared.routes.handler = handler }
    }
    
    /// Register a url
    ///
    /// - Parameters:
    ///   - URLString: url will be routed
    ///   - handler: handler will be excuted after routed
    class func register(_ pattern: String, handler: @escaping RouterHandler) {
        
        guard let url = URL(string: pattern)   else { return }
        shared.addRoute(with: url, handler: handler)
    }
    
    
    /// Register a url which will return the object
    ///
    /// - Parameters:
    ///   - URLString: url will be routed
    ///   - handler: handler will be excuted after routed and return the object
    class func register(_ pattern: String,  objectHandler handler: @escaping RouterObjectHandler) {
        guard let url = URL(string: pattern)   else { return }
        shared.addObjectRoute(with: url, handler: handler)
    }
    
    
    /// Unregister a url
    ///
    /// - Parameter URLString: url will be unregistered
    class func unregister(_ pattern: String) {
        guard let url = URL(string: pattern)   else { return }
        shared.removeRoute(with: url)
    }
    
    /// Unregistered all urls
    class func unregisterAll() {
        shared.removeRoutes()
    }
    
    /// Route a url
    ///
    /// - Parameters:
    ///   - string:    url to be routed
    ///   - paramters: additional paramters, will override same key if key exists in url.querys
    ///   - completion:   completion handler, will be called in registered handler
    class func route(_ pattern: String, with paramters: [String : AnyObject] = [:], completion: RouterCompletionHandler? = nil) {
        
        guard let url = rewrite(pattern)            else { return }
        
        var userInfo = shared.mergeQueryItems(of: url, with: paramters)
        if let completion = completion { userInfo[RouterCompletionHandlerKey] = completion as AnyObject }
        
        guard let route = shared.getRoute(of: url) else { return }
        if let executor = route.handler { executor(userInfo) }
    }
    
    
    /// Route a url and get the return object
    ///
    /// - Parameters:
    ///   - string:    url to be routed
    ///   - paramters: additional paramters
    /// - Returns: the object returned from registered url handler
    class func object(with string: String, paramters: [String : AnyObject] = [:]) -> AnyObject? {
        
        guard let url = rewrite(string)            else { return nil }
        let userInfo = shared.mergeQueryItems(of: url, with: paramters)
        
        guard let route = shared.getRoute(of: url) else { return nil }
        guard let executor = route.objectHandler   else { return nil }
        return executor(userInfo)
    }
    
    
    /// Determine url string can be routed
    ///
    /// - Parameter string: url string to be verified
    /// - Returns: url string can be routed
    class func canRoute(with string: String) -> Bool {
        
        guard let url = rewrite(string)             else { return false }
        guard let route = shared.getRoute(of: url)  else { return false }
        if let _ = route.handler                         { return true }
        if let _ = route.objectHandler                   { return true }
        return false
    }
}

extension URL {
    
    static func encodedURL(_ string: String) -> URL? {
        if let url = URL(string: string) { return url }
        guard let encoded = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        return URL(string: encoded)
    }
}


////////////////////////////////////
// Rewrite
////////////////////////////////////

public extension Router {
    
    
    /// Rewrite orgin url string, support urlencode(origin)
    ///
    /// - Parameter origin: the origin url string
    /// - Returns: an rewrited URL
    class func rewrite(_ origin: String) -> URL? {
        
        let rules = shared.getRules()
        
        guard rules.count > 0 else { return URL.encodedURL(origin) }
        
        for (rule, target) in rules {
            
            // 1. determine rule is match with origin
            guard let rx = try? NSRegularExpression(pattern: rule) else { continue }
            let nsRange = NSRange(origin.startIndex..<origin.endIndex, in: origin)
            guard let result = rx.firstMatch(in: origin, range: nsRange) else { continue }
            
            // 2. parse matched values
            var values: [String] = []
            for i in 0..<result.numberOfRanges {
                guard let range = Range(result.range(at: i), in: origin) else { continue }
                values.append(String(origin[range]))
            }
            
            // 3. replace matched value in target url
            var targetURL = target
            let targetRange = target.startIndex..<target.endIndex
            for i in 0..<values.count {
                guard let range = targetURL.range(of: "[$]([$|#]?)\(i)", options: .regularExpression, range: targetRange) else { continue }
                var replaced: String? = values[i]
                if target[range].hasPrefix("$#") { replaced = replaced?.removingPercentEncoding  }
                else if target[range].contains("$$") { replaced = replaced?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) }
                if let replaced = replaced  { targetURL = targetURL.replacingCharacters(in: range, with: replaced) }
            }
            
            return URL.encodedURL(targetURL) ?? URL.encodedURL(origin)
        }
        
        return URL.encodedURL(origin)
    }
    
    
    /// Add a rewrite rule.
    ///
    /// - Parameters:
    ///   - rule:   rule which supports regular
    ///   - target: the targer url to route
    class func addRewrite(_ rule: String, target: String) {
        shared.addRewrite(rule: rule, target: target)
    }
    
    /// Remove a rewrite rule
    ///
    /// - Parameter rule: rule which supports regular
    class func removeRewrite(_ rule: String) {
        shared.removeRewrite(rule: rule)
    }
    
    /// Get added rewrite rules
    ///
    /// - Returns: rules
    class func getRules() -> [String : String] {
        return shared.getRules()
    }
}
