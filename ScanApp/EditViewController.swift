//
//  EditViewController.swift
//  ScanApp
//
//  Created by 大江諒介 on 2019/07/10.
//  Copyright © 2019 oe. All rights reserved.
//

import UIKit
import Firebase
import Lottie
import Pastel

class EditViewController: UIViewController, UITextFieldDelegate {
    
    var cardImage = UIImage()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cardNameTextField: UITextField!
    @IBOutlet weak var memoTextField: UITextField!
    
    var pastelView1 = PastelView()
    var animationView: AnimationView! = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = cardImage
        nameTextField.delegate = self
        cardNameTextField.delegate = self
        memoTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    func startAnimation(){
        let animation = Animation.named("scan")
        animationView.animation = animation
        animationView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height:
            self.view.frame.size.height)
        animationView.contentMode = .scaleAspectFit
        animationView.layer.zPosition = 1
        animationView.loopMode = .loop
        animationView.backgroundColor = .white
        view.addSubview(animationView)
        animationView.play()
    }
    
    func addData() {
        startAnimation()
        
        nameTextField.resignFirstResponder()
        cardNameTextField.resignFirstResponder()
        memoTextField.resignFirstResponder()
        
        let rootRef = Database.database().reference(fromURL: "https://scanapp-a995d.firebaseio.com/").child("post")
        let storage = Storage.storage().reference(forURL: "gs://scanapp-a995d.appspot.com/")
        let key = rootRef.child("Users").childByAutoId().key
        let imageRef = storage.child("Users").child("\(String(describing: key!)).jpg")
        
        print(imageRef)
        
        var data:Data = Data()
        if let image = imageView.image {
            data = image.jpegData(compressionQuality: 0.5)! as Data
        }
        
        let uploadTask = imageRef.putData(data, metadata: nil) {
            (metaData, error) in
            if error != nil {
                self.navigationController?.popViewController(animated: true)
                
                return
            }
            
            imageRef.downloadURL(completion: { (url, error) in
                if url != nil {
                    let feed = ["company": self.cardNameTextField.text as Any, "userName": self.nameTextField.text as Any, "imageString": url?.absoluteString as Any, "memo": self.memoTextField.text as Any, "createAt": ServerValue.timestamp()] as [String: Any]
                    let postFeed = ["\(key!)": feed]
                    rootRef.updateChildValues(postFeed)
                    self.animationView.removeFromSuperview()
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        uploadTask.resume()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.resignFirstResponder()
        cardNameTextField.resignFirstResponder()
        memoTextField.resignFirstResponder()
    }
    
    
    @IBAction func add(_ sender: Any) {
        addData()
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
