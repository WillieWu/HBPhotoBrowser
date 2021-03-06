//
//  HBPhotosController.swift
//  HBPhotoBrowser
//
//  Created by 伍宏彬 on 16/8/20.
//  Copyright © 2016年 伍宏彬. All rights reserved.
//

import UIKit
import Photos



private extension Selector {
    static let chooseBtnChick = #selector(HBCollectionViewCell.chickChooseBtn(_:))
}

class HBPhotosController: HBBaseViewController {
    
    var assetCollection: PHAssetCollection? {
    
        didSet{
            
            guard assetCollection != nil else {
                print("assetCollection == nil")
                return
            }
            
            self.title = assetCollection!.localizedTitle?.chinese()
            
            DispatchQueue.global().async(execute: {
                
                let fetchResult = PHAsset.fetchAssets(in: self.assetCollection!, options: nil)
                
                fetchResult.enumerateObjects({ (asset, index, stop) in
                    
                    let model = HBMediaItem()
                    
                    model.asset = asset
                    
                    self.photos.append(model)
                    
                })
                DispatchQueue.main.async(execute: {
                    
                    self.collectionView.reloadData()
                    
                    if self.photos.count > 0{
                        
                        self.collectionView.scrollToItem(at: IndexPath(item: self.photos.count - 1, section: 0), at: .bottom, animated: false)
                        
                    }else{
                    
                        self.authorLable.text = "没有任何照片和视频哦！！"
                        self.view.addSubview(self.authorLable)

                    
                    }
                    
                })
                
            })
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCollection()
        self.showCancleBtn()
    }

    fileprivate func addCollection() {
        
        self.view.backgroundColor = UIColor.white

        
        self.collectionView.register(HBCollectionViewCell.self, forCellWithReuseIdentifier: "HBCollectionViewCellID")
        
        view.addSubview(self.collectionView)
        
        self.buttonView.delegate = self
        view.addSubview(self.buttonView)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = CGRect(x: 0, y: 0, width: self.view.hb_W, height: self.view.hb_H - 44)
        
        if #available(iOS 11.0, *) {
            buttonView.frame = CGRect(x: 0, y: self.view.safeAreaLayoutGuide.layoutFrame.maxY - 44, width: self.view.hb_W, height: 44)
        } else {
            buttonView.frame = CGRect(x: 0, y: self.view.hb_H - 44, width: self.view.hb_W, height: 44)
        }
    }
   fileprivate lazy var collectionView: UICollectionView = {
    
        let flowLayout = UICollectionViewFlowLayout()
    
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    
        collectionview.backgroundColor = UIColor.white
        collectionview.delegate = self
        collectionview.dataSource = self
        return collectionview
    
    }()
    
    fileprivate lazy var photos: [HBMediaItem] = {
        let array = [HBMediaItem]()
        return array
    }()
    fileprivate var buttonView: HBButtomView = {
        
        let buttonView = HBButtomView(frame: .zero)
        buttonView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return buttonView
    }()
    fileprivate var selectPhotos: [HBMediaItem] = {
        let photos = [HBMediaItem]()
        return photos
    }()
    deinit {
        print(#file + "销毁")
    }
}

//#MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension HBPhotosController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HBCollectionViewCellDelegate, HBButtomViewDelegate, HBPreviewControllerDelegate {
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
        let model = self.photos[indexPath.item]
        guard model.isEnable else { return }
        if selectPhotos.count > 0 && model.asset?.mediaType == .video {
            let alterVc = UIAlertController(title: nil, message: "已选有图片，不能选择视频", preferredStyle: .alert)
            let cancleAction = UIAlertAction(title: "确定", style: .cancel) { (action) in
                print(action.title ?? "标题")
            }
            alterVc.addAction(cancleAction)
            self.present(alterVc, animated: true, completion: nil)
            return
        }

