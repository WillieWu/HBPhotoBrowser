//
//  HBPhotoBrowser.swift
//  HBPhotoBrowser
//
//  Created by 伍宏彬 on 16/8/19.
//  Copyright © 2016年 伍宏彬. All rights reserved.
//

import UIKit
import Photos
import SnapKit


private extension Selector {
    static let maxTap = #selector(HBBaseViewControllerDelegate.baseViewController(_:didMaxCount:))
}

//MARK: HBPhotoBrowser
class HBPhotoBrowser: HBBaseViewController {

    /// 最大选中数量，默认9张
    var maxPhotos: Int = 9
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1.设置默认属性
        addDefault()
        //2.添加TableView
        self.tableView.register(HBPhotoBrowserCell.self, forCellReuseIdentifier: "UITableViewCellID")
        self.view.addSubview(self.tableView)
        
        //3.获取photo
        setPhotos()
        
        self.showCancleBtn()
    }
    
    func addDefault() {
        
        view.backgroundColor = UIColor.white
        title = "照片";
        
    }
    
    func setPhotos() {
        PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) in
            if status == .notDetermined {
                print("NotDetermined")
                
            }else if status == .authorized {
                
                DispatchQueue.global().async(execute: {
                    
                    
                    //相机胶卷
                    let cameraRoll: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
                
                    cameraRoll.enumerateObjects({ (object, index, stop) in
                        
                        let model = photoBrowerModel.init(object)
                        if model.collectionTitle == "相机胶卷" {
                            self.photoList.insert(model, at: 0)
                        }else{
                            self.photoList.append(model)
                        }
                        
                    })
                    
                    let newRoll: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
                    newRoll.enumerateObjects({ (object, index, stop) in
                        
                        let model = photoBrowerModel.init(object)
                        self.photoList.append(model)
                        
                    })
                    
                    DispatchQueue.main.async(execute: { 
                         self.tableView.reloadData()
                    })
                    
                })
            
            }else if status == .restricted {
                print("Restricted")
            }else if status == .denied {
                print("没有获取到用户授权")
                
                DispatchQueue.main.async {
                    
                    self.authorLable.text = "请在iPhone的\"设置-隐私-照片\"选项中，\n允许访问你的手机相册。"
                    self.view.addSubview(self.authorLable)

                }
                
            }
        }
    }
    //#MARK: 懒加载
   fileprivate lazy var tableView: UITableView = {
    
        let tabview = UITableView(frame: self.view.bounds, style: .plain)
        tabview.tableFooterView = UIView()
        tabview.delegate = self
        tabview.dataSource = self
        return tabview
        
    }()
   fileprivate lazy var photoList: [photoBrowerModel] = {
        
        let list = [photoBrowerModel]()
        return list
    
    }()
    
    
    
    deinit {
        print("销毁啦-------------------------1");
    }
}

extension HBPhotoBrowser: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photoList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCellID", for: indexPath) as! HBPhotoBrowserCell
        cell.model = self.photoList[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = self.photoList[indexPath.row]
        
        let collectionVc = HBPhotosController(delegate: self.delegate!)
        collectionVc.assetCollection = model.assetCollection
        self.navigationController?.pushViewController(collectionVc, animated: true)
        self.tableView.deselectRow(at: indexPath, animated: false)
 
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
}

//MARK: 相册分类列表
class HBPhotoBrowserCell: UITableViewCell {
    
