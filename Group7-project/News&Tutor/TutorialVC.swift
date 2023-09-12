//
//  TutorialVC.swift
//  News-App
//
//  Created by tc_san on 8/11/2019.
//  Copyright © 2019 Johnny Perdomo. All rights reserved.
//

import UIKit

class TutorialVC: UIViewController, UITableViewDelegate, UITableViewDataSource ,VideoModelDelegate {
    
    
   

    @IBOutlet weak var tutorialView: UITableView!
    
    var videos:[Video] = [Video]()
    var selectedvideo:Video?
    let model:VideoModel = VideoModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.model.delegate = self
        
        model.getFeedVideo()
        
        self.tutorialView.dataSource = self
        self.tutorialView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        self.didReceiveMemoryWarning()
    }
    func dataReady() {
        self.videos = self.model.arrayOfvideo
        print(videos)
        self.tutorialView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.view.frame.size.width / 320) * 180
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videos.count
       }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let videoTitle = videos[indexPath.row].videoTitle
        
        
        let label = cell!.viewWithTag(2) as! UILabel
        label.text = videoTitle
        
        let videoUrlString = videos[indexPath.row].videoThumbnailUrl
        
        
        guard let imageURL = URL(string: videoUrlString) else { return cell! }

               // just not to cause a deadlock in UI!
           DispatchQueue.global().async {
               guard let imageData = try? Data(contentsOf: imageURL) else { return }

               let image = UIImage(data: imageData)
               
               DispatchQueue.main.async {
                 let imageview = cell!.viewWithTag(1) as! UIImageView
                
                   imageview.image = image
               }
           } 
//
        return cell!
       }
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedvideo =  self.videos[indexPath.row]
        
        self.performSegue(withIdentifier: "goToDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let detailViewController = segue.destination as! VideoVC
        
        detailViewController.selectedvideo = self.selectedvideo
    }

}
