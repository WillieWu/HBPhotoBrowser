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
    }

    @IBAction func goSelectPhotos(_ sender: UIButton) {
    
        let rootVc = HBPhotoBrowser(delegate: self)
        rootVc.maxPhotos = 3

        let navBrowser = HBNavgationBrowser(rootViewController: rootVc)
    
        self.present(navBrowser, animated: true, completion: nil)
        
        
    }
    
}

extension ViewController: HBBaseViewControllerDelegate {
    
    func baseViewController(_ baseVc: HBBaseViewController, didPickPhotos photos: [photo], isOriginImage: Bool) {
        print("一共选取\(photos.count)张图片, 是否原图: \(isOriginImage)")

    }
   
    func baseViewController(_ baseVc: HBBaseViewController, didPickVideo video: photo) {
        print("选取视频：\(video)")
        
    }
    
    func baseViewController(_ baseVc: HBBaseViewController, didMaxCount maxCount: Int) {
        print("最多选择\(maxCount)张照片")
    }
   
}
