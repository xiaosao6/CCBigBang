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
import Toast

let s_width  = UIScreen.main.bounds.width
let s_height = UIScreen.main.bounds.height
let api_key  = "p1C6E1V2Q5urkIxkss9n6NtBKVXXmG9KfTSlnFVk"
let base_url = "https://api.ltp-cloud.com/analysis/"
let def_input = "在语言云默认的设定中，依靠换行符对文本进行划分段落，表现的结果是含有多个para对象。在GET方式中，由于URL对特殊字符的限制，将换行符直接放在URL中可能会有错误。所以强烈建议用户不要在文本中携带换行符，推荐只输入一段话，并且依靠结尾标点来划分句子。如果您确实需要分段，语言云提供给您三种途径。"


// 注意：全局定义WordCell的字体大小

class ViewController: UIViewController {
    
    lazy var inputTV: UITextView = {
        let textView = UITextView.init()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 6
        textView.font = UIFont.systemFont(ofSize: 16.5)
        textView.zw_placeHolder = "您可以手动输入待分词的文字"
        textView.returnKeyType = .done
        textView.delegate = self
        return textView
    }()
    
    lazy var reqBtn: UIButton = {
        let btn = UIButton.init(type: .system)
        btn.setTitle("分词", for: .normal)
        btn.backgroundColor = UIColor.init(white: 0.7, alpha: 0.5)
        btn.layer.cornerRadius = 6
        btn.addTarget(self, action: #selector(splitClicked), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        let historyBtn = UIButton.init(type: .system)
        historyBtn.setImage(#imageLiteral(resourceName: "icon_history"), for: .normal)
        historyBtn.addTarget(self, action: #selector(historyBtnClicked), for: .touchUpInside)
        self.view.addSubview(historyBtn)
        historyBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(50)
            make.right.equalToSuperview().inset(20)
        }
        
        let settingBtn = UIButton.init(type: .system)
        settingBtn.setImage(#imageLiteral(resourceName: "icon_setting"), for: .normal)
        settingBtn.addTarget(self, action: #selector(settingBtnClicked), for: .touchUpInside)
        self.view.addSubview(settingBtn)
        settingBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(50)
            make.left.equalToSuperview().inset(20)
        }
        
        self.view.addSubview(inputTV)
        inputTV.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize.init(width: s_width * 0.9, height: s_height * 0.5))
        }
        
        self.view.addSubview(reqBtn)
        reqBtn.snp.makeConstraints { (make) in
            make.top.equalTo(inputTV.snp.bottom).offset(20)
            make.size.equalTo(CGSize(width: 65, height: 35))
            make.centerX.equalToSuperview()
        }
        
        LocalSegmentor.initSegmentor()
        inputTV.text = UIPasteboard.general.string ?? def_input
    }
    
    @objc private func splitClicked() -> () {
        if inputTV.text.count == 0 {
            view.makeToast("请输入待分词的文字", duration: 0.8, position: CSToastPositionCenter)
            inputTV.becomeFirstResponder(); return
        }
        
        if UserDefaults.standard.bool(forKey: "CloudSegmentSettingKey") {
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
                SplitResultView.init(models: models).show()
            }
        } else {
            SplitResultView.init(models: LocalSegmentor.cutIntoModel(withInput: inputTV.text)).show()
        }
    }
    
    @objc private func historyBtnClicked() -> () {
        viewDeckController?.rightViewController?.preferredContentSize = CGSize.init(width: s_width*0.8, height: s_height)
        viewDeckController?.open(.right, animated: true)
    }
    
    @objc private func settingBtnClicked() -> () {
        viewDeckController?.leftViewController?.preferredContentSize = CGSize.init(width: s_width*0.8, height: s_height)
        viewDeckController?.open(.left, animated: true)
    }
}

extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let isReturn = (text == "\n")
        if isReturn { textView.resignFirstResponder();    splitClicked() }
        return !isReturn
    }
}
