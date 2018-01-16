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
    
    lazy var tbView: UITableView = {
        let tmptbView = UITableView.init(frame: CGRect.zero, style: .plain)
        tmptbView.delegate = self; tmptbView.dataSource = self
        tmptbView.separatorInset = UIEdgeInsets.zero
        tmptbView.separatorColor = UIColor.lightGray
        tmptbView.tableFooterView = UIView()
        tmptbView.rowHeight = 50
        tmptbView.register(SwitchCell.self, forCellReuseIdentifier: NSStringFromClass(SwitchCell.self))
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SwitchCell.self), for: indexPath) as! SwitchCell
        cell.titlelabel.text = "云端分词"
        cell.switch_.isOn = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}
