//
//  config.swift
//  HBPhotoBrowser
//
//  Created by 伍宏彬 on 16/8/22.
//  Copyright © 2016年 伍宏彬. All rights reserved.
//

import UIKit

func color(_ r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
    return color_a(r: r, g: g, b: b, a: 1)
}
func color_a(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}
let mainColor = color(245,g: 79,b: 85)
let KEY_HB_ORIGINIMAGE = "KEY_HB_ORIGINIMAGE"

/// 秒数转换成00:00:00
///
/// - Parameter time: 多少秒
/// - Returns: 时间字符串
func stringTime(_ time:NSInteger) -> String {
    
    let hours = String(format: "%02d", (time / 3600))
    let minutes = String(format: "%02d", ((time / 60) % 60))
    let seconds = String(format: "%02d", (time % 60))
    
    if hours == "00" {
        return minutes + ":" + seconds
    }
    return hours + ":" + minutes + ":" + seconds
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

