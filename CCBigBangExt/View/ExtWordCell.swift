//
//  ExtWordCell.swift
//  CCBigBangExt
//
//  Created by sischen on 2018/1/4.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

import UIKit
import SnapKit

class ExtWordCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: CGFloat(UserDefaults.standard.float(forKey: "SegmentFontSizeSettingKey")))
        label.textAlignment = .center
        label.layer.backgroundColor = UIColor.lightGray.cgColor
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(5)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    func configUI(text: String?) -> () {
        titleLabel.text = text
    }
}
