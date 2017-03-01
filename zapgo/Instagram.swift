//
//  Instagram.swift
//  zapgo
//
//  Created by 김대종 on 2/25/17.
//  Copyright © 2017 devwue. All rights reserved.
//
import SwiftyJSON
import Alamofire

struct InstaUser {
    var userid: String?
    var username: String?
    var id: Int = 0;
    var follows: Int = 0;
    var picture: String?
    
    mutating func clear() {
        userid = nil;
        username = nil;
        id = 0
        follows = 0;
        picture = nil;
        
    }
}


struct Instargram {
    let id:String?
    let secret: String?
    var code: String?
    var token: String?
    var redirect_url: String?
    
    init(id: String, secret: String, redirectUrl: String) {
        self.id = id
        self.secret = secret
        self.redirect_url = redirectUrl
    }
    
    // 인증 코드 획들을 위한 URL 리턴
    func authRequestUrl(scope: String) -> URL {
        let url = "https://api.instagram.com/oauth/authorize/?client_id=\(id!)&redirect_uri=\(redirect_url!)&response_type=token&scope=\(scope)"
        return URL(string: url)!;
    }

    
    // 로그인 사용자 프로파일 리턴
    func getProfile(cbHandler: @escaping ([String:Any ]) -> Void) {
        let url = "https://api.instagram.com/v1/users/self/?access_token=\(token!)";
        print("insta login api: \(url)");
        Alamofire.request(url, method: .get).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                print("json \(value)")
                let json = JSON(data: response.data!);
                print("json \(json)");
                cbHandler(json["data"].dictionaryObject!);
            case .failure(let error):
                debugPrint("api error: \(error)");
            }
        }
    }
    
    // 로그인 사용자 미디어 리스트 가져오기
    func getUserMedia(count: Int, cbhandler: ([JSON]) -> Void) {
        let url = "https://api.instagram.com/v1/users/self/media/recent/?count=\(count)&access_token=\(token!)";
        Alamofire.request(url, method: .get).responseJSON(completionHandler: { response in
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                print(JSON)
            }else
            {
                print(response);
            }
        });
    }
    
    // 팔로워 리스트
    func getUserFollowes(count: Int, cbHandler: @escaping ([JSON]) ->Void) {
        let url = "https://api.instagram.com/v1/users/self/follows?access_token=\(token!)" ;
        Alamofire.request(url, method: .get).responseJSON(completionHandler: { response in
            switch response.result {
            case .success(let value) :
                print("success: \(value)");
                if let data = response.data {
                    let json = JSON(data: data);  
                    cbHandler(json["data"].arrayValue);
                }else {
                    cbHandler([]);
                    print("failed append");
                }
                
            case .failure(let error):
                print("error: \(error)");
            }
        });
    }
    
    // 팔로워 리스트
    func getUserFollowed(count: Int, cbHandler: @escaping ([JSON]) ->Void) {
        let url = "https://api.instagram.com/v1/users/self/followed-by?access_token=\(token!)" ;
        Alamofire.request(url, method: .get).responseJSON(completionHandler: { response in
            switch response.result {
            case .success(let value) :
                print("success: \(value)");
                if let data = response.data {
                    let json = JSON(data: data);
                    cbHandler(json["data"].arrayValue);
                }else {
                    cbHandler([]);
                    print("failed append");
                }
                
            case .failure(let error):
                print("error: \(error)");
            }
        });
    }
    
    // 최신 미디어 가져오기
    func getRecentMedia(cbHandler: (JSON) -> Void) {
        let url = "https://api.instagram.com/v1/tags/daijongkim/media/recent?client_id=\(id!)";
        let headers : HTTPHeaders = [
            "client_id" : id!
        ];
        
    
        Alamofire.request(url, method: .get, headers: headers ).responseJSON { response  in
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                print(JSON)
            }else
            {
                print(response);
            }
            
        };
        
    }
}
