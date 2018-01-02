//
//  PasteHistoryCell.swift
//  CCBigBang
//
//  Created by sischen on 2018/1/2.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

import UIKit

class PasteHistoryCell: UITableViewCell {

    lazy var contentLabel: UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        
        self.contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(timeLabel.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
        
        contentLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
}
