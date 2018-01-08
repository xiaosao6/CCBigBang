//
//  SplitResultView.swift
//  CCBigBang
//
//  Created by sischen on 2018/1/8.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

import UIKit
import UICollectionViewLeftAlignedLayout


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
        tmpcollView.backgroundColor = UIColor.white
        tmpcollView.delegate = self; tmpcollView.dataSource = self
        tmpcollView.register(WordCell.self, forCellWithReuseIdentifier: NSStringFromClass(WordCell.self))
        return tmpcollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGray
        
        self.addSubview(collView)
        collView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(frame.width * 0.9)
            make.height.equalTo(frame.height * 0.5)
        }
        
        let gestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handleGesture(_:)))
        self.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.minimumNumberOfTouches = 1
        gestureRecognizer.maximumNumberOfTouches = 1
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    func reloadWithDatas(_ datas:[WordModel]) -> () {
        dataSource = datas
        collView.reloadData()
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
                collView.reloadItems(at: prev2CurrentPaths)
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
    
    @objc fileprivate func setCellSelection(cell:UICollectionViewCell?, selected: Bool) -> () {
        cell?.contentView.backgroundColor = selected ? UIColor.blue : UIColor.init(white: 0.5, alpha: 0.3)
    }
    
    @objc fileprivate func toggleSelectState(_ indexPath: IndexPath) -> () {
        let cell = collView.cellForItem(at: indexPath)
        if selectedPaths.contains(indexPath) {
            setCellSelection(cell: cell, selected: false)
            selectedPaths.remove(indexPath)
        } else {
            setCellSelection(cell: cell, selected: true)
            selectedPaths.insert(indexPath)
        }
    }
}

extension SplitResultView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return dataSource.count }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize(ofLabelSize: dataSource[indexPath.item].rectSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(WordCell.self), for: indexPath) as! WordCell
        cell.configUI(text: dataSource[indexPath.item].cont)
        
        if isPanning {
            if isPanDeleting {
                let selected = selectedPaths.subtracting(tmpPanPaths).contains(indexPath)
                setCellSelection(cell: cell, selected: selected)
            } else {
                let selected = selectedPaths.union(tmpPanPaths).contains(indexPath)
                setCellSelection(cell: cell, selected: selected)
            }
        } else {
            let selected = selectedPaths.contains(indexPath)
            setCellSelection(cell: cell, selected: selected)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { toggleSelectState(indexPath) }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) { toggleSelectState(indexPath) }
}
