//
//  PasteHistoryViewController.swift
//  CCBigBang
//
//  Created by sischen on 2018/1/2.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

import UIKit

let pasteHistoryCacheKey = "PasteHistoryCacheKey"


/// 剪贴板历史界面
class PasteHistoryViewController: UIViewController {
    
    fileprivate var dataSource = [String]()
    
    lazy var tbView: UITableView = {
        let tmptbView = UITableView.init(frame: CGRect.zero, style: .plain)
        tmptbView.delegate = self; tmptbView.dataSource = self
        tmptbView.separatorInset = UIEdgeInsets.zero
        tmptbView.separatorColor = UIColor.lightGray
        tmptbView.tableFooterView = UIView()
        tmptbView.rowHeight = 50
        tmptbView.register(PasteHistoryCell.self, forCellReuseIdentifier: NSStringFromClass(PasteHistoryCell.self))
        return tmptbView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor.white
        
        let clearBtn = UIButton.init(type: .system)
        clearBtn.setTitle("删除全部", for: .normal)
        clearBtn.addTarget(self, action: #selector(clearClick), for: .touchUpInside)
        self.view.addSubview(clearBtn)
        clearBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-15)
        }
        
        self.view.addSubview(tbView)
        tbView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(50)
            make.bottom.equalTo(clearBtn.snp.top).offset(-15)
        }
        
        if let arr = UserDefaults.standard.array(forKey: pasteHistoryCacheKey) { dataSource = arr as! Array<String> }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tmpString = UIPasteboard.general.string ?? ""
        if dataSource.contains(tmpString) { return }
        dataSource.insert(tmpString, at: 0)
        refreshHistoryCache(newStrs: dataSource)
        tbView.reloadData()
    }
    
    //MARK: ------------------------ Private
    fileprivate func refreshHistoryCache(newStrs: [String]?) -> () {
        UserDefaults.standard.set(newStrs, forKey: pasteHistoryCacheKey)
        UserDefaults.standard.synchronize()
    }
    
    @objc private func clearClick() -> () {
        refreshHistoryCache(newStrs: nil)
        dataSource.removeAll()
        tbView.reloadData()
    }
}

extension PasteHistoryViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PasteHistoryCell.self), for: indexPath) as! PasteHistoryCell
        cell.contentLabel.text = dataSource[indexPath.row]
        cell.timeLabel.text = "1月2日 22:19"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction.init(style: .destructive, title: "删除") { (act, indexpath) in
            self.dataSource.remove(at: indexpath.row)
            self.refreshHistoryCache(newStrs: self.dataSource)
            self.tbView.deleteRows(at: [indexpath], with: .fade)
        }
        return [action]
    }
    
}
