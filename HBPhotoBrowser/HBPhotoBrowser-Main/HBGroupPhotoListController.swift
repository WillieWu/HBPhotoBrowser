//
//  HBGroupPhotoListController.swift
//  HBGroupPhotoListController
//
//  Created by 伍宏彬 on 16/8/19.
//  Copyright © 2016年 伍宏彬. All rights reserved.
//

import UIKit
import Photos

public enum HBMeidaType {
    case `default`, video, image
}

private extension Selector {
    static let maxTap = #selector(HBBaseViewControllerDelegate.baseViewController(_:didMaxCount:))
}

//MARK: HBGroupPhotoListController
public class HBGroupPhotoListController: HBBaseViewController {

    /// 最大选中数量，默认9张
    public var maxCount: Int = 9 {
        didSet {
            kHBMaxCount = maxCount
        }
    }
    public var shouldEdit:Bool = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //1.设置默认属性
        addDefault()
        //2.添加TableView
        self.tableView.register(HBGroupPhotoListControllerCell.self, forCellReuseIdentifier: "UITableViewCellID")
        self.view.addSubview(self.tableView)
        
        //3.获取photo
        setPhotos()
        
        self.showCancleBtn()
    }
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            self.tableView.frame = self.view.safeAreaLayoutGuide.layoutFrame
        } else {
            // Fallback on earlier versions
            self.tableView.frame = self.view.bounds
        }
        
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
    
        let tabview = UITableView(frame: .zero, style: .plain)
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
        print(#file + "销毁")
        p_resetDefault()
    }
}

extension HBGroupPhotoListController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photoList.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCellID", for: indexPath) as! HBGroupPhotoListControllerCell
        cell.model = self.photoList[indexPath.row]
        return cell
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = self.photoList[indexPath.row]
        
        let collectionVc = HBPhotosController(delegate: self.delegate!)
        collectionVc.assetCollection = model.assetCollection
        self.navigationController?.pushViewController(collectionVc, animated: true)
        self.tableView.deselectRow(at: indexPath, animated: false)
 
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HBPhotoCollectionsTableViewCell_Height
    }
}

//MARK: 相册分类列表
class HBGroupPhotoListControllerCell: UITableViewCell {
    var model: photoBrowerModel? {
        didSet {
            guard model != nil else { return }
            iconImageView.image = model!.collectionLastImage
            title.text = model!.collectionTitle
            subtitle.text = model!.collectionTitleDesc
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconImageView.hb_X = 5
        iconImageView.frame.size = CGSize(width: 50, height: 50)
        iconImageView.hb_centerY = self.contentView.hb_centerY
        
        title.sizeToFit()
        title.hb_X = self.iconImageView.frame.maxX + 15
        title.hb_centerY = self.iconImageView.hb_centerY - 7
        
        subtitle.sizeToFit()
        subtitle.hb_X = title.hb_X
        subtitle.hb_Y = self.title.frame.maxY + 3
        
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
    
    leftTitle.textColor = HBPhotoCollectionsTableViewCell_TitleColor
    leftTitle.font = HBPhotoCollectionsTableViewCell_TitleFont
    
    return leftTitle
        
    }()
   fileprivate lazy var subtitle: UILabel = {
        
    let rightTitle = UILabel()
    
    rightTitle.textColor = HBPhotoCollectionsTableViewCell_SubtitleColor
    rightTitle.font = HBPhotoCollectionsTableViewCell_SubtitleFont
    
    return rightTitle
        
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: 导航控制器
public final class HBNavgationBrowser: UINavigationController {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationBar.tintColor = HBNavgation_tintColor
        self.navigationBar.barTintColor = HBNavgation_barTintColor
        self.navigationBar.titleTextAttributes = HBNavgation_titleTextAttributes
    }
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

@objc public protocol HBBaseViewControllerDelegate: NSObjectProtocol {
    
    /**
     取消，返回到根视图
     
     - parameter baseVc: baseVc
     */
    @objc optional func baseViewcontroller(didCancle baseVc: HBBaseViewController)
    
    /// - Parameters:
    ///   - baseVc: baseVc
    ///   - photos: 照片数据模型集合
    ///   - isOriginImage: 是否选择原图
    @objc optional func baseViewController(_ baseVc: HBBaseViewController, didPickPhotos photos: [HBMediaItem], isOriginImage: Bool)
    
    /// 选取的视频
    ///
    /// - Parameters:
    ///   - baseVc: 根控制器
    ///   - photo: 视频数据
    @objc optional func baseViewController(_ baseVc: HBBaseViewController, didPickVideo video: HBMediaItem)
    
    /**
     选取图片到达上限
     
     - parameter baseVc: baseVc
     */
    @objc optional func baseViewController(_ baseVc: HBBaseViewController, didMaxCount maxCount: Int)
}

private extension Selector {
    static let rightBarButtonCancleChick = #selector(HBGroupPhotoListController.cancle)
}
//#MARK: 基类
public class HBBaseViewController: UIViewController {
    
    public weak var delegate: HBBaseViewControllerDelegate?
    
    convenience public init(delegate: HBBaseViewControllerDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showCancleBtn() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.done, target: self, action: .rightBarButtonCancleChick)
    }
    
    func cancle() {
        self.delegate?.baseViewcontroller?(didCancle: self)
    }
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    var assetCollection: PHAssetCollection?
    var collectionTitle: String?
    var collectionLastImage: UIImage?
    var collectionImageCount: Int = 0
    var collectionVideoCount: Int = 0
    var collectionTitleDesc: String {
        var desc = ""
        if self.collectionImageCount > 0 {
            desc = "\(self.collectionImageCount)张照片 、"
        }
        if self.collectionVideoCount > 0 {
            desc.append("\(self.collectionVideoCount)个视频")
        }
        return desc == "" ? "0" : desc
    }
    
    
    convenience init(_ assetResult: PHAssetCollection) {
        self.init()
        let result = PHAsset.fetchAssets(in: assetResult, options: nil)
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .fast
        if let asset = result.lastObject {
            PHImageManager.default().requestImage(for: asset, targetSize:HBPhotoCollectionsTableViewCell_ImageSize , contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, imageDic) in
                self.collectionLastImage = image
            })
        }else{
            self.collectionLastImage = HBPhotoCollectionsTableViewCell_Image
        }
        self.collectionImageCount = result.countOfAssets(with: .image)
        self.collectionVideoCount = result.countOfAssets(with: .video)
        self.collectionTitle = assetResult.localizedTitle?.chinese()
        self.assetCollection = assetResult
    }
    

}

