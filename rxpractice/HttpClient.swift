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

public protocol HttpClient {
    
    func get(url: NSURL, parameters: [String:String]?, headers: [String:String]?) -> Observable<(NSData, NSHTTPURLResponse)>
    
    func post(url: NSURL, parameters: [String:String]?, headers: [String:String]?) -> Observable<(NSData, NSHTTPURLResponse)>
    
}

public class DefaultHttpClient: HttpClient {
    
    private static let manager: Manager = Alamofire.Manager()
    
    public func get (url: NSURL, parameters: [String : String]?, headers: [String : String]?) -> Observable<(NSData, NSHTTPURLResponse)> {
        return action(Alamofire.Method.GET, url: url, parameters: parameters, headers: headers)
    }
    
    public func post (url: NSURL, parameters: [String:String]?, headers: [String:String]?) -> Observable<(NSData, NSHTTPURLResponse)> {
        return action(.POST, url: url, parameters: parameters, headers: headers)
    }
    
    private func action (method: Alamofire.Method, url: NSURL, parameters: [String:String]?, headers: [String:String]?) -> Observable<(NSData, NSHTTPURLResponse)> {
        let request = DefaultHttpClient.manager.request(method, url, parameters: parameters, encoding: ParameterEncoding.URL).request!
        let mutableRequest = setHeader(headers, mutableRequest: request.mutableCopy() as? NSMutableURLRequest)
        return DefaultHttpClient.manager.session.rx_response(mutableRequest!)
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