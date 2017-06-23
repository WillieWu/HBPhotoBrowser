//
//  HBPreviewController.swift
//  HBPhotoBrowser
//
//  Created by 伍宏彬 on 16/8/20.
//  Copyright © 2016年 伍宏彬. All rights reserved.
//

import UIKit
import Photos

let previewPadding = 1.0

private extension Selector {
    static let rightChooseBtnChick = #selector(HBPreviewController.chickChooseBtn)
    static let tapSingle = #selector(HBScrollerView.singleTap)
    static let tapDouble = #selector(HBScrollerView.doubleTap)
    static let buttomSendChick = #selector(HBButtomView.sendBtnChick(_:))
    static let customBtnChick = #selector(HBButton.tap(_:))
}

protocol HBPreviewControllerDelegate: NSObjectProtocol {
    
    func fixChooseCell(_ indexPath: IndexPath, model: photo, choosePhotos: [photo])
    
}

//FIXME: 1.翻页增加间距
//FIXME: 2.翻页预览下一张，以免频幕会闪一下

class HBPreviewController: HBBaseViewController {
    
    weak var previewDelegate: HBPreviewControllerDelegate?
    var _index: IndexPath?
    
    var player: AVPlayer?
    var playLayer: AVPlayerLayer?
    var timeObserverToken: Any?
    
    /// 视频数据
    var videoModel: photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.collectionView.register(HBPreviewCollectionCell.self, forCellWithReuseIdentifier: "HBPreviewCollectionCellID")
        
        view.addSubview(self.collectionView)
        
        view.addSubview(self.playView)

        self.buttonView.delegate = self
        view.addSubview(self.buttonView)
        
        if let index = _index {
            
            self.collectionView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.collectionView.scrollToItem(at: index, at: UICollectionViewScrollPosition(), animated: false)
            })
            
            self.fixButtomState()
        }
       
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.collectionView.frame = self.view.bounds
        self.playView.hb_W = 64
        self.playView.hb_H = 64
        self.playView.hb_center = self.view.center
        
        self.buttonView.frame = CGRect(x: 0, y: self.view.hb_H - 44, width: self.view.hb_W, height: 44)
        
