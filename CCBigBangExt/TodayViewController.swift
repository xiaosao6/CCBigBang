//
//  TodayViewController.swift
//  CCBigBangExt
//
//  Created by sischen on 2018/1/4.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

import UIKit
import NotificationCenter
import UICollectionViewLeftAlignedLayout
import MBProgressHUD

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

class TodayViewController: UIViewController, NCWidgetProviding {
    
    fileprivate var dataSource = [WordModel]()
    fileprivate var selectedPaths = Set<IndexPath>()
    
    fileprivate lazy var collView : UICollectionView = {
        let flowLayout = UICollectionViewLeftAlignedLayout.init()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 5; flowLayout.minimumLineSpacing = 5
        let tmpcollView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        tmpcollView.showsVerticalScrollIndicator = false
        tmpcollView.allowsMultipleSelection = true
        tmpcollView.backgroundColor = UIColor.white
        tmpcollView.delegate = self; tmpcollView.dataSource = self
        tmpcollView.register(ExtWordCell.self, forCellWithReuseIdentifier: NSStringFromClass(ExtWordCell.self))
        return tmpcollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    fileprivate func initUI() -> () {
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        
        self.view.addSubview(collView)
        collView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(15)
        }
    }
    
    fileprivate func refreshData() -> () {
        var params = Dictionary<String, String>.init()
        params.updateValue(api_key, forKey: "api_key")
        params.updateValue(UIPasteboard.general.string ?? "", forKey: "text")
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
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        preferredContentSize = maxSize
    }
    
}

extension TodayViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return dataSource.count }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize(ofLabelSize: dataSource[indexPath.item].rectSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ExtWordCell.self), for: indexPath) as! ExtWordCell
        cell.configUI(text: dataSource[indexPath.item].cont)
        
        let selected = selectedPaths.contains(indexPath)
        setCellSelection(cell: cell, selected: selected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleSelectState(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        toggleSelectState(indexPath)
    }
    
}
