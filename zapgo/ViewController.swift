//
//  ViewController.swift
//  zapgo
//
//  Created by 김대종 on 2/24/17.
//  Copyright © 2017 devwue. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
//import InstagramKit


class ViewController: UIViewController {
    var user : InstaUser = InstaUser();
    var instagram: Instargram = Instargram(id: "c0843a4a211e478caf33e6f72e4f7d42", secret: "7c8aeda4616843ebb5ab344d71a4e7f5", redirectUrl: "https://www.instagram.com/" );
    var webView : UIWebView?;
    var tableView: UITableView?;
    var items : [JSON] = [];
    var bLoad: Bool = false;
    var info : NSDictionary?;

    // 최초 앱이 로드가 완료되면 설정됨.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist")
            ,let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            info = dict as NSDictionary?;
        }
        
        if instagram.token == nil {
            initWebView(completedHandler: {
                let url = instagram.authRequestUrl(scope: "basic+public_content+follower_list");
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
                webView?.loadRequest(request)
            });
        }else
        {
            updateLoginUser();
        }
        
    }
    
    
    // 쿠키 클리어
    @IBAction func actionClose(_ sender: UIBarButtonItem) {
        
        print("closed");
        let alertController = UIAlertController(
            title: "로그아웃",
            message: "정말로 로그 아웃 하시겠습니까?",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        let cancelAction = UIAlertAction(
            title: "취소",
            style: UIAlertActionStyle.destructive) { (action) in
            // todo: 취소시에 뭘 띄우지???
        }
        
        let confirmAction = UIAlertAction(
        title: "로그아웃", style: UIAlertActionStyle.default) { (action) in
            self.deleteChache();
            self.user.clear();
            self.initWebView(completedHandler: {
                let url = self.instagram.authRequestUrl(scope: "basic+public_content");
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
                self.webView?.loadRequest(request)
                self.tableView?.removeFromSuperview();
            });
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
         present(alertController, animated: true, completion: nil)
    }
    
    // 인스타그램 인증
    @IBAction func actionAuthorize(_ sender: UIBarButtonItem) {

        
    }
    
    // 토큰을 사용하여 로그인 유/무 확인
    func isLogin() -> Bool {
        if instagram.token != nil {
            return true;
        }
        return false;
    }
    
    
    // 로그인 사용자 정보 업데이트
    func updateLoginUser() ->Void {

        //if user.userid != nil { return }
        instagram.getProfile(cbHandler: { response  in
            print("api response: \(response)");
            
            self.user.id = (response["id"] as! NSString).integerValue
            self.user.userid = response["username"] as! String?;
            self.user.username = response["full_name"] as! String?;
            self.user.picture = response["profile_picture"] as! String?;
            
            self.navigationItem.title = "\(self.user.username!)(\(self.user.userid!))";
        });
        
        instagram.getUserFollowes(count: 100) { response in
            self.items = response;
            self.tableView?.reloadData();
            print("media: \(response)")
        }

    }
    
    // 인스타그램 API
    @IBAction func actionApi(_ sender: UIBarButtonItem) {
    
        instagram.getUserFollowed(count: 100) { users in
                self.items = users
                self.tableView?.reloadData();
                print("media: \(users)")
        
        }
    }
    
    
    // json 파싱 연습 ㅋㅋ
    func readJson() {
        let  data : NSDictionary = PlaceProvider.readJsonFromFile(filename: "sample.json") as! NSDictionary;
        print(data["name"]!);
        //var json = JSON(data);
        for (key,value) in data {
            print("key: \(key) =>\(value)");
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 캐쉬 제거
    func deleteChache() {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0;
        URLCache.shared.memoryCapacity = 0;
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }


}
// 요건 테이블
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func getNavigationBarHeight() -> CGFloat {
        let frame = self.navigationController?.navigationBar.frame;
        
        return (frame!.origin.y+frame!.size.height);
    }
    
    // 왜 안되지???
    func updateTable() {
        tableView = UITableView();
        let barHeight = getNavigationBarHeight();
        tableView?.frame         =  CGRect(0,barHeight
                                            , UIScreen.main.bounds.width
                                            , UIScreen.main.bounds.height - barHeight);
        print("tableview: \(tableView?.frame)");
        tableView?.delegate      =   self
        tableView?.dataSource    =   self
        
        tableView?.frame.origin.y = barHeight;
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView!)
        tableView?.reloadData();

    }

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return self.items.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell");
        
        
        if let json = items[indexPath.row].dictionaryObject {
            cell.textLabel?.text = json["username"] as? String;
            cell.detailTextLabel?.text = json["full_name"] as? String;
            if let urlString = json["profile_picture"] as? String {
                if let image = URL(string: urlString)?.getImages() {
                    cell.imageView?.image = image;
                    cell.imageView?.layer.cornerRadius =  (image.size.height*0.18) //(cell.imageView?.frame.size.width)! / 2
                    cell.imageView?.layer.masksToBounds = true
                }
            }else {
                // todo 기본 이미지가 필요할듯
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        if let json = items[indexPath.row].dictionaryObject {

            print("json: \(json)")
            
            let navHeight = self.navigationController?.navigationBar.frame;
            
        let vc = UIViewController();
        let bar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: (self.navigationController?.navigationBar.frame.origin.y)!+30))
        //vc.navigationController?.navigationItem.title = "Detail View";
            let item = UINavigationItem(title: "detail View");
            bar.setItems([item], animated: false);
        
            // user info
            let label = UILabel(frame: CGRect(x: 0, y: getNavigationBarHeight(), width: UIScreen.main.bounds.width, height: 30));
            let sUser = json["username"] as? String;
            let sName = json["full_name"] as? String;
            
            label.text = "user: \(sUser!)(\(sName!))"
            let img  = URL(string: (json["profile_picture"] as? String)!)?.getImages();
            let imgview = UIImageView(image: img); //CGRect(x: 0, y: 0, width: 100, height: 200)
            imgview.frame = CGRect(x: 0, y: (navHeight?.origin.y)! + 80 , width: (img?.size.width)!, height: (img?.size.height)!);
            
            
            
        vc.view.addSubview(bar);
        vc.view.addSubview(label)
            vc.view.addSubview(imgview);
        vc.view.backgroundColor = UIColor.white
        let parent = self;
        present(vc, animated: true, completion: {
            let when = DispatchTime.now() + 5 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                parent.dismiss(animated: true, completion: nil)
            }
            
        });
        }

    }
    
    
}


