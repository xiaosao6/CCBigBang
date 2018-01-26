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
    
    fileprivate var historySource = [Dictionary<String, String>]() // key"文本", value:"1月31日"
    
    lazy var _dateFormatter: DateFormatter = {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "M月d日" // "M月d日 HH:mm"
        return formatter
    }()
    
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
        
        if let arr = UserDefaults.standard.array(forKey: pasteHistoryCacheKey) {
            historySource = arr as! Array<[String:String]>
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tmpString = UIPasteboard.general.string ?? ""
        if tmpString.count == 0 { return }
        if historySource.map({ (dict) -> String in
            return dict.keys.first ?? ""
        }).contains(tmpString) { return }
        
        historySource.insert([tmpString: _dateFormatter.string(from: Date())], at: 0)
        if historySource.count > UserDefaults.standard.integer(forKey: "PasteHistorySizeSettingKey") { historySource.removeLast() }
        
        refreshHistoryCache(newStrs: historySource)
        tbView.reloadData()
    }
    
    //MARK: ------------------------ Private
    fileprivate func refreshHistoryCache(newStrs: [[String:String]]?) -> () {
        UserDefaults.standard.set(newStrs, forKey: pasteHistoryCacheKey)
        UserDefaults.standard.synchronize()
    }
    
    @objc private func clearClick() -> () {
        let alt = UIAlertController.init(title: "提示", message: "确定清除拷贝历史？", preferredStyle: .alert)
        alt.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { [weak self] (_) in
            self?.refreshHistoryCache(newStrs: nil)
            self?.historySource.removeAll(); self?.tbView.reloadData()
            self?.viewDeckController?.closeSide(true)
        }))
        alt.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        self.present(alt, animated: true, completion: nil)
    }
}

extension PasteHistoryViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historySource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PasteHistoryCell.self), for: indexPath) as! PasteHistoryCell
        cell.contentLabel.text = historySource[indexPath.row].keys.first
        cell.timeLabel.text = historySource[indexPath.row].values.first
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let centerNavVC:UINavigationController = self.viewDeckController?.centerViewController as? UINavigationController,
           let centerVC:ViewController = centerNavVC.viewControllers.first as? ViewController {
            centerVC.inputTV.text = historySource[indexPath.row].keys.first
            self.viewDeckController?.closeSide(true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction.init(style: .destructive, title: "删除") { (act, indexpath) in
            self.historySource.remove(at: indexpath.row)
            self.refreshHistoryCache(newStrs: self.historySource)
            self.tbView.deleteRows(at: [indexpath], with: .fade)
        }
        return [action]
    }
    
}
