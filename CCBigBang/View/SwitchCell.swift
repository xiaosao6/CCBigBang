//
//  SwitchCell.swift
//  CCBigBang
//
//  Created by sischen on 2018/1/15.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

import UIKit


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


extension SwitchCell: ColorPickerDelegate {
    
    func currentColorChanged(to color: UIColor!) {
        colorDisplayView.backgroundColor = color
    }
    
    func colorPickCompleted(with color: UIColor!) {
        colorDisplayView.backgroundColor = color
        UserDefaults.standard.set(color.RGBString(), forKey: "SegmentCellBgColorSettingKey")
        UserDefaults.standard.synchronize()
    }
}


/// 开关Cell
class SwitchCell: UITableViewCell {
    
    static let colorPickerReuseId = NSStringFromClass(SwitchCell.self) + "_colorPicker"
    
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
    
    lazy var colorDisplayView: UIView = {
        let tmpv = UIView.init()
        tmpv.layer.cornerRadius = 8
        tmpv.layer.masksToBounds = true
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
        
        if reuseIdentifier == SwitchCell.colorPickerReuseId {
            self.contentView.addSubview(colorDisplayView)
            colorDisplayView.snp.makeConstraints { (make) in
                make.edges.equalTo(switch_)
            }
            switch_.alpha = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let color = UIColor.colorOfRGB(hex: UserDefaults.standard.string(forKey: "SegmentCellBgColorSettingKey") ?? "")
        colorDisplayView.backgroundColor = color
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        let color = UIColor.colorOfRGB(hex: UserDefaults.standard.string(forKey: "SegmentCellBgColorSettingKey") ?? "")
        colorDisplayView.backgroundColor = color
    }
    
}
