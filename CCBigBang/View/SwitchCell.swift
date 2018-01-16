//
//  SwitchCell.swift
//  CCBigBang
//
//  Created by sischen on 2018/1/15.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

import UIKit

/// 开关Cell
class SwitchCell: UITableViewCell {
    
    lazy var titlelabel: UILabel = {
        let tmpv = UILabel.init()
        tmpv.font = UIFont.systemFont(ofSize: 15)
        return tmpv
    }()
    
    lazy var switch_: UISwitch = {
        let tmpv = UISwitch.init()
        tmpv.onTintColor = UIColor.init(red: 0.208, green: 0.573, blue: 1, alpha: 1)
        tmpv.isOn = false
        return tmpv
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(titlelabel)
        titlelabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        self.contentView.addSubview(switch_)
        switch_.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
}
