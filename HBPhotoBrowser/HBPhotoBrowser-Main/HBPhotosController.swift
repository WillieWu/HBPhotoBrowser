//
//  HBPhotosController.swift
//  HBPhotoBrowser
//
//  Created by 伍宏彬 on 16/8/20.
//  Copyright © 2016年 伍宏彬. All rights reserved.
//

import UIKit
import Photos

let padding = 3
let line = 4

private extension Selector {
    static let chooseBtnChick = #selector(HBCollectionViewCell.chickChooseBtn(_:))
    static let rightBarButtonChick = #selector(HBPhotosController.cancleTap)
}

class HBPhotosController: HBBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HBCollectionViewCellDelegate, HBButtomViewDelegate, HBPreviewControllerDelegate {
    
    var assetCollection: PHAssetCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCollection()
    
        addBottomView()
        
        self.collectionView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(-44)
        }
        self.buttonView.snp.makeConstraints { (make) in
            make.top.equalTo(self.collectionView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            
        }
        
        if let collection = assetCollection {
            
            self.title = collection.localizedTitle?.chinese()
            
            DispatchQueue.global().async(execute: {

                let fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
                
                fetchResult.enumerateObjects({ (asset, index, stop) in
                    
                    let model = photo()
                    
                    model.asset = asset
                    
                    self.photos.append(model)
                    
                })
                DispatchQueue.main.async(execute: {
                    
                    self.collectionView.reloadData()
                    
                    if self.photos.count > 0{
                        self.collectionView.scrollToItem(at: IndexPath(item: self.photos.count - 1, section: 0), at: .bottom, animated: false)
                    }

                })
               
            })
            
        }
        
    }
    func addCollection() {
        
        self.view.backgroundColor = UIColor.white

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: .rightBarButtonChick)
        
        self.collectionView.register(HBCollectionViewCell.self, forCellWithReuseIdentifier: "HBCollectionViewCellID")
        
        view.addSubview(self.collectionView)
        
        
    }
    
    func addBottomView() {
        
        self.buttonView.delegate = self
        view.addSubview(self.buttonView)
        
        
    }
    func cancleTap(){
        
        
        self.delegate?.baseViewcontroller!(didCancle: self)
        
    }
    
   fileprivate lazy var collectionView: UICollectionView = {
    
        let flowLayout = UICollectionViewFlowLayout()
    
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionview.backgroundColor = UIColor.white
        collectionview.delegate = self
        collectionview.dataSource = self
        return collectionview
    
    }()
    
    fileprivate lazy var photos: [photo] = {
        let array = [photo]()
        return array
    }()
    fileprivate var buttonView: HBButtomView = {
        
        let buttonView = HBButtomView(frame: .zero)
        buttonView.leftBtn.isHidden = true
        buttonView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return buttonView
    }()
    fileprivate var selectPhotos: [photo] = {
        let photos = [photo]()
        return photos
    }()
    deinit {
        print("销毁啦-------------------------2");
    }
}
extension HBPhotosController {
    //#MARK: UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HBCollectionViewCellID", for: indexPath) as! HBCollectionViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.model = self.photos[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectPhotos.count > 0 {
            
            let alter = UIAlertView(title: nil, message: "已选有图片，不能选择视频", delegate: nil, cancelButtonTitle: "确定")
            alter.show()
            
            return
        }
        
        let previewVc = HBPreviewController(delegate: self.delegate!)
        previewVc.previewDelegate = self
        previewVc.selectItem(self.photos, indexPath: indexPath, choosePhotos: self.selectPhotos)
        self.navigationController?.pushViewController(previewVc, animated: true)
                
    }
    //#MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(padding)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    
        return CGFloat(padding)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemW = (UIScreen.main.bounds.size.width - CGFloat((line + 1) * padding)) / CGFloat(line)
        return CGSize(width: itemW, height: itemW)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(CGFloat(padding), CGFloat(padding), CGFloat(padding), CGFloat(padding))
    }
    //MARK: HBCollectionViewCellDelegate
    func collectionViewChickStateBtn(_ cell: HBCollectionViewCell, model: photo, indexPath: IndexPath, chickBtn: UIButton) {
        
        if !model.isSelect! && self.checkMaxCount(self.selectPhotos){ return }
        
        model.isSelect = !model.isSelect!
        chickBtn.isSelected = model.isSelect!
        
        if self.selectPhotos.contains(model) {
            
            self.selectPhotos.remove(at: self.selectPhotos.index(of: model)!)
            
        }else{
            
            chickBtn.hb_starBoundsAnimation()
            
            self.selectPhotos.append(model)
        }
        if self.selectPhotos.count == 0 {
            self.buttonView.stopMidBtnAnimation()
        }else{
            self.buttonView.starMidBtnAnimation(String(self.selectPhotos.count))
        }
        
    }
    //MARK: HBButtomViewDelegate
    func buttomViewChick(_ btn: UIButton, state: buttonChick) {
        switch state {
        case .originImage:
            print("获取原图")
        case .send:
        
            self.delegate?.baseViewController!(self, didPickPhotos: self.selectPhotos)
        }
    }
    //MARK: HBPreviewControllerDelegate
    func fixChooseCell(_ indexPath: IndexPath, model: photo, choosePhotos: [photo]) {
        self.photos[indexPath.row] = model
        self.collectionView.reloadItems(at: [indexPath])
        
        self.selectPhotos = choosePhotos
        
        if self.selectPhotos.count == 0 {
            self.buttonView.stopMidBtnAnimation()
        }else{
            self.buttonView.starMidBtnAnimation(String(self.selectPhotos.count))
        }
        
        
    }
 
}