        let previewVc = HBPreviewController(delegate: self.delegate!)
        previewVc.previewDelegate = self
        previewVc.selectItem(self.photos, indexPath: indexPath, choosePhotos: self.selectPhotos)
        self.navigationController?.pushViewController(previewVc, animated: true)
                
    }
    //#MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return HBPhotos_padding
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    
        return HBPhotos_padding
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemW = (UIScreen.main.bounds.size.width - (HBPhotos_line + 1) * HBPhotos_padding) / HBPhotos_line
        return CGSize(width: itemW, height: itemW)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(HBPhotos_padding, HBPhotos_padding, HBPhotos_padding, HBPhotos_padding)
    }
    //MARK: HBCollectionViewCellDelegate
    func collectionViewChickStateBtn(_ cell: HBCollectionViewCell, model: HBMediaItem, indexPath: IndexPath, chickBtn: UIButton) {
        
        model.isSelect = !model.isSelect
        chickBtn.isSelected = model.isSelect
        
        if self.selectPhotos.contains(model) {
            let removeIndex = self.selectPhotos.index(of: model)!
            self.selectPhotos.remove(at: removeIndex)
        }else{
            self.selectPhotos.append(model)
        }
        for (index, item) in self.selectPhotos.enumerated() {
            item.index = index + 1
        }
        if self.selectPhotos.first != nil {
            kHBCanChoiceType = self.selectPhotos.first?.asset?.mediaType == .video ? .video : .image
        } else {
            kHBCanChoiceType = .default
        }
        
        kHBIsMaxCount = self.selectPhotos.count == kHBMaxCount
        self.collectionView.reloadData()
        self.selectPhotos.isEmpty ? self.buttonView.stopMidBtnAnimation() : self.buttonView.starMidBtnAnimation(String(self.selectPhotos.count))
        
        
    }
    //MARK: HBButtomViewDelegate
    func buttomViewChick(_ btn: UIButton, state: buttonChick) {
        switch state {
        case .send:
            self.delegate?.baseViewController?(self, didPickPhotos: self.selectPhotos, isOriginImage: UserDefaults.standard.bool(forKey: KEY_HB_ORIGINIMAGE))
            self.dismiss(animated: true, completion: nil)
        }
    }
    //MARK: HBPreviewControllerDelegate
    func fixChooseCell(_ model: HBMediaItem, choosePhotos: [HBMediaItem]) {
        self.selectPhotos = choosePhotos
        kHBCanChoiceType = self.selectPhotos.first?.asset?.mediaType == .video ? .video : .image
        kHBIsMaxCount = self.selectPhotos.count == kHBMaxCount
        self.collectionView.reloadData()
        self.selectPhotos.isEmpty ? self.buttonView.stopMidBtnAnimation() : self.buttonView.starMidBtnAnimation(String(self.selectPhotos.count))
    }
 
}

protocol HBCollectionViewCellDelegate: NSObjectProtocol {
    func collectionViewChickStateBtn(_ cell: HBCollectionViewCell, model: HBMediaItem, indexPath: IndexPath, chickBtn: UIButton)
}

class HBCollectionViewCell: UICollectionViewCell {
    
    private var imageSize: CGSize?
    fileprivate lazy var coverView: UIView = {
        let tl = UIView()
        tl.backgroundColor = UIColor.black
        tl.alpha = 0.5
        return tl
    }()
    weak var delegate: HBCollectionViewCellDelegate?
    var indexPath: IndexPath?
    weak var model:HBMediaItem? {
        didSet {
            guard model != nil else { return }
            let requestOptions = PHImageRequestOptions()
            requestOptions.resizeMode = .fast
            PHImageManager.default().requestImage(for: model!.asset!, targetSize:imageSize! , contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, imageDic) in
                    self.imageView.image = image
            })
            
            p_setChooseButtonState(model!)
            p_reloadMeidaType(type: model!.asset!.mediaType)
            if kHBIsMaxCount {
                model!.isEnable = model!.isSelect
            } else {
                if kHBCanChoiceType == .default || model!.asset!.mediaType == .image && kHBCanChoiceType == .image || model!.asset!.mediaType == .video && kHBCanChoiceType == .video {
                    model!.isEnable = true
                } else {
                    model!.isEnable = false
                }
            }

            self.coverView.isHidden = model!.isEnable
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
        contentView.addSubview(self.coverView)

    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.imageView.frame = self.bounds
        self.chooseBtn.frame = CGRect(x: self.hb_W - 30, y: 0, width: 30, height: 30)
        self.videoImageView.frame = CGRect(x: 0, y: self.hb_H - 20, width: 40, height: 20)

