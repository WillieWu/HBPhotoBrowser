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
    static let rightBarButtonCancleChick = #selector(HBPhotoBrowser.cancle)
    static let maxTap = #selector(HBBaseViewControllerDelegate.baseViewController(_:didMaxCount:))
}

//MARK: HBPhotoBrowser
class HBPhotoBrowser: HBBaseViewController, UITableViewDelegate, UITableViewDataSource {

    /// 最大选中数量，默认9张
    var maxPhotos: Int = 9
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //1.设置默认属性
        addDefault()
        //2.添加TableView
        self.tableView.register(HBPhotoBrowserCell.self, forCellReuseIdentifier: "UITableViewCellID")
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        //3.获取photo
        setPhotos()
        
        
    }
    
    func addDefault() {
        
        view.backgroundColor = UIColor.white
        title = "照片";
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.done, target: self, action: .rightBarButtonCancleChick)
        
        
    }
    func cancle() {
        
        self.delegate?.baseViewcontroller!(didCancle: self)
        
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
                    self.requestAuthorizationLable()
                }
                
            }
        }
    }
    fileprivate func requestAuthorizationLable() {
        let deniedLable = UILabel()
        deniedLable.numberOfLines = 0
        deniedLable.text = "请在iPhone的\"设置-隐私-照片\"选项中，\n允许访问你的手机相册。"
        deniedLable.textAlignment = .center
        deniedLable.textColor = UIColor.black
        self.view.addSubview(deniedLable)
        
        deniedLable.snp.makeConstraints { (make) in
            make.top.equalTo(84)
//            make.height.equalTo(50)
            make.left.right.equalToSuperview()
            
        }
        
    }
    //#MARK: 懒加载
   fileprivate lazy var tableView: UITableView = {
    
        let tabview = UITableView(frame: CGRect.zero, style: .plain)
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
extension HBPhotoBrowser {

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

//MARK: HBPhotoBrowserCell
class HBPhotoBrowserCell: UITableViewCell {
    
    var model: photoBrowerModel? {
    
        didSet {
        
            if let getModel = model {
                
                self.iconImageView.image = getModel.collectionLastImage
                self.title.text = getModel.collectionTitle
                self.subtitle.text = "\(getModel.collectionImageCount)" + "张照片" + "、\(getModel.collectionVideoCount)" + "个视频"
            }
            
    
        }
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(iconImageView)
        self.contentView.addSubview(title)
        self.contentView.addSubview(subtitle)
        
        iconImageView.snp.makeConstraints { (make) in
            
            make.left.equalTo(5)
            make.size.equalTo(50)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
        title.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        title.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(15)
            make.centerY.equalTo(iconImageView.snp.centerY)
        }
        subtitle.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        subtitle.snp.makeConstraints { (make) in
            
            make.left.equalTo(title.snp.right).offset(10)
            make.centerY.equalTo(title.snp.centerY)
            
            
        }
        
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
//MARK: HBNavgationBrowser
class HBNavgationBrowser: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.barTintColor = UIColor.black
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
    
}

@objc protocol HBBaseViewControllerDelegate: NSObjectProtocol {
    /**
     选取的所有图片
     
     - parameter baseVc: baseVc
     - parameter photos: [photo]
     */
    @objc optional func baseViewController(_ baseVc: HBBaseViewController, didPickPhotos photos: [photo])
    /**
     取消，返回到根视图
     
     - parameter baseVc: baseVc
     */
    @objc optional func baseViewcontroller(didCancle baseVc: HBBaseViewController)
    /**
     选取图片到达上限
     
     - parameter baseVc: baseVc
     */
    @objc optional func baseViewController(_ baseVc: HBBaseViewController, didMaxCount maxCount: Int)
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
}

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
