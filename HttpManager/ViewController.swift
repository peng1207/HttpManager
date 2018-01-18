//
//  ViewController.swift
//  HttpManager
//
//  Created by Mac on 2018/1/11.
//  Copyright © 2018年 Mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
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
        
        
        let setModel = HSPHttpSetModel()
        setModel.url = "http://baike.baidu.com/api/openapi/BaikeLemmaCardApi?scope=103&format=json&appid=379020&bk_key=swift&bk_length=600"
//        setModel.url = "http://www.baidu.com/search?search=name"
//        setModel.parm = ["id":"qw","name":"name","subName":"#中文","duoKey":["1","2","3"],"key2":["key1":"1","key2":"2"]]
        setModel.httpMethod = HSPHttpMethod.post
//        _ = HSPHttpManager.request(httpSet: setModel, success: { (response:Data?) in
//
//            let json = try? JSONSerialization.jsonObject(with: response!, options: JSONSerialization.ReadingOptions.mutableContainers)
//            print("json is \(String(describing: json))")
//
//        },failure: { (error:Error?) in
//            print(error as Any)
//        })

//        download(num: "1")
//        download(num: "2")
//        download(num: "3")
//        download(num: "4")
//        download(num: "5")
//        let imageView = UIImageView()
        
        let string = "http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1307/23/c0/23656308_1374564438338_800x600.jpg"
//      imageButton.setImage(UIImage.init(named: "sharebtn"), for: UIControlState.normal)
        imageButton.hsp_image(url: URL(string: string)!, state: UIControlState.normal)
          imageButton.setTitle("12", for: UIControlState.normal)
//        imageButton.hsp_backgroundImage(url: URL(string: string)!, state: UIControlState.normal)
        imageView.hsp_image(url: URL(string: string)!)
    
        imageButton.addTarget(self, action: #selector(buttonClickAction), for: UIControlEvents.touchUpInside)
        
//        let button = UIButton(type: UIButtonType.custom)
//        button.frame = CGRect(x: 10, y: 260, width: 300, height: 60)
//        button.setTitle("12", for: UIControlState.normal)
//        button.setImage(UIImage.init(named: "sharebtn"), for: UIControlState.normal)
//        button.setTitleColor(UIColor.red, for: UIControlState.normal)
//
//        self.view.addSubview(button)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    @objc func buttonClickAction() -> Void{
        let pictureVC = HSPBrowsePicturesVC()
        self.present(pictureVC, animated: true, completion: nil)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

