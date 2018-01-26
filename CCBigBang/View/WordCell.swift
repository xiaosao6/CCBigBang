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
        label.font = UIFont.systemFont(ofSize: CGFloat(UserDefaults.standard.float(forKey: "SegmentFontSizeSettingKey")))
        label.textAlignment = .center
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var bgimgv: UIImageView = {
        let imgv = UIImageView.init()
        return imgv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(5)
        }
        
        self.contentView.insertSubview(bgimgv, belowSubview: titleLabel)
        bgimgv.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    func configUI(model: WordModel, selected: Bool) -> () {
        titleLabel.text = model.cont
        
        bgimgv.image = selected ? model.cornerBgImg_Selected : model.cornerBgImg
    }
    
}
