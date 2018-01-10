//
//  SplitResultView.swift
//  CCBigBang
//
//  Created by sischen on 2018/1/8.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

import UIKit
import UICollectionViewLeftAlignedLayout


func isCell(cell: UICollectionViewCell, containsPoint: CGPoint) -> Bool {
    let cellSX = cell.frame.origin.x
    let cellEX = cell.frame.origin.x + cell.frame.size.width
    let cellSY = cell.frame.origin.y
    let cellEY = cell.frame.origin.y + cell.frame.size.height
    let pointerX = containsPoint.x
    let pointerY = containsPoint.y
    return pointerX >= cellSX && pointerX <= cellEX && pointerY >= cellSY && pointerY <= cellEY
}


let splitViewTag = 111

/// 分词结果View
class SplitResultView: UIView {
    
    fileprivate var dataSource = [WordModel]()
    
    fileprivate var selectedPaths = Set<IndexPath>()
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
    
    lazy var clearBtn: UIButton = {
        let btn = UIButton.init(type: .system)
        btn.backgroundColor = UIColor.white
        btn.layer.cornerRadius = 6
        btn.setTitle(" 取消 ", for: .normal)
        btn.addTarget(self, action: #selector(clearClicked(_:)), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
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
            make.height.equalTo(frame.height * 0.6)
        }
        
        self.addSubview(clearBtn)
        clearBtn.snp.makeConstraints { (make) in
            make.top.equalTo(collView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        let gestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handleGesture(_:)))
        self.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.minimumNumberOfTouches = 1
        gestureRecognizer.maximumNumberOfTouches = 1
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    func refreshWithDatas(_ datas:[WordModel]?) -> () {
        if let datas_ = datas {
            dataSource = datas_
            refreshCollViewHeight()
        }
    }
    
    fileprivate func refreshCollViewHeight() -> () {
        collView.reloadData()
    }
    
}

extension SplitResultView {
    
    @objc fileprivate func clearClicked(_ btn: UIButton) -> () {
        if selectedPaths.count > 0 {
            selectedPaths.removeAll()
            refreshCollViewHeight()
        }else{
            self.removeFromSuperview()
        }
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
        cell.configUI(model: dataSource[indexPath.item])
        
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
