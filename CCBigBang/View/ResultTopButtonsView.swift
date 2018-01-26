//
//  ResultTopButtonsView.swift
//  CCBigBang
//
//  Created by sischen on 2018/1/25.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

import UIKit

func topButton(titled: String?) -> UIButton {
    let btn = UIButton.init(type: .system)
    btn.setTitleColor(.white, for: .normal)
    btn.setTitle(titled, for: .normal)
    btn.backgroundColor = UIColor.darkGray
    btn.layer.cornerRadius = 7
    return btn
}


protocol ResultTopButtonsProtocol: NSObjectProtocol {
    
    func translateClicked(_ btn: UIButton) -> ()
    
    func searchClicked(_ btn: UIButton) -> ()
    
    func shareClicked(_ btn: UIButton) -> ()
    
    func copyClicked(_ btn: UIButton) -> ()
}


/// 结果顶部功能按钮View
class ResultTopButtonsView: UIView {

    weak var delegate: ResultTopButtonsProtocol?
    
    lazy var translateBtn: UIButton = {
        let btn = topButton(titled: "  翻译  ")
        btn.addTarget(self, action: #selector(translateClicked(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var searchBtn: UIButton = {
        let btn = topButton(titled: "  搜索  ")
        btn.addTarget(self, action: #selector(searchClicked(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var shareBtn: UIButton = {
        let btn = topButton(titled: "  发送  ")
        btn.addTarget(self, action: #selector(shareClicked(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var copyBtn: UIButton = {
        let btn = topButton(titled: "  复制  ")
        btn.addTarget(self, action: #selector(copyClicked(_:)), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let gap: CGFloat = 15
        let btnWidth = (frame.size.width - gap * CGFloat(4 + 1))/4.0
        
        self.addSubview(translateBtn)
        translateBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(gap)
            make.width.equalTo(btnWidth)
        }
        self.addSubview(searchBtn)
        searchBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(2 * gap + 1 * btnWidth)
            make.width.equalTo(btnWidth)
        }
        self.addSubview(shareBtn)
        shareBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(3 * gap + 2 * btnWidth)
            make.width.equalTo(btnWidth)
        }
        self.addSubview(copyBtn)
        copyBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(4 * gap + 3 * btnWidth)
            make.width.equalTo(btnWidth)
        }
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    override var isHidden: Bool{
        didSet{
            let hidden = isHidden
            UIView.animate(withDuration: 0.2) { self.alpha = hidden ? 0.0 : 1.0 }
        }
    }
}

extension ResultTopButtonsView {
    
    @objc fileprivate func translateClicked(_ btn: UIButton) -> () {
        self.delegate?.translateClicked(btn)
    }
    
    @objc fileprivate func searchClicked(_ btn: UIButton) -> () {
        self.delegate?.searchClicked(btn)
    }
    
    @objc fileprivate func shareClicked(_ btn: UIButton) -> () {
        self.delegate?.shareClicked(btn)
    }
    
    @objc fileprivate func copyClicked(_ btn: UIButton) -> () {
        self.delegate?.copyClicked(btn)
    }
}
