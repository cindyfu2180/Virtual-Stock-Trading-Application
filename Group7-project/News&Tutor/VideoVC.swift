//
//  VideoVC.swift
//  News-App
//
//  Created by tc_san on 9/11/2019.
//  Copyright © 2019 Johnny Perdomo. All rights reserved.
//

import UIKit

class VideoVC: UIViewController {

 
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var Descriptionlabel: UILabel!
    @IBOutlet weak var titlelabel: UILabel!
    
    var selectedvideo:Video?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let vid = self.selectedvideo {
            
            self.titlelabel.text = vid.videoTitle
            self.Descriptionlabel.text = vid.videoDescription
            
            let width = Int(self.view.frame.size.width)
            let height = width/320*220
            
            
            let videoEmbedString = "<html><head><style type=\"text/css\">body {background-color: transparent;color: white;}</style></head><body style=\"margin:0\"><iframe frameBorder=\"0\" height=\"" + String(height) + "\" width=\"" + String(width) + "\" src=\"http://www.youtube.com/embed/" + vid.videoId + "?showinfo=0&modestbranding=1&frameborder=0&rel=0\"></iframe></body></html>"
            
            self.webview.loadHTMLString(videoEmbedString, baseURL: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
