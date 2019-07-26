//
//  CardViewController.swift
//  ScanApp
//
//  Created by 大江諒介 on 2019/07/04.
//  Copyright © 2019 oe. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import MBDocCapture
import Pastel
import GoogleMobileAds

class CardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ImageScannerControllerDelegate, GADInterstitialDelegate {
    
    
    @IBOutlet weak var backGroundImageView: UIImageView!
    
    var pastelView1 = PastelView()
    
    var displayName = String()
    let refleshControl = UIRefreshControl()

    @IBOutlet weak var myProfileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    weak var element:Element?
    var listOfData = [Element]()
    
    // カード
    var cardImageView = UIImageView()
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // ログインをした
        UserDefaults.standard.set(1, forKey: "loginOK")
        navigationController?.setNavigationBarHidden(true, animated: true)
        refleshControl.attributedTitle = NSAttributedString(string: "引っ張って更新！")
        refleshControl.addTarget(self, action: #selector(reflesh), for: .valueChanged)
        
        tableView.addSubview(refleshControl)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        displayName = UserDefaults.standard.object(forKey: "displayName") as! String
        displayNameLabel.text = displayName
        
        var pictureURLString = UserDefaults.standard.value(forKey: "pictureURLString") as! NSData
        self.myProfileImageView.image = UIImage(data: pictureURLString as Data)
    }
    
    @objc func reflesh() {
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.object(forKey: "image") != nil {
            var data = Data()
            data = UserDefaults.standard.object(forKey: "image") as! Data
            backGroundImageView.image = UIImage(data: data)
        }
        
        pastelView1.removeFromSuperview()
        graduationStart1()
        NotificationCenter.default.addObserver(self, selector:
            #selector(viewWillEnterForeground(
                notification:)), name: UIApplication.willEnterForegroundNotification,
                                 object: nil)
        NotificationCenter.default.addObserver(self, selector:
            #selector(viewDidEnterBackground(
                notification:)), name: UIApplication.didEnterBackgroundNotification,
                                 object: nil)
        
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        navigationController?.setNavigationBarHidden(true, animated: true)
        fetchData()
    }
    
    @objc func viewWillEnterForeground(notification: Notification) {
        print("フォアグラウンド")
        pastelView1.removeFromSuperview()
        graduationStart1()
    }
    // AppDelegate -> applicationDidEnterBackgroundの通知
    @objc func viewDidEnterBackground(notification: Notification) {
        print("バックグラウンド")
    }
    
    func graduationStart1(){
        pastelView1 = PastelView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height:
            self.view.frame.size.height))
        // Custom Direction
        pastelView1.startPastelPoint = .bottomLeft
        pastelView1.endPastelPoint = .topRight
        // Custom Duration
        pastelView1.animationDuration = 2.0
        // Custom Color
        pastelView1.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                               UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                               UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                               UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                               UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                               UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                               UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        pastelView1.startAnimation()
        view.insertSubview(pastelView1, at: 0)
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let userNameLabel = cell.viewWithTag(1) as! UILabel
        userNameLabel.text = listOfData[indexPath.row].userName
        
        let companyNameLabel = cell.viewWithTag(2) as! UILabel
        companyNameLabel.text = listOfData[indexPath.row].company
        
        cardImageView = cell.viewWithTag(3) as! UIImageView
        let profileImageURL = URL(string: listOfData[indexPath.row].imageString as! String)
        cardImageView.sd_setImage(with: profileImageURL, completed: nil)
        cardImageView.layer.cornerRadius = 10.0
        cardImageView.clipsToBounds = true
        
        let createAtLabel = cell.viewWithTag(4) as! UILabel
        let dateUnix = Double(listOfData[indexPath.row].createAt!) as! TimeInterval
        let date = Date(timeIntervalSince1970: dateUnix/1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM--dd HH:mm"
        let dateStr = formatter.string(from: date)
        createAtLabel.text = dateStr
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height/3
    }
    
    // データをFirebaseからとってくる
    func fetchData(){
        
        
        // データベースサーバから
        // postというノード（点、場所）から（postとは、送信したときの点）
        // 最新100件を
        // 古い順にとってくる（createAt）
        
        let ref = Database.database().reference(fromURL: "https://scanapp-a995d.firebaseio.com/").child("post").queryLimited(toLast: 100).queryOrdered(byChild: "postDate").observe(.value) {(snapshot) in
            
            self.listOfData.removeAll()
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let postData = snap.value as? [String:Any] {
                        let userName = postData["userName"] as? String
                        let company = postData["company"] as? String
                        let imageString = postData["imageString"] as? String
                        let memo = postData["memo"] as? String
                        var postDate:CLong?
                        if let postedDate = postData["createAt"] as? CLong {
                            postDate = postedDate
                        }
                        self.listOfData.append(Element(userName: userName!, company: company!, imageString: imageString!, memo: memo!, createAt: postDate!))
                    }
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 画面遷移（値を渡しながら）
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "detail") as! DetailViewController
        detailVC.nameString = listOfData[indexPath.row].userName!
        detailVC.companyString = listOfData[indexPath.row].company!
        detailVC.memoString = listOfData[indexPath.row].memo!
        detailVC.cardImage = listOfData[indexPath.row].imageString!
        
        let dateUnix = Double(listOfData[indexPath.row].createAt!) as! TimeInterval
        let date = Date(timeIntervalSince1970: dateUnix/1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateStr = formatter.string(from: date)
        detailVC.dateString = dateStr
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
    @IBAction func openCamera(_ sender: Any) {
        let scanner = ImageScannerController(delegate: self)
        scanner.shouldScanTwoFaces = false
        present(scanner, animated: true)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        
        scanner.dismiss(animated: true) {
            // 値を保持して、画面遷移
            let editVC = self.storyboard?.instantiateViewController(withIdentifier: "edit") as! EditViewController
            editVC.cardImage = results.scannedImage
            self.navigationController!.pushViewController(editVC, animated: true)
        }
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithPage1Results page1Results: ImageScannerResults, andPage2Results page2Results: ImageScannerResults) {
        scanner.dismiss(animated: true, completion: nil)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true, completion: nil)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        scanner.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func toSettingView(_ sender: Any) {
        let settingVC = self.storyboard?.instantiateViewController(withIdentifier: "setting") as! SettingViewController
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
