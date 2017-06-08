//
//  ViewController.swift
//  HBPhotoBrowser
//
//  Created by 伍宏彬 on 16/8/19.
//  Copyright © 2016年 伍宏彬. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func goSelectPhotos(_ sender: UIButton) {
    
        let rootVc = HBPhotoBrowser(delegate: self)

        let navBrowser = HBNavgationBrowser(rootViewController: rootVc)
    
        self.present(navBrowser, animated: true, completion: nil)
    }
    
}

extension ViewController: HBBaseViewControllerDelegate {
    
    func baseViewcontroller(didCancle baseVc: HBBaseViewController) {
        print("取消")
        baseVc.dismiss(animated: true, completion: nil)
    
    }
    func baseViewController(_ baseVc: HBBaseViewController, didPickPhotos photos: [photo], isOriginImage: Bool) {
        print("一共选取\(photos.count)张图片, 是否原图: \(isOriginImage)")
        baseVc.dismiss(animated: true, completion: nil)
    }
    
    func baseViewController(_ baseVc: HBBaseViewController, didPickVideo video: photo) {
        print("选取视频：\(video)")
        baseVc.dismiss(animated: true, completion: nil)
    }
    func baseViewController(_ baseVc: HBBaseViewController, didMaxCount maxCount: Int) {
        
        let errorMessage = "小兄弟，最多选择\(maxCount)张"
        
        let alterVc = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        
        let cancleAction = UIAlertAction(title: "确定", style: .cancel) { (action) in
            print(action.title ?? "标题")
        }

        alterVc.addAction(cancleAction)
        
        baseVc.present(alterVc, animated: true, completion: nil)
    
    }
}
