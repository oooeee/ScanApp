//
//  ViewController.swift
//  ScanApp
//
//  Created by 大江諒介 on 2019/06/27.
//  Copyright © 2019 oe. All rights reserved.
//

import UIKit
import LineSDK
import Photos


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var lineLoginButton: LoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // ユーザに許可をとる
        PHPhotoLibrary.requestAuthorization {(status) in
            switch(status) {
            case .authorized:
                break
            case .denied:
                break
            case .notDetermined:
                break
            case .restricted:
                break
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        // ログインする箇所
        LoginManager.shared.login(permissions: [.profile], in: self) { (result) in
            switch result {
            case .success(let loginResult):
                if let profile = loginResult.userProfile {
                    UserDefaults.standard.set(profile.displayName, forKey: "displayName")
                    
                    do {
                        let data = try Data(contentsOf: profile.pictureURL!)
                        UserDefaults.standard.set(data, forKey: "pictureURLString")
                    } catch let error {
                        print(error)
                    }
                    
                    // 画面遷移
                    let cardVC = self.storyboard?.instantiateViewController(withIdentifier: "cardVC") as! CardViewController
                    self.navigationController?.pushViewController(cardVC, animated: true)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

