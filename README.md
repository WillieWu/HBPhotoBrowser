####iOS8.0 swift <Photos.framework >
---

######先上个效果图吧！

![效果图](http://upload-images.jianshu.io/upload_images/620797-e2b802c1a0e6143f.gif?imageMogr2/auto-orient/strip)\

> 整Demo个写下来，没花多少时间。主要也就是拿swift练手。

***这个里面最主要的就是优化内存消耗问题了，一直控制在15M以内！***

***使用iphone5（9.2）也就是在展示所有小图片的时候，滚动灰常流畅。甚至比系统相册滚动的时候流畅。本人亲测哈。。***

---

***工程目录文件***

![目录](http://upload-images.jianshu.io/upload_images/620797-47dcd1e484fcca95.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###1.导入所需文件
导入`<Photos.framework >`与`HBPhotoBrowser-Main`

###2.使用
实例化***`HBPhotoBrowser`***

		//实例化，设置代理<HBBaseViewControllerDelegate>
		let rootVc = HBPhotoBrowser(delegate: self)
		//最大可选择数量(默认最大可选9张)
        rootVc.maxPhotos = 3
        
        let navBrowser = HBNavgationBrowser(rootViewController: rootVc)
    
        self.presentViewController(navBrowser, animated: true, completion: nil)

	
***`HBBaseViewControllerDelegate`***方法

	@objc protocol HBBaseViewControllerDelegate: NSObjectProtocol {
	
    /**
     选取的所有图片
     
     - parameter baseVc: baseVc
     - parameter photos: [photo]
     */
    optional func baseViewController(baseVc: HBBaseViewController, didPickPhotos photos: [photo])
    /**
     取消，返回到根视图
     
     - parameter baseVc: baseVc
     */
    optional func baseViewcontroller(didCancle baseVc: HBBaseViewController)
    /**
     选取图片到达上限
     
     - parameter baseVc: baseVc
     */
    optional func baseViewController(baseVc: HBBaseViewController, didMaxCount maxCount: Int)
    
	}

实现***`HBBaseViewControllerDelegate`***方法

```

	extension ViewController: HBBaseViewControllerDelegate {
    
    func baseViewcontroller(didCancle baseVc: HBBaseViewController) {
        print("取消 - 我要回老家了")
        baseVc.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    func baseViewController(baseVc: HBBaseViewController, didPickPhotos photos: [photo]) {
        print("一共选取" + String(photos.count) + "张图片")
        baseVc.dismissViewControllerAnimated(true, completion: nil)
       
    }
    
    func baseViewController(baseVc: HBBaseViewController, didMaxCount maxCount: Int) {
        
        let errorMessage = "小兄弟，最多选择" + String(maxCount) + "张"
        
        let alter = UIAlertView(title: nil, message: errorMessage, delegate: nil, cancelButtonTitle: "确定")
        alter.show()
    
   	 }
 }
 

 ```	
 
***关于`<Photos.framework >`更多的介绍***

[点击这里](http://www.jianshu.com/p/5fa2e4ca8fd3)


>如果这个文章帮到了你，一定给我`Star`、点击`关注`哦！

>[项目地址](https://github.com/WillieWu/HBPhotoBrowser.git) **欢迎围观**！