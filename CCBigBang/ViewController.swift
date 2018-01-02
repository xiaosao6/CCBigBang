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

let s_width  = UIScreen.main.bounds.width
let s_height = UIScreen.main.bounds.height

func cellSize(ofLabelSize:CGSize) -> CGSize {
    return CGSize(width: ofLabelSize.width + 18, height: ofLabelSize.height + 18*0.5)
}


// 注意：全局定义WordCell的字体大小

class ViewController: UIViewController {

    fileprivate var dataSource = [WordModel]()
    
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
        btn.backgroundColor = UIColor.lightGray
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
        tmpcollView.backgroundColor = UIColor.white
        tmpcollView.delegate = self; tmpcollView.dataSource = self
        tmpcollView.register(WordCell.self, forCellWithReuseIdentifier: NSStringFromClass(WordCell.self))
        return tmpcollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        params.updateValue("p1C6E1V2Q5urkIxkss9n6NtBKVXXmG9KfTSlnFVk", forKey: "api_key")
        params.updateValue(inputTV.text, forKey: "text")
        params.updateValue("ws", forKey: "pattern")
        params.updateValue("json", forKey: "format")
        
        let request = HttpRequest(url: "https://api.ltp-cloud.com/analysis/", params: params)
        NSLog("\(request.reqPrint())")
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        HttpUtil.util().sendReq(request) { [weak self] (list, err) in
            MBProgressHUD.hide(for: self?.view, animated: true)
            guard let models = list else { return }
            self?.dataSource = models
            self?.collView.reloadData()
        }
    }

}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let osize = dataSource[indexPath.item].rectSize
        return cellSize(ofLabelSize: osize)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(WordCell.self), for: indexPath) as! WordCell
        cell.configUI(text: dataSource[indexPath.item].cont)
        return cell
    }
    
}

