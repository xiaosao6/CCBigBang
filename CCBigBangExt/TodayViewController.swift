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
    fileprivate var selectedPaths = Set<IndexPath>(){
        didSet{ topFuncView.isHidden = (selectedPaths.count == 0) }
    }
    
    fileprivate lazy var collView : UICollectionView = {
        let flowLayout = UICollectionViewLeftAlignedLayout.init()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 5; flowLayout.minimumLineSpacing = 5
        let tmpcollView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        tmpcollView.showsVerticalScrollIndicator = false
        tmpcollView.allowsMultipleSelection = true
        tmpcollView.backgroundColor = UIColor.clear
        tmpcollView.delegate = self; tmpcollView.dataSource = self
        tmpcollView.register(ExtWordCell.self, forCellWithReuseIdentifier: NSStringFromClass(ExtWordCell.self))
        return tmpcollView
    }()
    
    lazy var topFuncView: ResultTopButtonsView = {
        let tmpv = ResultTopButtonsView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width-15, height: 30))
        tmpv.delegate = self
        tmpv.isHidden = true
        return tmpv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        
        self.view.addSubview(topFuncView)
        topFuncView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(5)
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
        }
        
        self.view.addSubview(collView)
        collView.snp.makeConstraints { (make) in
            make.top.equalTo(topFuncView.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview().inset(10)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
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
    
    @objc private func setCellSelection(cell:UICollectionViewCell, path:IndexPath, selected: Bool) -> () {
        let unselColor = (dataSource[path.item].cont as NSString).isPunctuation() ? UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) : UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        cell.contentView.backgroundColor = selected ? UIColor.colorOfRGB(hex: "#007aff") : unselColor
    }
    
    @objc fileprivate func toggleSelectState(_ indexPath: IndexPath) -> () {
        guard let cell = collView.cellForItem(at: indexPath) else { return }
        if selectedPaths.contains(indexPath) {
            setCellSelection(cell: cell, path: indexPath, selected: false)
            selectedPaths.remove(indexPath)
            topFuncView.isHidden = (selectedPaths.count == 0)
        } else {
            setCellSelection(cell: cell, path: indexPath, selected: true)
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
        return dataSource[indexPath.item].rectSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ExtWordCell.self), for: indexPath) as! ExtWordCell
        cell.configUI(model: dataSource[indexPath.item], selected: selectedPaths.contains(indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleSelectState(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        toggleSelectState(indexPath)
    }
    
}

extension TodayViewController: ResultTopButtonsProtocol{
    func translateClicked(_ btn: UIButton) {
        let rvc = UIReferenceLibraryViewController.init(term: currentSelectedStrings())
//        UIApplication.shared.keyWindow?.rootViewController?.present(rvc, animated: true, completion: nil)
    }
    
    func searchClicked(_ btn: UIButton) {
        let content = (currentSelectedStrings() as NSString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: "https://m.baidu.com/s?word=" + (content ?? ""))!
        self.extensionContext?.open(url, completionHandler: nil)
    }
    
    func shareClicked(_ btn: UIButton) {
        let textToShare = currentSelectedStrings()
        let avc = UIActivityViewController.init(activityItems: [textToShare], applicationActivities: nil)
//        UIApplication.shared.keyWindow?.rootViewController?.present(avc, animated: true, completion: nil)
    }
    
    func copyClicked(_ btn: UIButton) {
        UIPasteboard.general.string = currentSelectedStrings()
//        UIApplication.shared.keyWindow?.makeToast("文本已复制", duration: 0.8, position: CSToastPositionCenter)
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