        self.timeLable.hb_W = 50
        self.timeLable.hb_H = 20
        self.timeLable.hb_X = self.hb_W - self.timeLable.hb_W - 2
        self.timeLable.hb_centerY = self.videoImageView.hb_centerY
        
        self.shadowLayer.frame = CGRect(x: 0, y: contentView.hb_H - 30, width: contentView.hb_W, height: 30)
        self.coverView.frame = contentView.bounds
    }
    @objc fileprivate func chickChooseBtn(_ getBtn: UIButton) -> Void {
        
        self.delegate?.collectionViewChickStateBtn(self, model: self.model!, indexPath: self.indexPath!, chickBtn: getBtn)
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    /// 秒数转换成00:00:00
    ///
    /// - Parameter time: 多少秒
    /// - Returns: 时间字符串
    fileprivate func stringTime(_ time:NSInteger) -> String {
        
        let hours = String(format: "%02d", (time / 3600))
        let minutes = String(format: "%02d", ((time / 60) % 60))
        let seconds = String(format: "%02d", (time % 60))
        
        if hours == "00" {
            return minutes + ":" + seconds
        }
        return hours + ":" + minutes + ":" + seconds
    }
    fileprivate lazy var imageView: UIImageView = {
        let icon = UIImageView(frame: .zero)
        icon.layer.masksToBounds = true
        icon.contentMode = .scaleAspectFill
        return icon
    }()
    fileprivate lazy var chooseBtn: UIButton = {
        
        let btn = UIButton()
        btn.setBackgroundImage(HBPhotos_select_NO_Icon, for: .normal)
        btn.setBackgroundImage(HBPhotos_select_YES_Icon, for: .selected)
        
        btn.addTarget(self, action: .chooseBtnChick, for: .touchUpInside)
        btn.setTitleColor(UIColor.white, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        btn.imageView?.contentMode = .center
        
        return btn
        
    }()
    fileprivate lazy var shadowLayer: CAGradientLayer = {
    
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)

        return layer
    
    }()
    fileprivate lazy var videoImageView: UIImageView = {
        let videoImage = UIImageView(image: UIImage.whb_imageName(name: "camera@2x.png"))
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

extension HBCollectionViewCell {
    
    func colorToblack() -> [CGColor] {
        return [color_a(r: 0, g: 0, b: 0, a: 0.0).cgColor,
                color_a(r: 0, g: 0, b: 0, a: 0.1).cgColor,
                color_a(r: 0, g: 0, b: 0, a: 0.2).cgColor,
                color_a(r: 0, g: 0, b: 0, a: 0.4).cgColor]
    }
    func color_clear() -> [CGColor] {
        return [color_a(r: 0, g: 0, b: 0, a: 0.0).cgColor,
                color_a(r: 0, g: 0, b: 0, a: 0.0).cgColor,
                color_a(r: 0, g: 0, b: 0, a: 0.0).cgColor,
                color_a(r: 0, g: 0, b: 0, a: 0.0).cgColor]
    }
    fileprivate func p_setChooseButtonState(_ model: HBMediaItem) {
        self.chooseBtn.isSelected = model.isSelect
        self.chooseBtn.isSelected ? self.chooseBtn.setTitle("\(model.index)", for: .normal) : self.chooseBtn.setTitle("", for: .normal)
    }
    fileprivate func p_reloadMeidaType(type: PHAssetMediaType) {
        self.shadowLayer.colors = type == .image ? self.color_clear() : self.colorToblack()
        self.timeLable.isHidden = type == .image ? true : false
        self.chooseBtn.isHidden = type == .image ? false : true
        self.videoImageView.isHidden = type == .image ? true : false
        if !self.timeLable.isHidden {
            self.timeLable.text = stringTime(Int(model!.asset!.duration))
        }
    }
}

public class HBMediaItem: NSObject {
    public var asset: PHAsset?
    /// 是否选中
    public var isSelect: Bool = false
    /// 展示删除
    public var isShowDelete: Bool = false
    /// 索引
    public var index: Int = 0
    
    var isEnable: Bool = true
}