    var model: photoBrowerModel? {
    
        didSet {
        
            if let getModel = model {
                
                iconImageView.image = getModel.collectionLastImage
                title.text = getModel.collectionTitle
                subtitle.text = "\(getModel.collectionImageCount)" + "张照片" + "、\(getModel.collectionVideoCount)" + "个视频"
             
            }
            
    
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconImageView.hb_X = 5
        iconImageView.frame.size = CGSize(width: 50, height: 50)
        iconImageView.hb_centerY = self.contentView.hb_centerY
        
        title.sizeToFit()
        title.hb_X = self.iconImageView.frame.maxX + 15
        title.hb_centerY = self.iconImageView.hb_centerY
        
        subtitle.sizeToFit()
        subtitle.hb_X = self.title.frame.maxX + 10
        subtitle.hb_centerY = self.title.hb_centerY
        
    }
    //FIXME: 修改frame
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(iconImageView)
        self.contentView.addSubview(title)
        self.contentView.addSubview(subtitle)
        
        
    }
    //MARK: getter 设置cell子视图
   fileprivate lazy var iconImageView: UIImageView = {
        
    let icon = UIImageView()
   
    icon.contentMode = .scaleAspectFill
    icon.layer.masksToBounds = true
    return icon
        
    }()
   fileprivate lazy var title: UILabel = {
        
    let leftTitle = UILabel()
    
    leftTitle.textColor = UIColor ( red: 0.5333, green: 0.5333, blue: 0.5333, alpha: 1.0 )
    leftTitle.font = UIFont.systemFont(ofSize: 17)
    
    return leftTitle
        
    }()
   fileprivate lazy var subtitle: UILabel = {
        
    let rightTitle = UILabel()
    
    rightTitle.textColor = UIColor ( red: 0.8637, green: 0.8637, blue: 0.8637, alpha: 1.0 )
    rightTitle.font = UIFont.systemFont(ofSize: 14)
    
    return rightTitle
        
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: 导航控制器
class HBNavgationBrowser: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.barTintColor = UIColor.black
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

@objc protocol HBBaseViewControllerDelegate: NSObjectProtocol {
    
    /**
     取消，返回到根视图
     
     - parameter baseVc: baseVc
     */
    @objc func baseViewcontroller(didCancle baseVc: HBBaseViewController)
    /**
     选取的所有图片
     
     - parameter baseVc: baseVc
     - parameter photos: [photo]
     */
    @objc optional func baseViewController(_ baseVc: HBBaseViewController, didPickPhotos photos: [photo], isOriginImage: Bool)
    
    /// 选取的视频
    ///
    /// - Parameters:
    ///   - baseVc: 根控制器
    ///   - photo: 视频数据
    @objc optional func baseViewController(_ baseVc: HBBaseViewController, didPickVideo video: photo)
    /**
     选取图片到达上限
     
     - parameter baseVc: baseVc
     */
    @objc optional func baseViewController(_ baseVc: HBBaseViewController, didMaxCount maxCount: Int)
}

private extension Selector {
    static let rightBarButtonCancleChick = #selector(HBPhotoBrowser.cancle)
}
//#MARK: 基类
class HBBaseViewController: UIViewController {
    
    weak var delegate: HBBaseViewControllerDelegate?
    
    convenience init(delegate: HBBaseViewControllerDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func showCancleBtn() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.done, target: self, action: .rightBarButtonCancleChick)
    }
    
    func cancle() {
        
        self.delegate?.baseViewcontroller(didCancle: self)
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    /**
     是否到达最大可选数量
     
     - parameter photos: 已选中的数组
     
     - returns: true 已到最大值
     */
    func checkMaxCount(_ photos: [photo]) -> Bool {
        
        let topVc = self.navigationController?.childViewControllers.first as! HBPhotoBrowser
        
        if photos.count < topVc.maxPhotos { return false}
        
        if (self.delegate?.responds(to: Selector.maxTap))! {
            self.delegate?.baseViewController!(self, didMaxCount: topVc.maxPhotos)
        }
        
        
        return true
    }
    lazy var authorLable: UILabel = {
        let deniedLable = UILabel(frame: CGRect(x: 0, y: 84, width: self.view.hb_W, height: 44))
        deniedLable.numberOfLines = 0
        deniedLable.textAlignment = .center
        deniedLable.textColor = UIColor.black
        return deniedLable
        
    }()
}
//MARK: 数据模型
class photoBrowerModel: NSObject {
    
    private let size = CGSize(width: 50, height: 50)
    private let imageCell = UIImage(named: "HBPhotoBrowser.bundle/place_icon")
    
    var assetCollection: PHAssetCollection?
    var collectionTitle: String?
    var collectionLastImage: UIImage?
    var collectionImageCount: Int = 0
    var collectionVideoCount: Int = 0
    
    convenience init(_ assetResult: PHAssetCollection) {
        self.init()
        
        let result = PHAsset.fetchAssets(in: assetResult, options: nil)
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .fast
        
        if let asset = result.lastObject {
            
            PHImageManager.default().requestImage(for: asset, targetSize:size , contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, imageDic) in
                
                self.collectionLastImage = image
                
            })
            
        }else{
            
            self.collectionLastImage = imageCell
            
        }
        self.collectionImageCount = result.countOfAssets(with: .image)
        self.collectionVideoCount = result.countOfAssets(with: .video)
        self.collectionTitle = assetResult.localizedTitle?.chinese()
        self.assetCollection = assetResult
    }
    

}