//        if !self.navigationController!.navigationBar.isTranslucent {
//            self.collectionView.hb_Y = -64
//        }
//        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let _ = player {
            
            if (self.timeObserverToken != nil) {
                player?.removeTimeObserver(self.timeObserverToken!)
            }
            player?.pause()
            player = nil

        }
        
    }
    
    /**
     设置预览
     
     - parameter assetResult: 结果集
     - parameter indexPath:   选中IndexPath
     */
    func selectItem(_ photos: [photo], indexPath: IndexPath, choosePhotos: [photo]) {
        
        let model = photos[indexPath.item]
        
        if model.asset?.mediaType == .image {
            
            self.playView.isHidden = true
            
            _index = indexPath
            
            self.list += photos

            self.tempList += choosePhotos
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.chooseBtn)
            
            self.title = "\(indexPath.item + 1)" + "/" + "\(self.list.count)"
            
            self.chooseBtn.isSelected = model.isSelect

        }else if model.asset?.mediaType == .video {
            
            videoModel = model
            
            self.collectionView.isHidden = true
            self.buttonView.leftBtn.isHidden = true
            self.buttonView.rightBtn.isEnabled = true
            PHImageManager.default().requestPlayerItem(forVideo: model.asset!, options: nil, resultHandler: { (playerItem, assetDic) in
                
                DispatchQueue.main.async {

                    let durationTime = Int((playerItem?.asset.duration.value)!)/Int((playerItem?.asset.duration.timescale)!)
                    
                    self.player = AVPlayer(playerItem: playerItem)
                    self.playLayer = AVPlayerLayer(player: self.player)
                    self.playLayer?.backgroundColor = UIColor.black.cgColor
                    self.playLayer?.frame = CGRect(x: 0, y: 0, width: self.view.hb_W, height: self.view.hb_H)
                    self.playLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                    self.view.layer.insertSublayer(self.playLayer!, at: 0)
                    //监听播放状态
                    self.timeObserverToken = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: DispatchQueue.main, using: { [weak self] (cmtime) in
                        
                        let currentTime = Int(cmtime.value)/Int(cmtime.timescale)
                    
                        if currentTime < durationTime { return }
                        //播放完成，跳到开始
                        self?.player?.seek(to: CMTimeMake(0, 1), completionHandler: { (isFinish) in
                            if isFinish {
                                
                                self?.playView.isHidden = !(self?.playView.isHidden)!
                                self?.player?.pause()
                            }
                        })
                    
                    })
                }
                
            })
            
            
        }
    
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard self.collectionView.isHidden else {
            return;
        }
    
        playBtnChick()
    
    }
    /**
     获取当前cell
     
     - returns: 目标cell
     */
    fileprivate func getVisibleCell() -> (cell: HBPreviewCollectionCell, indexPath: IndexPath, model: photo) {
        let cell = self.collectionView.visibleCells.first as! HBPreviewCollectionCell
        let indexPath = self.collectionView.indexPath(for: cell)
        let model = self.list[(indexPath?.item)!]
        
        return (cell,indexPath!,model)
    }
    /**
     修改工具栏状态
     */
    fileprivate func fixButtomState() {
        if self.tempList.count == 0 {
            self.buttonView.stopMidBtnAnimation()
        }else{
            self.buttonView.starMidBtnAnimation(String(self.tempList.count))
        }
    }
    /**
     设置所有按钮状态
     
     - parameter result: photo
     */
    fileprivate func setChooseBtnStatus(_ result: photo) {
        
        self.chooseBtn.isSelected = result.isSelect
        
    }

    @objc fileprivate func chickChooseBtn() {
        
        let group = getVisibleCell()
        
        if !group.model.isSelect && self.checkMaxCount(self.tempList) { return }
        
        group.model.isSelect = !group.model.isSelect
        
        self.chooseBtn.isSelected = group.model.isSelect
        
        if self.tempList.contains(group.model) {
            self.tempList.remove(at: self.tempList.index(of: group.model)!)
            
        }else{
            self.tempList.append(group.model)
        }
        fixButtomState()
        self.previewDelegate?.fixChooseCell(group.indexPath, model: group.model, choosePhotos: self.tempList)
    }
    
    @objc fileprivate func playBtnChick() {
        
        if self.playView.isHidden {
            self.player?.pause()
        }else{
            self.player?.play()
        }
        self.playView.isHidden = !self.playView.isHidden
        
        let isBarHide = self.navigationController?.navigationBar.isHidden
        self.navigationController?.setNavigationBarHidden(!isBarHide!, animated: false)
        self.setNeedsStatusBarAppearanceUpdate()
        self.buttonView.starAlphaAnimation(!isBarHide!)
        
    }
    override var prefersStatusBarHidden: Bool {
        return (self.navigationController?.navigationBar.isHidden)!
    }
    fileprivate lazy var collectionView: UICollectionView = {
    
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    
    }()
    fileprivate lazy var list: [photo] = {
        let list = [photo]()
        return list
    }()
    fileprivate lazy var tempList: [photo] = {
    
        let tempList = [photo]()
        return tempList
    }()
    fileprivate lazy var chooseBtn: UIButton = {
    
        let btn = UIButton.init(type: UIButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn.setImage(UIImage(named: "HBPhotoBrowser.bundle/select_No"), for: UIControlState())
        btn.setImage(UIImage(named: "HBPhotoBrowser.bundle/select_Yes"), for: .selected)
        btn.addTarget(self, action: .rightChooseBtnChick, for: .touchUpInside)
        btn.imageView?.contentMode = .center
        return btn
    
    }()
    fileprivate lazy var playView: UIImageView = {
        
        let image = UIImageView(image: UIImage(named: "HBPhotoBrowser.bundle/play"))
        
        return image
        
    }()
    fileprivate var buttonView: HBButtomView = {
        
        let buttonView = HBButtomView(frame: .zero)
        buttonView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return buttonView
    }()
    deinit {
        print("销毁啦-------------------------3");
    }
}
extension HBPreviewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, HBPreviewCollectionCellDelegate,HBButtomViewDelegate {
     //#MARK: UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return self.list.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HBPreviewCollectionCellID", for: indexPath) as! HBPreviewCollectionCell
        let result = self.list[indexPath.item] 
        cell.addPreview(fillImage: result.asset!)
        cell.delegate = self
 
