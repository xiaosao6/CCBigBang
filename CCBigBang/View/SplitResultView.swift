//
//  SplitResultView.swift
//  CCBigBang
//
//  Created by sischen on 2018/1/8.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

import UIKit
import UICollectionViewLeftAlignedLayout
import Toast


func isCell(cell: UICollectionViewCell, containsPoint: CGPoint) -> Bool {
    let cellSX = cell.frame.origin.x
    let cellEX = cell.frame.origin.x + cell.frame.size.width
    let cellSY = cell.frame.origin.y
    let cellEY = cell.frame.origin.y + cell.frame.size.height
    let pointerX = containsPoint.x
    let pointerY = containsPoint.y
    return pointerX >= cellSX && pointerX <= cellEX && pointerY >= cellSY && pointerY <= cellEY
}

func distance(_ viewA:UIView, viewB:UIView) -> Double {
    let distanceX = fabs(viewA.center.x - viewB.center.x)
    let distanceY = fabs(viewA.center.y - viewB.center.y)
    return Double(sqrt(pow(distanceX, 2) + pow(distanceY, 2)))
}




let splitViewTag = 111

/// 分词结果View
class SplitResultView: UIView {
    
    fileprivate var dataSource = [WordModel]()
    
    fileprivate var selectedPaths = Set<IndexPath>(){
        didSet{ topFuncView.isHidden = (selectedPaths.count == 0) }
    }
    fileprivate var tmpPanPaths = Set<IndexPath>()
    
    fileprivate var isPanning = false
    fileprivate var isPanDeleting: Bool{
        get{
            if let began = beganPath { return selectedPaths.contains(began) }
            return false
        }
    }
    /// 每次手势的起始位置
    fileprivate var beganPath: IndexPath?
    /// 当前位置的前一个触摸位置
    fileprivate var prevTouchPath: IndexPath?
    
    fileprivate lazy var collView : UICollectionView = {
        let flowLayout = UICollectionViewLeftAlignedLayout.init()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 5; flowLayout.minimumLineSpacing = 5
        let tmpcollView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        tmpcollView.showsVerticalScrollIndicator = false
        tmpcollView.allowsMultipleSelection = true
        tmpcollView.backgroundColor = UIColor.clear
        tmpcollView.delegate = self; tmpcollView.dataSource = self
        tmpcollView.register(WordCell.self, forCellWithReuseIdentifier: NSStringFromClass(WordCell.self))
        return tmpcollView
    }()
    
    lazy var topFuncView: ResultTopButtonsView = {
        let tmpv = ResultTopButtonsView.init(frame: CGRect(x: 0, y: 0, width: s_width, height: 30))
        tmpv.delegate = self
        tmpv.isHidden = true
        return tmpv
    }()
    
    lazy var clearBtn: UIButton = {
        let btn = UIButton.init(type: .system)
        btn.setImage(#imageLiteral(resourceName: "icon_close"), for: .normal)
        btn.tintColor = UIColor.colorOfRGB(hex: UserDefaults.standard.string(forKey: "SegmentCellBgColorSettingKey") ?? "")
        btn.addTarget(self, action: #selector(clearClicked(_:)), for: .touchUpInside)
        return btn
    }()
    
    convenience init(models:[WordModel]?) {
        self.init(frame: CGRect.init(x: 0, y: 0, width: s_width, height: s_height))
        dataSource = models ?? [WordModel]()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.tag = splitViewTag
        
        //模糊背景
        let effectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .extraLight))
        effectView.frame = frame
        self.addSubview(effectView)
        
        self.addSubview(collView)
        collView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(frame.width * 0.9)
            make.height.equalTo(frame.height * 0.5)
        }
        
        self.addSubview(clearBtn)
        clearBtn.snp.makeConstraints { (make) in
            make.top.equalTo(collView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(topFuncView)
        topFuncView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(collView.snp.top).offset(-20)
            make.height.equalTo(30)
        }
        
        let gestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handleGesture(_:)))
        self.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.minimumNumberOfTouches = 1
        gestureRecognizer.maximumNumberOfTouches = 1
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    func show(inView: UIView?) -> () {
        inView?.addSubview(self)
        
        collView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            let contentH = self.collView.contentSize.height; let max_H = self.bounds.height * 0.5
            let minH = contentH < max_H ? contentH : max_H
            self.collView.snp.updateConstraints { (make) in
                make.height.equalTo(minH)
            }
            
            let centerIndex = self.collView.indexPathsForVisibleItems.count/2
            guard let centerCell = self.collView.cellForItem(at: IndexPath(item: centerIndex, section: 0)) else { return }
            
            for cell in self.collView.visibleCells {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0012 * distance(cell, viewB: centerCell)) {
                    cell.transform = CGAffineTransform.init(scaleX: 0.7, y: 0.5)
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    })
                }
            }
        }
    }
    
    deinit { NSLog("\(self.classForCoder.description())销毁了") }
    
}

