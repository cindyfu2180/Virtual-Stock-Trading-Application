//
//  ViewController.swift
//
//
//  Created by Cindy Fu on 8/11/2019.
//  Copyright © 2019 CityUEE. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

struct data_struct{
    var name:String = ""
    var data:String = ""
    var changes:String = ""
    var nation:String = ""
    var green:Bool = true
}

class IndexViewController: UIViewController {
    @IBOutlet weak var tableViewCell: UITableView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet var searchBar: UISearchBar!
    
    var timer : Timer?
    var arrayList:[data_struct] = Array()
    var currentList:[data_struct] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load_data()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //_ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(load_data), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}


extension IndexViewController{
    @objc func load_data() {
        Alamofire.request("https://www.investing.com/indices/major-indices").responseString { response in
            if let html = response.result.value{
                self.parsehtml(html)
            }
        }
    }
    
    @objc func parsehtml(_ html1:String)  {
        //var positive = 1
        var gg:NSString = " "
        let doc = try? Kanna.HTML(html: html1, encoding: String.Encoding.utf8)
        var s = data_struct()
        for i in 1...47{
            for j in 1...7{
                for rate in doc!.xpath("//*[@id='cross_rates_container']/table/tbody/tr[\(i)]/td[\(j)]") {

                    if (j == 1) {
                        for nationPath in doc!.xpath("//*[@id='cross_rates_container']/table/tbody/tr[\(i)]/td[1]/span/@title") {
                            gg = nationPath.text! as NSString
                            s.nation = gg as String
                        }
                    }
 
                    if (j == 2) { //name
                        gg = rate.text! as NSString
                        s.name = gg as String
                    }
                    if (j == 3) { //data
                        gg = rate.text! as NSString
                        s.data = gg as String
                    }
                    if (j == 7) { //changes
                        gg = rate.text! as NSString
                        s.changes = gg as String
                        if (s.changes.prefix(1) == "-") {
                            s.green = false
                        }
                        else {
                            s.green = true
                        }
                    }
                }
            }
            arrayList.append(s)
            currentList = arrayList
        }
        tableViewCell.reloadData()
    }
}

extension IndexViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  currentList.count > 0 {
            return currentList.count
        }
        else {
               return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IndextableViewCell", for: indexPath) as! IndexTableViewCell
        
        let tdydate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd - MM - yyyy"
        date.text = formatter.string(from: tdydate)
        
        cell.cellName.text = currentList[indexPath.row].name
        cell.cellData.text = currentList[indexPath.row].data
        cell.cellNation.text = currentList[indexPath.row].nation
        
        cell.cellChanges.text = currentList[indexPath.row].changes
        cell.cellChanges.layer.cornerRadius = 10.0
        cell.cellChanges.clipsToBounds = true
        
        if (currentList[indexPath.row].green) {
            cell.cellChanges.backgroundColor = UIColor.systemGreen
        }
        else {
             cell.cellChanges.backgroundColor = UIColor.red
        }
        
        return cell
    
    }
    func alterLayout() {
        tableViewCell.tableHeaderView = UIView()
        tableViewCell.estimatedSectionHeaderHeight = 50
        navigationItem.titleView = searchBar
        searchBar.showsScopeBar = false
        searchBar.placeholder = "Search Index by Name"
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            currentList = arrayList
            tableViewCell.reloadData()
            return
        }
        currentList = arrayList.filter({ data_struct -> Bool in
            data_struct.name.lowercased().contains(searchText.lowercased())
        })
        tableViewCell.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