// 요건 웹뷰
extension ViewController : UIWebViewDelegate {
    // 웹뷰 초기화
    func initWebView(completedHandler: () -> Void) {
        webView = UIWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        webView?.delegate = self
        webView?.isOpaque = false;
        webView?.backgroundColor = UIColor.clear
        webView?.scalesPageToFit = true;
        
        view.addSubview(webView!)
        completedHandler();
    }
    
    
    // 웹뷰 생성 및 현재 뷰에 할당
    func createWebview() {
        webView = UIWebView(frame: CGRect(0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height))
        
        webView?.delegate = self
        view.addSubview(webView!);
    }

    // 웹뷰 로딩이 시작될때
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
            if let url = request.url {
                print("url > \(url)");
                guard ((url.host?.range(of: "instagram.com")) != nil) else {
                    return true
                }
                
                if (url.absoluteString.range(of: "access_token=") != nil) {
                    print("webview should: \(url)");
                    // 어떻게 인스타그램 SDK가 해쉬태그 파싱이 제대로 안되지????
                    if let url2: String = url.absoluteString.replacingOccurrences(of: "#access_token", with: "?access_token") {
                        print("webview \(url2)");
                        if let param = URL(string: url2)?.queryItems {
                            if let token = param["access_token"], token != instagram.token {
                                instagram.token = token;
                                updateLoginUser();
                                updateTable();
                                print("instagram accessToken: \(token)");
                            }
                        }
                    }
                }
                if (url.absoluteString.range(of: "code=") != nil), let param = url.queryItems, let instaCode = param["code"] {
                    instagram.code = instaCode;
                    print("instagram cod set: \(instaCode)");
                }
                
                
               
            }
        return true
    }
    

    func webViewDidFinishLoad(_ webView: UIWebView) {
        if let url = webView.request?.url {
            if ((url.host?.range(of: "instagram.com")) != nil), instagram.token != nil {
                //updateLoginUser();
                webView.removeFromSuperview();
            }
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("webview load failed");
    }
  
}
