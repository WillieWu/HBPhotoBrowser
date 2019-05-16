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


##1.cocoapods安装

1.Podfile内容

	source 'https://github.com/CocoaPods/Specs.git'
	
	use_frameworks!
	platform :ios, '8.0'
	
	target '项目Target' do
	pod 'whb_HBPhotoBrowser', '~> 0.0.3'
	end
	 
2.安装

	pod install
	
3.导入头

	import whb_HBPhotoBrowser

###2.使用
---

实例化***`HBPhotoBrowser`***

		var browser: HBPhotoBrowser? //声明变量
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

	
 
***关于`<Photos.framework >`更多的介绍***

[点击这里](http://www.jianshu.com/p/5fa2e4ca8fd3)


>如果这个文章帮到了你，一定给我`Star`、点击`关注`哦！

>[项目地址](https://github.com/WillieWu/HBPhotoBrowser.git) **欢迎围观**！