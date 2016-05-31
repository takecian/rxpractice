//
//  HttpClient.swift
//  rxpractice
//
//  Created by Fujiki Takeshi on 5/30/16.
//  Copyright © 2016 takecian. All rights reserved.
//
import Alamofire
import RxSwift
import Foundation

protocol HttpClient {
    
    func get(url: NSURL, parameters: [String:String]?, headers: [String:String]?) -> Observable<[User]>
    
    func post(url: NSURL, parameters: [String:String]?, headers: [String:String]?) -> Observable<AnyObject>
    
}

struct User {
    let name: String
    let url: String
    let avatarUrl: String
}

class DefaultHttpClient: HttpClient {
    
    private static let manager: Manager = Alamofire.Manager()
    
    func get (url: NSURL, parameters: [String : String]?, headers: [String : String]?) -> Observable<[User]> {
        return action(Alamofire.Method.GET, url: url, parameters: parameters, headers: headers)
            .debug()
            .map({ (json) -> [User] in
                guard let json = json as? [AnyObject] else { fatalError("Cast failed") }
                return self.parseJSON(json)
            })
    }
    
    func post (url: NSURL, parameters: [String:String]?, headers: [String:String]?) -> Observable<AnyObject> {
        return action(.POST, url: url, parameters: parameters, headers: headers)
    }
    
    func parseJSON(json: [AnyObject]) -> [User] {
        return json.map { result in
            let name = result["name"] as? String ?? ""
            let url = result["previewUrl"] as? String ?? ""
            let avatarUrl = result["frameUrl"] as? String ?? ""
            return User(name: name, url: url, avatarUrl: avatarUrl)
        }
    }

    private func action (method: Alamofire.Method, url: NSURL, parameters: [String:String]?, headers: [String:String]?) -> Observable<AnyObject> {
        let request = DefaultHttpClient.manager.request(method, url, parameters: parameters, encoding: ParameterEncoding.URL).request!
        let mutableRequest = setHeader(headers, mutableRequest: request.mutableCopy() as? NSMutableURLRequest)
        return DefaultHttpClient.manager.session.rx_JSON(mutableRequest!)
    }
    
    private func setHeader(headers: [String:String]?, mutableRequest: NSMutableURLRequest?) -> NSMutableURLRequest? {
        if let headers = headers {
            for (key, value) in headers {
                mutableRequest?.setValue(value, forHTTPHeaderField: key)
            }
        }
        return mutableRequest
    }
    
}