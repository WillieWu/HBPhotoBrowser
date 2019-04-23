//
//  HBPhotoBrowser.swift
//  HBPhotoBrowser
//
//  Created by 伍宏彬 on 2019/4/21.
//  Copyright © 2019 伍宏彬. All rights reserved.
//

import UIKit
import Photos

public class HBPhotoBrowser: NSObject {
    convenience init(_ presentVC: UIViewController) {
        self.init()
        self.presentVc = presentVC
    }
    fileprivate var presentVc: UIViewController = (UIApplication.shared.keyWindow?.rootViewController)!
    
    public var didSelectPhotos: ((_ isOriginImage: Bool ,_ photoItems: [HBMediaItem]) -> ())?
    public var didSelectVideo: ((_ VideoItem: HBMediaItem) -> ())?
    public var didMaxCount: ((_ count: Int) -> ())?
    
    public var maxCount: Int = 9
    //TODO: @whb 后期增加图片剪裁功能
//    public var shouldEdit:Bool = false
    
    public func show() {
        let rootVc = HBGroupPhotoListController(delegate: self)
        rootVc.maxCount = self.maxCount
//        rootVc.shouldEdit = self.shouldEdit
        let navBrowser = HBNavgationBrowser(rootViewController: rootVc)
        self.presentVc.present(navBrowser, animated: true, completion: nil)
    }
}

extension HBPhotoBrowser: HBBaseViewControllerDelegate {
    public func baseViewcontroller(didCancle baseVc: HBBaseViewController) {
        baseVc.dismiss(animated: true, completion: nil)
    }
    
    public func baseViewController(_ baseVc: HBBaseViewController, didPickPhotos photos: [HBMediaItem], isOriginImage: Bool) {
        self.didSelectPhotos?(isOriginImage, photos)
        
    }
    public func baseViewController(_ baseVc: HBBaseViewController, didPickVideo video: HBMediaItem) {
        self.didSelectVideo?(video)
    }
    public func baseViewController(_ baseVc: HBBaseViewController, didMaxCount maxCount: Int) {
        self.didMaxCount?(maxCount)
    }
}
