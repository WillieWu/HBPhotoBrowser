//
//  config.swift
//  HBPhotoBrowser
//
//  Created by 伍宏彬 on 16/8/22.
//  Copyright © 2016年 伍宏彬. All rights reserved.
//

import UIKit

//MARK: UI 设置 ------------------ BEGIN
//MARK: 导航栏
let HBNavgation_tintColor = UIColor.white
let HBNavgation_barTintColor = UIColor.black
let HBNavgation_titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]

//MARK: 相册分类界面
let HBPhotoCollectionsTableViewCell_Height: CGFloat = 66
let HBPhotoCollectionsTableViewCell_Image = UIImage(named: "HBPhotoBrowser.bundle/place_icon")
let HBPhotoCollectionsTableViewCell_ImageSize = CGSize(width: 50, height: 50)

let HBPhotoCollectionsTableViewCell_TitleColor = UIColor ( red: 0.5333, green: 0.5333, blue: 0.5333, alpha: 1.0 )
let HBPhotoCollectionsTableViewCell_TitleFont = UIFont.systemFont(ofSize: 17)

let HBPhotoCollectionsTableViewCell_SubtitleColor = UIColor ( red: 0.8637, green: 0.8637, blue: 0.8637, alpha: 1.0 )
let HBPhotoCollectionsTableViewCell_SubtitleFont = UIFont.systemFont(ofSize: 14)

//MARK: 照片缩略图界面
let HBPhotos_select_YES_Icon = UIImage(named: "HBPhotoBrowser.bundle/select_Yes")
let HBPhotos_select_NO_Icon = UIImage(named: "HBPhotoBrowser.bundle/select_No")
let HBPhotos_padding: CGFloat = 2.0
let HBPhotos_line: CGFloat = UIScreen.main.bounds.size.width > 375 ? 5 : 4

//MARK: 底部工具栏
let HBPhoto_Buttom_Send_Color_Normal = color(245,g: 79,b: 85)
let HBPhoto_Buttom_Send_Color_Disabled = UIColor ( red: 0.8902, green: 0.8902, blue: 0.8902, alpha: 1.0 )

//MARK: UI 设置 ------------------ END
let KEY_HB_ORIGINIMAGE = "KEY_HB_ORIGINIMAGE"

func color(_ r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
    return color_a(r: r, g: g, b: b, a: 1)
}
func color_a(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

extension String {
    
    /// 相册英文名称对应的中文
    ///
    /// - Returns: String
    func chinese() -> String {
        
        var name: String = ""
        
        switch self {
        case "Slo-mo":
            name = "慢动作"
        case "Recently Added":
            name = "最近添加"
        case "Favorites":
            name = "个人收藏"
        case "Recently Deleted":
            name = "最近删除"
        case "Videos":
            name = "视频"
        case "All Photos":
            name = "所有照片"
        case "Selfies":
            name = "自拍"
        case "Screenshots":
            name = "屏幕快照"
        case "Camera Roll":
            name = "相机胶卷"
        case "Panoramas":
            name = "全景照片"
        case "Hidden":
            name = "已隐藏"
        case "Time-lapse":
            name = "延时拍摄"
        case "Bursts":
            name = "连拍快照"
        case "Depth Effect":
            name = "景深效果"
        default:
            name = self
        }
        return name
    }

}

extension UIView {
    
    var hb_X: CGFloat {
        
        get{
            return self.frame.origin.x
        }
        set{
            var originRect = self.frame
            originRect.origin.x = newValue
            self.frame = originRect
        }
        
    }
    var hb_Y: CGFloat {
        
        get{
            return self.frame.origin.y
        }
        set{
            var originRect = self.frame
            originRect.origin.y = newValue
            self.frame = originRect
        }
        
    }
    var hb_W: CGFloat {
        
        get{
            return self.frame.size.width
        }
        set{
            var originRect = self.frame
            originRect.size.width = newValue
            self.frame = originRect
        }
        
    }
    var hb_H: CGFloat {
        
        get{
            return self.frame.size.height
        }
        set{
            var originRect = self.frame
            originRect.size.height = newValue
            self.frame = originRect
        }
        
    }
    var hb_centerX: CGFloat {
        
        get{
            return self.center.x
        }
        set{
            var originCenter = self.center
            originCenter.x = newValue
            self.center = originCenter
        }
        
    }
    var hb_centerY: CGFloat {
        
        get{
            return self.center.y
        }
        set{
            var originCenter = self.center
            originCenter.y = newValue
            self.center = originCenter
        }
        
    }
    var hb_center: CGPoint {
    
        get{
            return self.center
        }
        set{
//            var originCenter = self.center
//            originCenter = newValue
            self.center = newValue
        }
    
    }
    
    
    func hb_starBoundsAnimation() {
        
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { (Finished) in
            UIView.animate(withDuration: 0.15, animations: {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        })
    }
    
    
}

