//
//  ViewController.swift
//  CCBigBang
//
//  Created by sischen on 2017/12/29.
//  Copyright © 2017年 pcbdoor.com. All rights reserved.
//

import UIKit
import UICollectionViewLeftAlignedLayout
import MBProgressHUD
import ViewDeck

let s_width  = UIScreen.main.bounds.width
let s_height = UIScreen.main.bounds.height
let api_key  = "p1C6E1V2Q5urkIxkss9n6NtBKVXXmG9KfTSlnFVk"
let base_url = "https://api.ltp-cloud.com/analysis/"

func cellSize(ofLabelSize:CGSize) -> CGSize {
    return CGSize(width: ofLabelSize.width + 18, height: ofLabelSize.height + 18*0.5)
}

func isCell(cell: UICollectionViewCell, containsPoint: CGPoint) -> Bool {
    let cellSX = cell.frame.origin.x
    let cellEX = cell.frame.origin.x + cell.frame.size.width
    let cellSY = cell.frame.origin.y
    let cellEY = cell.frame.origin.y + cell.frame.size.height
    let pointerX = containsPoint.x
    let pointerY = containsPoint.y
    return pointerX >= cellSX && pointerX <= cellEX && pointerY >= cellSY && pointerY <= cellEY
}


// 注意：全局定义WordCell的字体大小

class ViewController: UIViewController {

    fileprivate var dataSource = [WordModel]()
    
    fileprivate var selectedPaths = Set<IndexPath>()
    fileprivate var tmpPanPaths = Set<IndexPath>()
    
    fileprivate var isPanning = false
    fileprivate var isPanDeleting: Bool{
        get{
            if let began = beganPath {
                return selectedPaths.contains(began)
            } else {
                return false
            }
        }
    }
    /// 每次手势的起始位置
    fileprivate var beganPath: IndexPath?
    /// 当前位置的前一个触摸位置
    fileprivate var prevTouchPath: IndexPath?
    
    lazy var inputTV: UITextView = {
        let textView = UITextView.init()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.text = "在语言云默认的设定中，依靠换行符对文本进行划分段落，表现的结果是含有多个para对象。在GET方式中，由于URL对特殊字符的限制，将换行符直接放在URL中可能会有错误。所以强烈建议用户不要在文本中携带换行符，推荐只输入一段话，并且依靠结尾标点来划分句子。如果您确实需要分段，语言云提供给您三种途径。"
        textView.font = UIFont.systemFont(ofSize: 15)
        return textView
    }()
    
    lazy var reqBtn: UIButton = {
        let btn = UIButton.init(type: .system)
        btn.setTitle("分词", for: .normal)
        btn.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
        return btn
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        let historyBtn = UIButton.init(type: .system)
        historyBtn.setTitle("历史", for: .normal)
        historyBtn.addTarget(self, action: #selector(historyBtnClicked), for: .touchUpInside)
        self.view.addSubview(historyBtn)
        historyBtn.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview().inset(20)
        }
        
        let gestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handleGesture(gestureRecognizer:)))
        self.view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.minimumNumberOfTouches = 1
        gestureRecognizer.maximumNumberOfTouches = 1
        
        self.view.addSubview(collView)
        collView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: s_width * 0.9, height: s_height * 0.5))
        }
        
        self.view.addSubview(reqBtn)
        reqBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
        }
        
        self.view.addSubview(inputTV)
        inputTV.snp.makeConstraints { (make) in
            make.top.equalTo(collView.snp.bottom).offset(10)
            make.bottom.equalTo(reqBtn.snp.top).offset(-10)
            make.centerX.equalToSuperview()
            make.width.equalTo(s_width * 0.9)
        }
        
    }
    
    @objc private func btnClicked() -> () {
        var params = Dictionary<String, String>.init()
        params.updateValue(api_key, forKey: "api_key")
        params.updateValue(inputTV.text, forKey: "text")
        params.updateValue("ws", forKey: "pattern")
        params.updateValue("json", forKey: "format")
        
        let request = HttpRequest(url: base_url, params: params)
        NSLog("\(request.reqPrint())")
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        HttpUtil.util().sendReq(request) { [weak self] (list, err) in
            MBProgressHUD.hide(for: self?.view, animated: true)
            guard let models = list else { return }
            self?.dataSource = models
            self?.collView.reloadData()
        }
    }
    
    @objc private func historyBtnClicked() -> () {
        viewDeckController?.open(.right, animated: true)
    }
    
    @objc private func handleGesture(gestureRecognizer: UIPanGestureRecognizer) -> () {
        let point = gestureRecognizer.location(in: collView)
        isPanning = true

        let touchingCell = collView.visibleCells.filter { (cell_) -> Bool in
            return isCell(cell: cell_, containsPoint: point)
        }.last

        if let cell = touchingCell {
            let touchOver = collView.indexPath(for: cell) ?? IndexPath(item: 0, section: 0)
            if beganPath == nil { beganPath = touchOver } // 一次手势的起始位置
            
            if touchOver != prevTouchPath {
                let began2CurrentPaths = collView.indexPathsForVisibleItems.filter { (indexPath) -> Bool in
                    return (indexPath.item >= beganPath!.item && indexPath.item <= touchOver.item) ||
                        (indexPath.item <= beganPath!.item && indexPath.item >= touchOver.item)
                }
                tmpPanPaths = Set.init(began2CurrentPaths)
                
                let prev2CurrentPaths = collView.indexPathsForVisibleItems.filter { (indexPath) -> Bool in
                    return (indexPath.item >= prevTouchPath?.item ?? 0 && indexPath.item <= touchOver.item) ||
                        (indexPath.item <= prevTouchPath?.item ?? 0 && indexPath.item >= touchOver.item)
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
    
    @objc private func setCellSelection(cell:UICollectionViewCell?, selected: Bool) -> () {
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

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleSelectState(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        toggleSelectState(indexPath)
    }
    
}
