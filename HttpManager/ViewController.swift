//
//  ViewController.swift
//  HttpManager
//
//  Created by Mac on 2018/1/11.
//  Copyright © 2018年 Mac. All rights reserved.
//

import UIKit
import SwiftSocket

class ViewController: UIViewController {

    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    let host = "192.168.197.105"
    let port = 5000
    var client : TCPClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var url = URL(string: "http:www.bai.com?key=value&key1=value")
        print(url?.absoluteString as Any)
        print(url?.query as Any)
        print( url?.description as Any)
        var urlComponents = URLComponents(url: url!, resolvingAgainstBaseURL: false)
        let percentEncodedQuery = (urlComponents?.percentEncodedQuery.map{$0 + "&"} ?? "") + "key2=value"
        urlComponents?.percentEncodedQuery = percentEncodedQuery
        url = urlComponents?.url
        print(url?.absoluteString as Any)
        print(url?.query as Any)
        
        let string = "http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1307/23/c0/23656308_1374564438338_800x600.jpg"
        imageButton.hsp_image(url: URL(string: string)!, state: UIControlState.normal)
          imageButton.setTitle("12", for: UIControlState.normal)
        imageView.hsp_image(url: URL(string: string)!)
    
        imageButton.addTarget(self, action: #selector(buttonClickAction), for: UIControlEvents.touchUpInside)
        
        
        print(split(num: 17))
        
        let array  = [1,4,10,5,90,80,34,12,20,10]
     
        let sortArray =  array.sorted { (s1 : Int, s2 : Int) -> Bool in
            return s1 > s2
        }
        print("\(sortArray)")
        let resultArray =  array.map {  ( a : Int)in "\(a)?"
        }
        print("\(resultArray)")
        
        
        
        client = TCPClient(address: host, port: Int32(port))
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    /**
     公质数
     */
    func  split(num : Int) -> Array<Int> {
        var array  = Array<Int>()
        var i = 2
        var value = 0
        while  i <= num  {
            if num % i   == 0  {
                value = num / i
                break
            }
            i = i + 1
        }
        if value  != 0 {
            array.append(i)
            array += split(num: value)
        }
        return array
    }
    
    @objc func buttonClickAction() -> Void{
        guard let client = client else {
            return
        }
        imageButton.isSelected = !imageButton.isSelected
        guard let _ = client.fd else{
            connectClint(client: client)
            return
        }
        dealButtonState(client: client)
    }
    /**
     处理按钮的状态 是打开还是关闭的
     */
    fileprivate func dealButtonState(client:TCPClient){
        if imageButton.isSelected {
            if let reponse = sendRequest(string: "on1", client: client){
                appendToTextField(string: reponse)
            }
        }else{
            if let reponse = sendRequest(string: "off1", client: client){
                appendToTextField(string: reponse)
            }
        }
    }
    
    /**
     连接client
     */
    fileprivate func connectClint(client : TCPClient){
        
        switch client.connect(timeout: 10) {
        case .success:
            if let response = sendRequest(string: "off1", client: client){
                appendToTextField(string: response)
            }
        case .failure(let error):
            appendToTextField(string: String(describing: error))
        }
    }
    /**
     发送数据
     */
    fileprivate func sendRequest(string:String,client: TCPClient) -> String?{
        switch client.send(string: string){
        case .success:
            return readResponse(from: client)
        case .failure(let error):
            appendToTextField(string: String(describing: error))
            return nil
        }
    }
    /**
     读取数据
     */
    fileprivate func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
        return String(bytes: response, encoding: .utf8)
    }
    /**
     打印
     */
    fileprivate func appendToTextField(string: String) {
        print(string)
    }
    
    func download(num:String){
        _ = HSPDownloadManager.download(url:  URL(string: "http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1307/23/c0/23656308_1374564438338_800x600.jpg")!, progress: { (progress: Float) in
            print("progress is \(progress)")
        }, success: { (data:Data?) in
            print("download success \(num)")
        }, failure: { (error : Error?)in
            print("download failure")
        })
    }
    deinit {
        guard let client = client else {
            return
        }
        client.close()
    }
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

