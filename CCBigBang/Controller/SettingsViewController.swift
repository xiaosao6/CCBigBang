//
//  SettingsViewController.swift
//  CCBigBang
//
//  Created by sischen on 2018/1/15.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

import UIKit

/// 设置界面
class SettingsViewController: UIViewController {
    
    let dataSource = [["云端分词": UserDefaults.standard.bool(forKey: "CloudSegmentSettingKey")],
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
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SwitchCell.self), for: indexPath) as! SwitchCell
        if indexPath.row < dataSource.count-1 {
            cell.titlelabel.text = dataSource[indexPath.row].keys.first
            cell.switch_.isOn = dataSource[indexPath.row].values.first as! Bool
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.colorPickerReuseId, for: indexPath) as! SwitchCell
            cell.titlelabel.text = dataSource[indexPath.row].keys.first
            cell.colorDisplayView.backgroundColor = UIColor.colorOfRGB(hex: dataSource[indexPath.row].values.first as! String)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}
