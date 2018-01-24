//
//  SettingsViewController.swift
//  CCBigBang
//
//  Created by sischen on 2018/1/15.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

import UIKit
import Toast

/// 设置界面
class SettingsViewController: UIViewController {
    
    var dataSource = [["云端分词": UserDefaults.standard.bool(forKey: "CloudSegmentSettingKey")],
                      ["更大字体": UserDefaults.standard.float(forKey: "SegmentFontSizeSettingKey") == 20.0],
                      ["更多拷贝历史": UserDefaults.standard.integer(forKey: "PasteHistorySizeSettingKey") == 20],
                      ["词语选中颜色": UserDefaults.standard.string(forKey: "SegmentCellBgColorSettingKey") ?? ""]]
    
    lazy var tbView: UITableView = {
        let tmptbView = UITableView.init(frame: CGRect.zero, style: .plain)
        tmptbView.delegate = self; tmptbView.dataSource = self
        tmptbView.separatorInset = UIEdgeInsets.zero
        tmptbView.separatorColor = UIColor.lightGray
        tmptbView.tableFooterView = UIView()
        tmptbView.rowHeight = 50
        tmptbView.register(SwitchCell.self, forCellReuseIdentifier: NSStringFromClass(SwitchCell.self))
        tmptbView.register(SwitchCell.self, forCellReuseIdentifier: SwitchCell.colorPickerReuseId)
        return tmptbView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor.white

        self.view.addSubview(tbView)
        tbView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(50)
            make.bottom.equalToSuperview().offset(-15)
        }
    }

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < dataSource.count-1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SwitchCell.self), for: indexPath) as! SwitchCell
            cell.titlelabel.text = dataSource[indexPath.row].keys.first
            cell.switch_.tag = 110 + indexPath.row
            cell.switch_.isOn = dataSource[indexPath.row].values.first as! Bool
            cell.switch_.addTarget(self, action: #selector(switchOfCellChanged(switch_:)), for: .valueChanged)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.colorPickerReuseId, for: indexPath) as! SwitchCell
        cell.titlelabel.text = dataSource[indexPath.row].keys.first
        cell.colorDisplayView.backgroundColor = UIColor.colorOfRGB(hex: dataSource[indexPath.row].values.first as! String)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == dataSource.count-1 {
            let cell = tableView.cellForRow(at: indexPath) as! SwitchCell
            let colorPicker = RoundColorPicker.init(color: UIColor.red)
            colorPicker?.delegate = cell
            colorPicker?.show(in: self.view)
        }
    }
    
}

extension SettingsViewController {
    
    @objc func switchOfCellChanged(switch_:UISwitch) -> () {
        let index = (switch_.tag - 110)
        let settingtitle = dataSource[index].keys.first!
        dataSource[index].updateValue(switch_.isOn, forKey: settingtitle)
        
        switch settingtitle {
        case "云端分词":
            UserDefaults.standard.set(switch_.isOn, forKey: "CloudSegmentSettingKey")
        case "更大字体":
            UserDefaults.standard.set(switch_.isOn ? 20.0 : 16.0, forKey: "SegmentFontSizeSettingKey")
        case "更多拷贝历史":
            UserDefaults.standard.set(switch_.isOn ? 20 : 10, forKey: "PasteHistorySizeSettingKey")
            view.makeToast("拷贝最多记录\(switch_.isOn ? 20 : 10)条", duration: 0.8, position: CSToastPositionCenter)
        default: break
        }
        UserDefaults.standard.synchronize()
    }
}
