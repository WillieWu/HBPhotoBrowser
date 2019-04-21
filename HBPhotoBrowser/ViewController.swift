//
//  ViewController.swift
//  HBPhotoBrowser
//
//  Created by 伍宏彬 on 16/8/19.
//  Copyright © 2016年 伍宏彬. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let label = (JPFPSStatus.sharedInstance()?.fpsLabel)!
        UIApplication.shared.keyWindow?.addSubview(label)
    }
    
    var browser: HBPhotoBrowser?
    @IBAction func goSelectPhotos(_ sender: UIButton) {
        self.browser = HBPhotoBrowser(self)
        self.browser?.maxCount = 4
        self.browser?.didMaxCount = { (count) in
            print(count)
        }
        self.browser?.didSelectVideo = { (item) in
            print(item)
        }
        self.browser?.didSelectPhotos = { (isOrigin, items) in
            print("\(isOrigin), \(items)")
        }
        self.browser?.show()
    }
    
}