        return cell
    }
     //#MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.hb_W - CGFloat(previewPadding * 2), height: self.view.hb_H)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(previewPadding * 2)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: CGFloat(previewPadding), bottom: 0, right: CGFloat(previewPadding))
    }
    //MARK: UIScrollerViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
        
        let result = self.list[index]
        
        self.setChooseBtnStatus(result)
        
        self.title = "\(index + 1)" + "/" + "\(self.list.count)"
    }
    //#MARK: HBPreviewCollectionCellDelegate
    func getChickCell(_ cell: HBPreviewCollectionCell, tapStatus: TouchStauts) {
        
        switch tapStatus {
        case .singleTap:
            print("singleTap")
            let isBarHide = self.navigationController?.navigationBar.isHidden
            self.navigationController?.setNavigationBarHidden(!isBarHide!, animated: false)
            self.setNeedsStatusBarAppearanceUpdate()
            self.buttonView.starAlphaAnimation(!isBarHide!)
            
        case .doubleTap:
            
            let isBarHide = self.navigationController?.navigationBar.isHidden
            if !isBarHide! {
                self.navigationController?.setNavigationBarHidden(!isBarHide!, animated: false)
                self.setNeedsStatusBarAppearanceUpdate()
                self.buttonView.starAlphaAnimation(!isBarHide!)
            }
           
            print("doubleTap")
            
        }
    }
    //MARK: HBButtomViewDelegate
    func buttomViewChick(_ btn: UIButton, state: buttonChick) {
        switch state {
        case .send:
            
            guard videoModel != nil else {
                self.delegate?.baseViewController?(self, didPickPhotos: self.tempList, isOriginImage: UserDefaults.standard.bool(forKey: KEY_HB_ORIGINIMAGE))
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            self.delegate?.baseViewController?(self, didPickVideo: videoModel!)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

protocol HBPreviewCollectionCellDelegate: NSObjectProtocol {

    func getChickCell(_ cell: HBPreviewCollectionCell, tapStatus: TouchStauts)

}

class HBPreviewCollectionCell: UICollectionViewCell {
    
    private let imageSize = UIScreen.main.bounds.size
    
    weak var delegate: HBPreviewCollectionCellDelegate?
    
    func addPreview(fillImage asset: PHAsset) {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options, resultHandler: { (image, imageDic) in
            
            if let getImage = image {
                self.scrollerView.setBigImage(getImage)
            }
            
        })
    }
   
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(self.scrollerView)
        
        self.scrollerView.scollerViewDidTouch { (stauts) in
            
            self.delegate?.getChickCell(self, tapStatus: stauts)
            
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.scrollerView.frame = self.bounds
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate lazy var scrollerView: HBScrollerView = {
        let scrollerview = HBScrollerView()
        return scrollerview
    }()
    
    
    
}
//MARK: HBScrollerView
public enum TouchStauts : Int {
    case singleTap
    case doubleTap

}
typealias tapBlock = (_ stauts: TouchStauts) -> Void
class HBScrollerView: UIScrollView {
    
    fileprivate var myTouch: tapBlock?
    fileprivate var tempScale: CGFloat = 0
    
    func setBigImage(_ image: UIImage) {
        self.bigImageView.image = image
        
        let originImageSize = CGSize(width: image.size.width / UIScreen.main.scale, height: image.size.height / UIScreen.main.scale)
        
        let parsent = originImageSize.width / originImageSize.height
    
        var fixImageSize: CGSize = CGSize.zero
        var fixImageX: CGFloat = 0
        var fixImageY: CGFloat = 0
        
        if parsent >= 1 {//横
            
            let scrollerViewSize = self.bounds.size
            fixImageSize = CGSize(width: scrollerViewSize.width, height: scrollerViewSize.width * originImageSize.height / originImageSize.width)
            fixImageY = (scrollerViewSize.height - fixImageSize.height) * 0.5
            fixImageX = 0
            
        }else if parsent < 1 {//竖
            
            let scrollerViewSize = self.bounds.size
            
            let tempH = scrollerViewSize.width * originImageSize.height / originImageSize.width
            
            fixImageSize = CGSize(width: scrollerViewSize.width , height: tempH)
            
            fixImageY = (scrollerViewSize.height - fixImageSize.height) * 0.5
            fixImageX = 0
        }
        
        self.bigImageView.frame = CGRect(origin: CGPoint(x: fixImageX, y: max(fixImageY, 0)), size: fixImageSize)
        self.maximumZoomScale = 3
        self.minimumZoomScale = 1
        self.contentSize = fixImageSize
        self.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
//        print(String(originImageSize) + String(fixImageSize))
    }
    func scollerViewDidTouch(_ touch: tapBlock?) {
        self.myTouch = touch
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
//        self.bounces = false
//        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.addSubview(self.bigImageView)
        self.bigImageView.addGestureRecognizer(self.tap)
        self.bigImageView.addGestureRecognizer(self.tapTwo)
        self.tap.require(toFail: self.tapTwo)
        self.setZoomScale(self.minimumZoomScale, animated: false)
        self.pinchGestureRecognizer?.delegate = self
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc fileprivate func singleTap() {
    
        if let touch = self.myTouch {
            touch(.singleTap)
        }
    }
    //#MARK: 双击
    @objc fileprivate func doubleTap() {
    
        let point = self.tapTwo.location(in: self.bigImageView)
        
        if self.zoomScale == self.maximumZoomScale {
            self.setZoomScale(self.minimumZoomScale, animated: true)
        }else{
            self.zoom(to: CGRect(origin: point, size: CGSize(width: self.maximumZoomScale, height: self.maximumZoomScale)), animated: true)
        }
        if let touch = self.myTouch {
            touch(.doubleTap)
        }
    }
   
    fileprivate lazy var bigImageView: UIImageView = {
        
        let content: UIImageView = UIImageView()
        content.contentMode = .scaleAspectFill
        content.isUserInteractionEnabled = true

        return content
        
    }()
    fileprivate lazy var tap: UITapGestureRecognizer = {
    
        let tap = UITapGestureRecognizer(target: self, action: .tapSingle)
        return tap
    }()
    fileprivate lazy var tapTwo: UITapGestureRecognizer = {
        
        let tapTwo = UITapGestureRecognizer(target: self, action: .tapDouble)
        tapTwo.numberOfTapsRequired = 2;
        return tapTwo
    }()
  
}
extension HBScrollerView: UIScrollViewDelegate,UIGestureRecognizerDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.bigImageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {

        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
        (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
        (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0
        self.bigImageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
        y: scrollView.contentSize.height * 0.5 + offsetY);
    
    }

}
//MARK: 底部工具栏
public enum buttonChick: Int {
    case send
}

protocol HBButtomViewDelegate: NSObjectProtocol {
    func buttomViewChick(_ btn: UIButton,state: buttonChick)
}

class HBButtomView: UIView {
    
    weak var delegate: HBButtomViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.leftBtn.isSelected = UserDefaults.standard.bool(forKey: KEY_HB_ORIGINIMAGE)
        self.addSubview(self.leftBtn)
        self.addSubview(self.rightBtn)
        
        
        self.leftBtn.chick { (btn) in
            
            btn.isSelected = !btn.isSelected
        
            UserDefaults.standard.set(btn.isSelected, forKey: KEY_HB_ORIGINIMAGE)
            
        }

    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.leftBtn.frame = CGRect(x: 0, y: 0, width: 120, height: self.hb_H)
        
        self.rightBtn.frame = CGRect(x: self.hb_W - 100, y: 0, width: 100, height: self.hb_H)
        
    }
    /**
     清空选中数字提示
     */
    func stopMidBtnAnimation() {
        
        self.rightBtn.isEnabled = false
        
        self.rightBtn.setTitle("确定", for: UIControlState())
        
    }
    /**
     开始选中数据提示
     
     - parameter title: 显示数字
     */
    func starMidBtnAnimation(_ title: String) {
        
        self.rightBtn.isEnabled = true
        
        self.rightBtn.setTitle("确定 (\(title))", for: UIControlState())
        
        
    }
    /**
     渐变动画
     
     - parameter isHide: 是否隐藏
     */
    func starAlphaAnimation(_ isHide: Bool) {
        
        if isHide {
            
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 0
            }, completion: { (Finished) in
                self.isHidden = isHide
            }) 
        }else{
            self.isHidden = isHide
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 1
            }, completion: { (Finished) in
                
            }) 
        
        }
        
        
    }
    
    @objc fileprivate func sendBtnChick(_ btn: UIButton) {
    
        self.delegate?.buttomViewChick(btn, state: .send)
        UserDefaults.standard.set(false, forKey: KEY_HB_ORIGINIMAGE)
    
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var leftBtn: HBButton = {
    
        let btn = HBButton()
        btn.setImage(UIImage(named: "HBPhotoBrowser.bundle/select_No"), for: UIControlState())
        btn.setImage(UIImage(named: "HBPhotoBrowser.bundle/select_Yes"), for: .selected)
        btn.setTitle("原图", for: UIControlState())
        return btn
    
    }()
    lazy var rightBtn: UIButton = {
        
        let btn = UIButton()
        btn.setTitleColor(HBPhoto_Buttom_Send_Color_Normal, for: UIControlState())
        btn.setTitleColor(HBPhoto_Buttom_Send_Color_Disabled, for: .disabled)
        btn.setTitle("确定", for: UIControlState())
        btn.addTarget(self, action: .buttomSendChick, for: .touchUpInside)
        btn.isEnabled = false
        return btn
        
    }()
  
}

//MARK: 自定义Button
typealias buttonBlock = (_ btn: HBButton) -> Void
let imagePrasent: CGFloat = 0.3

class HBButton: UIButton {
    
    fileprivate var chickBlock: buttonBlock?
    
    func chick(_ chickBlock: @escaping buttonBlock) {
        self.chickBlock = chickBlock
    }
    @objc fileprivate func tap(_ btn: HBButton) {
        
            self.chickBlock?(self)

    }
    
   override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.imageView?.contentMode = .center
        self.setTitleColor(UIColor ( red: 0.8902, green: 0.8902, blue: 0.8902, alpha: 1.0 ), for: UIControlState())
        self.setTitleColor(UIColor.white, for: .selected)
        self.addTarget(self, action: .customBtnChick, for: .touchUpInside)
    
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.hb_W * imagePrasent, height: self.hb_H))
    }
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: self.hb_W * imagePrasent, y: 0, width: self.hb_W * (1 - imagePrasent), height: self.hb_H)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
