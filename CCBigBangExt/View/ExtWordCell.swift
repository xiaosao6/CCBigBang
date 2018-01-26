//
//  ExtWordCell.swift
//  CCBigBangExt
//
//  Created by sischen on 2018/1/4.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

import UIKit
import SnapKit

extension UIColor{
    
    class func colorOfRGB(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if cString.count < 6 { return UIColor.clear }
        if cString.hasPrefix("0X") || cString.hasPrefix("0x") { cString = (cString as NSString).substring(from: 2) }
        if cString.hasPrefix("#") { cString = (cString as NSString).substring(from: 1) }
        if cString.count != 6 { return UIColor.clear }
        
        var range: NSRange = NSMakeRange(0, 2)
        let rString = (cString as NSString).substring(with: range)
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        range.location = 4
        let bString = (cString as NSString).substring(with: range)
        
        var r: UInt32 = 0x0
        var g: UInt32 = 0x0
        var b: UInt32 = 0x0
        Scanner.init(string: rString).scanHexInt32(&r)
        Scanner.init(string: gString).scanHexInt32(&g)
        Scanner.init(string: bString).scanHexInt32(&b)
        
        return UIColor.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
    }
    
    
    func RGBString() -> String {
        let colors = self.cgColor.components ?? [0.0, 0.0, 0.0]
        let hexCol: String = String(format: "#%02x%02x%02x", Int(colors[0] * 255.0), Int(colors[1] * 255.0), Int(colors[2] * 255.0))
        return hexCol
    }
    
}

class ExtWordCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 17)//CGFloat(UserDefaults.standard.float(forKey: "SegmentFontSizeSettingKey")
        label.textAlignment = .center
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.init(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        self.contentView.layer.cornerRadius = 8
        
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(5)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    func configUI(model: WordModel, selected: Bool) -> () {
        titleLabel.text = model.cont

        self.contentView.backgroundColor = selected ? UIColor.colorOfRGB(hex: "#007aff") : UIColor.init(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
    }
    
}
