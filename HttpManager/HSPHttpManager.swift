//
//  HSPHttpManager.swift
//  HttpManager
//
//  Created by Mac on 2018/1/11.
//  Copyright © 2018年 Mac. All rights reserved.
//

import UIKit
import Foundation
typealias SuccessBlock = (_ response:Data?) -> Void
typealias FailureBlock = (_ error:Error?) -> Void
let HSPHttpMethodArray = ["GET","HEAD","PUT"]

class HSPHttpManager: NSObject {
    /**
     请求
     */
    class func request(httpSet:HSPHttpSetModel?,success:SuccessBlock?,failure:FailureBlock?) -> URLSessionDataTask?{
        if httpSet == nil {
            return nil
        }
        if httpSet?.url == nil{
          return nil
        }
        let request = getRequest(httpSet: httpSet)
        let sessionDataTask = URLSession.shared.dataTask(with: request!) { (repose : Data?, urlResponse : URLResponse?, error : Error?) in
            if let datarepose = repose {
                if let successBlock = success{
                    successBlock(datarepose)
                }
            }else{
                if let failureblock = failure{
                    failureblock(error)
                }
            }
        }
        sessionDataTask.resume()
        return sessionDataTask
    }
    
    fileprivate class func getRequest(httpSet:HSPHttpSetModel?) -> URLRequest? {
        let requestURL : URL = URL(string: (httpSet?.url!)!)!
        var request : URLRequest = URLRequest(url: requestURL, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: (httpSet?.timeOut)!)
        request.httpMethod = httpSet?.httpMethod.getName()
        if HSPHttpMethodArray.contains((httpSet?.httpMethod.getName())!){
            // get head put
            if var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) ,let parm : Dictionary<String,Any> = httpSet?.parm, !parm.isEmpty{
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map{$0 + "&"} ?? "") + other(parm: httpSet?.parm)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                request.url = urlComponents.url
            }
        }else{
            // post
            if let parm : Dictionary<String,Any> = httpSet?.parm, !parm.isEmpty{
                request.httpBody = getPost(parm: httpSet?.parm)
            }
        }
        return request
    }
    /**
     获取post的参数的格式
     */
    fileprivate class func getPost(parm:Dictionary<String,Any>?) -> Data?{
        if let parmData = parm {
            return try! JSONSerialization.data(withJSONObject: parmData, options: JSONSerialization.WritingOptions.prettyPrinted)
        }else{
            return nil
        }
    }
    /**
     获取其他请求方式的入参数格式
     */
   fileprivate class func other(parm:Dictionary<String,Any>?) -> String {
        let parmArray = array(key: "", value: parm as Any)
        return parmArray.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    fileprivate class func array(key:String,value:Any) -> Array<(String,String)>{
        var compone : [(String,String)] = []
        if  let dic = value as? [String:Any]{
            for (dicKey,dicValue ) in dic{
                compone += array(key: "\(key)[\(dicKey)]", value: dicValue)
            }
        }else if let dataArray = value as? [Any]{
            for arrayValue in dataArray{
                compone += array(key: "\(key)[]", value: arrayValue)
            }
        }else if let bool = value as? Bool{
            compone.append((escape(key), escape((bool ? "1" : "0"))))
        }else {
            compone.append((escape(key), escape("\(value)")))
        }
        return compone
    }
    fileprivate class func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        var escaped = ""
        
        if #available(iOS 8.3, *) {
            escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        } else {
            let batchSize = 50
            var index = string.startIndex
            
            while index != string.endIndex {
                let startIndex = index
                let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
                let range = startIndex..<endIndex
                
                let substring = string[range]
                
                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? String(substring)
                
                index = endIndex
            }
        }
        
        return escaped
    }
}
/** 请求的封装 */
class HSPHttpSetModel: NSObject {
    /** 链接 */
    var url : String?
    /** 请求参数 */
    var parm : Dictionary<String,Any>?
    /** 请求超时 */
    var timeOut : TimeInterval = 60.00
    /** 请求方法*/
    var httpMethod : HSPHttpMethod = HSPHttpMethod.post
}

/** 请求方法*/
public enum HSPHttpMethod : Int {
        case get
        case post
    
    func getName() -> String{
        switch self {
        case .get: return "GET"
        case .post:return "POST"
        }
    }
}