extension SplitResultView {
    @objc fileprivate func clearClicked(_ btn: UIButton) -> () {
        if selectedPaths.count > 0 {
            selectedPaths.removeAll(); topFuncView.isHidden = true
            collView.reloadData()
        } else {
            self.removeFromSuperview()
        }
    }
}

extension SplitResultView: ResultTopButtonsProtocol{
    func translateClicked(_ btn: UIButton) {
        let rvc = UIReferenceLibraryViewController.init(term: currentSelectedStrings())
        UIApplication.shared.keyWindow?.rootViewController?.present(rvc, animated: true, completion: nil)
    }
    
    func searchClicked(_ btn: UIButton) {
        let content = (currentSelectedStrings() as NSString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: "https://m.baidu.com/s?word=" + (content ?? ""))!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    func shareClicked(_ btn: UIButton) {
        let textToShare = currentSelectedStrings()
        let avc = UIActivityViewController.init(activityItems: [textToShare], applicationActivities: nil)
        UIApplication.shared.keyWindow?.rootViewController?.present(avc, animated: true, completion: nil)
    }
    
    func copyClicked(_ btn: UIButton) {
        UIPasteboard.general.string = currentSelectedStrings()
        UIApplication.shared.keyWindow?.makeToast("文本已复制", duration: 0.8, position: CSToastPositionCenter)
        self.removeFromSuperview()
    }
    
    private func currentSelectedStrings() -> String {
        var selectedStrings = [String]()
        for model in dataSource {
            if selectedPaths.contains(IndexPath(item: dataSource.index(of: model)!, section: 0)){
                selectedStrings.append(model.cont)
            }
        }
        return selectedStrings.joined(separator: "")
    }
}

// MARK: - 处理手势、选择/取消选择的切换
extension SplitResultView {
    
    @objc private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) -> () {
        let point = gestureRecognizer.location(in: collView)
        isPanning = true
        
        let touchingCell = collView.visibleCells.filter { (cell_) -> Bool in
            return isCell(cell: cell_, containsPoint: point)
        }.last
        
        if let cell = touchingCell {
            let touchOver = collView.indexPath(for: cell)!
            if beganPath == nil { beganPath = touchOver } // 一次手势的起始位置
            
            if touchOver != prevTouchPath {
                let began2CurrentPaths = collView.indexPathsForVisibleItems.filter { (indexPath) -> Bool in
                    return (indexPath.item >= beganPath!.item && indexPath.item <= touchOver.item) ||
                        (indexPath.item <= beganPath!.item && indexPath.item >= touchOver.item)
                }
                tmpPanPaths = Set.init(began2CurrentPaths)
                
                let prev2CurrentPaths = collView.indexPathsForVisibleItems.filter { (indexPath) -> Bool in
                    return (indexPath.item >= (prevTouchPath ?? touchOver).item && indexPath.item <= touchOver.item) ||
                        (indexPath.item <= (prevTouchPath ?? touchOver).item && indexPath.item >= touchOver.item)
                }
                UIView.performWithoutAnimation { collView.reloadItems(at: prev2CurrentPaths) }
            }
            prevTouchPath = touchOver
        }
        
        if gestureRecognizer.state == .ended {
            prevTouchPath = nil
            isPanning = false
            if isPanDeleting {
                selectedPaths = selectedPaths.subtracting(tmpPanPaths)
            } else {
                selectedPaths = selectedPaths.union(tmpPanPaths)
            }
            tmpPanPaths.removeAll()
            beganPath = nil
            collView.isScrollEnabled = true
        }
    }
    
    @objc fileprivate func setCellSelection(cell:UICollectionViewCell, path:IndexPath, selected: Bool) -> () {
        let model = dataSource[path.item]
        (cell as? WordCell)?.bgimgv.image = selected ? model.cornerBgImg_Selected : model.cornerBgImg
    }
    
    @objc fileprivate func toggleSelectState(_ indexPath: IndexPath) -> () {
        guard let cell = collView.cellForItem(at: indexPath) else { return }
        if selectedPaths.contains(indexPath) {
            setCellSelection(cell: cell, path:indexPath, selected: false)
            selectedPaths.remove(indexPath)
            topFuncView.isHidden = (selectedPaths.count == 0)
        } else {
            setCellSelection(cell: cell, path:indexPath, selected: true)
            selectedPaths.insert(indexPath)
        }
    }
}

extension SplitResultView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return dataSource.count }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return dataSource[indexPath.item].rectSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(WordCell.self), for: indexPath) as! WordCell
        cell.configUI(model: dataSource[indexPath.item], selected: selectedPaths.contains(indexPath))
        
        if isPanning {
            if isPanDeleting {
                let selected = selectedPaths.subtracting(tmpPanPaths).contains(indexPath)
                setCellSelection(cell: cell, path:indexPath, selected: selected)
            } else {
                let selected = selectedPaths.union(tmpPanPaths).contains(indexPath)
                setCellSelection(cell: cell, path:indexPath, selected: selected)
            }
        } else {
            let selected = selectedPaths.contains(indexPath)
            setCellSelection(cell: cell, path:indexPath, selected: selected)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { toggleSelectState(indexPath) }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) { toggleSelectState(indexPath) }
}
