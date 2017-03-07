//
//  UIView+HBView.swift
//  HBPhotoBrowser
//
//  Created by 伍宏彬 on 16/8/19.
//  Copyright © 2016年 伍宏彬. All rights reserved.
//

import UIKit


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
