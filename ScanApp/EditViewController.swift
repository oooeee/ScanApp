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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = cardImage
        nameTextField.delegate = self
        cardNameTextField.delegate = self
        memoTextField.delegate = self
    }
    
    func addData() {
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
