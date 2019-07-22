//
//  Element.swift
//  ScanApp
//
//  Created by 大江諒介 on 2019/07/05.
//  Copyright © 2019 oe. All rights reserved.
//

import UIKit

class Element: NSObject {
    var userName:String?
    var company:String?
    var imageString:String?
    var memo:String?
    var createAt:CLong?
    
    init(userName:String, company:String, imageString:String, memo:String, createAt:CLong) {
        self.userName = userName
        self.company = company
        self.imageString = imageString
        self.memo = memo
        self.createAt = createAt
    }
}
