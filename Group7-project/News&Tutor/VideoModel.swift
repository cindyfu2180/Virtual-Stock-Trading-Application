//
//  VideoModel.swift
//  News-App
//
//  Created by tc_san on 8/11/2019.
//  Copyright © 2019 Johnny Perdomo. All rights reserved.
//

import UIKit
import Alamofire

protocol VideoModelDelegate{
    func dataReady()
}

class VideoModel: NSObject {
    
    let API_KEY = "AIzaSyBS2nJBYFXjJYI-84yBgsgRWuvbL0252B4"
    let PLAYLIST_ID = "PLsJrbQrdqmnzgPyboulJK9HQWxHHj-GdT"
    var delegate:VideoModelDelegate?
    var arrayOfvideo = [Video]()
    
   
    func getFeedVideo() {
        Alamofire.request("https://www.googleapis.com/youtube/v3/playlistItems", parameters: ["part":"snippet","playlistId":PLAYLIST_ID,"key":API_KEY,"maxResults":"9"], encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            var videoArray = [Video]()
            if let JSON = response.result.value{
            if let dictionary = JSON as?[String: Any]{
            for video in dictionary["items"] as! NSArray{
                    print(video)
                                   
            let videoObj = Video()
            videoObj.videoId = (video as AnyObject).value(forKeyPath: "snippet.resourceId.videoId") as! String
            videoObj.videoTitle = (video as AnyObject).value(forKeyPath: "snippet.title") as! String
            videoObj.videoDescription = (video as AnyObject).value(forKeyPath: "snippet.description") as! String
            videoObj.videoThumbnailUrl = (video as AnyObject).value(forKeyPath: "snippet.thumbnails.maxres.url") as! String
                   
                videoArray.append(videoObj)
                                      
              }
            }
                self.arrayOfvideo = videoArray
                
                if self.delegate != nil {
                    self.delegate!.dataReady()
                }
          }
             
        }
    }

}
