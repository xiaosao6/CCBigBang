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
let def_input = "在语言云默认的设定中，依靠换行符对文本进行划分段落，表现的结果是含有多个para对象。在GET方式中，由于URL对特殊字符的限制，将换行符直接放在URL中可能会有错误。所以强烈建议用户不要在文本中携带换行符，推荐只输入一段话，并且依靠结尾标点来划分句子。如果您确实需要分段，语言云提供给您三种途径。"

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
    
    lazy var inputTV: UITextView = {
        let textView = UITextView.init()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 6
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.zw_placeHolder = "请输入待分词的文字"
        textView.returnKeyType = .done
        textView.delegate = self
        return textView
    }()
    
    lazy var reqBtn: UIButton = {
        let btn = UIButton.init(type: .system)
        btn.setTitle("分词", for: .normal)
        btn.addTarget(self, action: #selector(splitClicked), for: .touchUpInside)
        return btn
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
        
        self.view.addSubview(reqBtn)
        reqBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
        }
        
        self.view.addSubview(inputTV)
        inputTV.snp.makeConstraints { (make) in
            make.height.equalTo(s_height * 0.5)
            make.bottom.equalTo(reqBtn.snp.top).offset(-10)
            make.centerX.equalToSuperview()
            make.width.equalTo(s_width * 0.9)
        }
        
        LocalSegmentor.initSegmentor()
        inputTV.text = def_input
    }
    
    @objc private func splitClicked() -> () {
        dataSource = LocalSegmentor.cutIntoModel(withInput: inputTV.text)
        let sview = SplitResultView.init(frame: self.view.frame)
        self.view.addSubview(sview)
        sview.reloadWithDatas(dataSource)
        
//        var params = Dictionary<String, String>.init()
//        params.updateValue(api_key, forKey: "api_key")
//        params.updateValue(inputTV.text, forKey: "text")
//        params.updateValue("ws", forKey: "pattern")
//        params.updateValue("json", forKey: "format")
//
//        let request = HttpRequest(url: base_url, params: params)
//        NSLog("\(request.reqPrint())")
//
//        MBProgressHUD.showAdded(to: self.view, animated: true)
//        HttpUtil.util().sendReq(request) { [weak self] (list, err) in
//            MBProgressHUD.hide(for: self?.view, animated: true)
//            guard let models = list else { return }
//            self?.dataSource = models
//            self?.collView.reloadData()
//        }
    }
    
    @objc private func historyBtnClicked() -> () {
        viewDeckController?.rightViewController?.preferredContentSize = CGSize.init(width: s_width*0.8, height: s_height)
        viewDeckController?.open(.right, animated: true)
    }

}

extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let isReturn = (text == "\n")
        if isReturn { textView.resignFirstResponder();    splitClicked() }
        return !isReturn
    }
}
