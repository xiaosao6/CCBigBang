//
//  WordCell.swift
//  CCBigBang
//
//  Created by sischen on 2017/12/30.
//  Copyright © 2017年 pcbdoor.com. All rights reserved.
//

import UIKit
import SnapKit



class WordCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.layer.backgroundColor = UIColor.lightGray.cgColor
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    func configUI(text: String?) -> () {
        titleLabel.text = text
    }
}