protocol HBCollectionViewCellDelegate: NSObjectProtocol {
    func collectionViewChickStateBtn(_ cell: HBCollectionViewCell, model: photo, indexPath: IndexPath, chickBtn: UIButton)
}

class HBCollectionViewCell: UICollectionViewCell {
    
    private var imageSize: CGSize?

    weak var delegate: HBCollectionViewCellDelegate?
    
    var indexPath: IndexPath?
    
    weak var model:photo? {
    
        didSet {
        
            if model != nil {
                
                let requestOptions = PHImageRequestOptions()
                requestOptions.resizeMode = .fast
                
                PHImageManager.default().requestImage(for: model!.asset!, targetSize:imageSize! , contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, imageDic) in
                    
                        self.imageView.image = image
                    
                })
                self.chooseBtn.isSelected = (model?.isSelect)!
                
                if model?.asset?.mediaType == .image {
                    
                    self.shadowLayer.colors = color_clear()
                    self.timeLable.isHidden = true
                    self.chooseBtn.isHidden = false
                    self.videoImageView.isHidden = true
                    
                }else if model?.asset?.mediaType == .video {
                    
                    self.shadowLayer.colors = colorToBlack()
                    self.timeLable.isHidden = false
                    self.chooseBtn.isHidden = true
                    self.videoImageView.isHidden = false
                    self.timeLable.text = stringTime(Int((model?.asset?.duration)!))
                    
                }
                
                
            }
            
        }
    
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageSize = self.contentView.bounds.size
        
        contentView.addSubview(self.imageView)
        contentView.addSubview(self.chooseBtn)
        contentView.layer.insertSublayer(self.shadowLayer, above: self.imageView.layer)
        contentView.addSubview(self.videoImageView)
        contentView.addSubview(self.timeLable)
        
        self.imageView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        self.chooseBtn.snp.makeConstraints { (make) in
            make.size.equalTo(30)
            make.top.right.equalToSuperview()
        }
        self.videoImageView.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(20)
            make.left.equalTo(self).offset(5)
            make.bottom.equalTo(self).offset(-3)
        }
        
        self.timeLable.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        
        self.timeLable.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.right.equalTo(self).offset(-3)
            make.bottom.equalTo(self).offset(-3)
            
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.shadowLayer.frame = CGRect(x: 0, y: contentView.hb_H - 30, width: contentView.hb_W, height: 30)
    }
    @objc fileprivate func chickChooseBtn(_ getBtn: UIButton) -> Void {
        
        self.delegate?.collectionViewChickStateBtn(self, model: self.model!, indexPath: self.indexPath!, chickBtn: getBtn)
    }
    fileprivate func colorToBlack() -> [CGColor] {
        return [color_a(r: 0, g: 0, b: 0, a: 0.0).cgColor,
                color_a(r: 0, g: 0, b: 0, a: 0.1).cgColor,
                color_a(r: 0, g: 0, b: 0, a: 0.2).cgColor,
                color_a(r: 0, g: 0, b: 0, a: 0.4).cgColor]
    }
    fileprivate func color_clear() -> [CGColor] {
        return [color_a(r: 0, g: 0, b: 0, a: 0.0).cgColor,
                color_a(r: 0, g: 0, b: 0, a: 0.0).cgColor,
                color_a(r: 0, g: 0, b: 0, a: 0.0).cgColor,
                color_a(r: 0, g: 0, b: 0, a: 0.0).cgColor]
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    lazy var imageView: UIImageView = {
        let icon = UIImageView(frame: .zero)
        icon.layer.masksToBounds = true
        icon.contentMode = .scaleAspectFill
        return icon
    }()
    fileprivate lazy var chooseBtn: UIButton = {
        
        let btn = UIButton()
        btn.setImage(UIImage(named: "HBPhotoBrowser.bundle/select_No"), for: UIControlState())
        btn.setImage(UIImage(named: "HBPhotoBrowser.bundle/select_Yes"), for: .selected)
        btn.addTarget(self, action: .chooseBtnChick, for: .touchUpInside)
        btn.imageView?.contentMode = .center
        
        return btn
        
    }()
    fileprivate lazy var shadowLayer: CAGradientLayer = {
    
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)

        return layer
    
    }()
    lazy var videoImageView: UIImageView = {
        let videoImage = UIImageView(image: UIImage(named: "HBPhotoBrowser.bundle/camera"))
        videoImage.contentMode = .center
        return videoImage
    }()
    fileprivate lazy var timeLable: UILabel = {
        
        let zlable = UILabel()
        zlable.textAlignment = .right
        zlable.textColor = UIColor.white
        zlable.font = UIFont.systemFont(ofSize: 12)
        return zlable
        
    }()
}

class photo: NSObject {
    var asset: PHAsset?
    /// 是否选中
    var isSelect: Bool?
    /// 是否获取原图
    var isOriginImage: Bool?
    override init() {
        super.init()
        self.isSelect = false
        self.isOriginImage = false
    }
    
}


