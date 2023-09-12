//
//  SavednewsViewController.swift
//  Group7-project
//
//  Created by Jeffrey Wong on 11/11/2019.
//  Copyright © 2019 ee4304-gp7-project. All rights reserved.
//

import UIKit

import Firebase
import FirebaseAuth




class SavednewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var uid = ""
    var ref: DatabaseReference = Database.database().reference()
    var savednews : [news] = []
    @IBOutlet weak var SavednewsTableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savednews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = SavednewsTableView.dequeueReusableCell(withIdentifier: "SavednewsCell", for: indexPath) as? SavednewsTableViewCell else { return UITableViewCell() }
            var titles = String()
            var sources = String()
            
            if savednews.count > 0 {
                titles = savednews[indexPath.row].title
            } else {
                 titles = ""
            }
            
            if savednews.count > 0 {
                sources = savednews[indexPath.row].source
            } else {
                sources = ""
            }
        
            if savednews.count > 0 {
                cell.newsImage.sd_setImage(with: URL(string: savednews[indexPath.row].imageurl)) { (image, error, cache, urls) in
                    if (error != nil) {
                        cell.newsImage.image = UIImage(named: "invest")
                    } else {
                        cell.newsImage.image = image
                    }
                }
                
            } else {
                cell.newsImage.image = UIImage(named: "invest")!
            }
            
            
            cell.newsImage.layer.cornerRadius = 10
            
            cell.configureCell(newsTitle: titles, newsSource: sources)
            
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urls = savednews[indexPath.row].savenews
        
        UIApplication.shared.open( URL(string: urls)!, options: [:] ) { (success) in
                if success {
                    print("open link")
            }
        }
    }
    func getData() {
        
         Database.database().reference(withPath: "ID/\(self.uid)").observe(.value, with: { (snapshot) in
                 
                    self.ref =  Database.database().reference(withPath: "ID/\(self.uid)/news")
                    self.ref.observe(.value, with: { (snapshot) in
                        self.savednews = []
                       // print(snapshot)
                        for item in snapshot.children {
                            let tempnews = news(snapshot: item as! DataSnapshot)
                            self.savednews.append(tempnews)
                        }
                         //print(self.savednews)
                    })
           
      
        }
        
    )}

    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser{
                  uid = user.uid }
        // Do any additional setup after loading the view.
         getData()
    }
    override func viewDidAppear(_ animated: Bool) {
       
        SavednewsTableView.reloadData()
        print(savednews)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let news = savednews[indexPath.row]
            let delnew = String(savednews[indexPath.row].title.letters)
            savednews.remove(at: indexPath.row)
            Database.database().reference(withPath: "ID/\(self.uid)/news/\(delnew)").removeValue()

        tableView.reloadData()
        }}
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }


}
