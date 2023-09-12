//
//  ViewController.swift
//  News-App
//
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import Firebase
import FirebaseAuth

extension String {
    var letters: String {
        return String(unicodeScalars.filter(CharacterSet.letters.contains))
    }
}


class NewsVC: UIViewController {

    @IBOutlet weak var newsTableView: UITableView!

    @IBOutlet weak var pageView: UIPageControl!
    
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    
    var uid = ""
    var ref: DatabaseReference = Database.database().reference()

    var titleArray = [String]()
    var newsSourceArray = [String]()
    var imageURLArray = [String]()
    var newsStoryUrlArray = [String]()
    
    var timer = Timer()
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTableView.delegate = self
        newsTableView.dataSource = self
        if let user = Auth.auth().currentUser{
            uid = user.uid
        }
        
        self.newsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getNewsData { (success) in
            if success {
                print("success")
                self.pageView.currentPage = 0
                DispatchQueue.main.async {
                    self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
                }
                
           //     self.imageURLArray = self.imageURLArray.filter { $0 != ""} //filter array to remove nil values
                self.newsTableView.reloadData()
                print(self.imageURLArray.count)
                
                
                
            } else {
                print("doesnt work ")
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func changeImage() {
       
       if counter < 10 {
           let index = IndexPath.init(item: counter, section: 0)
           self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
           pageView.currentPage = counter
           counter += 1
       } else {
           counter = 0
           let index = IndexPath.init(item: counter, section: 0)
           self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
           pageView.currentPage = counter
           counter = 1
       }
           
       }
        
}

    


extension NewsVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       return imageURLArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = newsTableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as? NewsCell else { return UITableViewCell() }
        cell.delegate = (self as! NewsTableViewCellDelegate)
        var titles = String()
        var sources = String()
        
        if titleArray.count > 0 {
             titles = titleArray[indexPath.row ]
        } else {
             titles = ""
        }
        
        if newsSourceArray.count > 0 {
            sources = newsSourceArray[indexPath.row]
        } else {
            sources = ""
        }
    
        if imageURLArray.count > 0 {
            
            cell.newsImage.sd_setImage(with: URL(string: imageURLArray[indexPath.row])) { (image, error, cache, urls) in
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
        
        let indexPath = tableView.indexPathForSelectedRow
        
        let urls = newsStoryUrlArray[(indexPath?.row)!]
    
        UIApplication.shared.open( URL(string: urls)!, options: [:] ) { (success) in
            if success {
                print("open link")
            }
        }
        
        
    }
    
}

extension NewsVC {
    
    func getNewsData(complete: @escaping (_ status: Bool) -> ()) {
        
        Alamofire.request("https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=8ba56fda65f74de5ba96fee477e1e535", method: .get).responseJSON { (response) in
            
            guard let value = response.result.value else { return }
            
                let json = JSON(value)
                
                for item in json["articles"].arrayValue {
                    
                
                    self.titleArray.append(item["title"].stringValue)
                self.newsSourceArray.append(item["source"]["name"].stringValue)
                    self.imageURLArray.append(item["urlToImage"].stringValue)
                    self.newsStoryUrlArray.append(item["url"].stringValue)
                
                }
            complete(true)
        
        }
    
    }
    
    
}
extension NewsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = sliderCollectionView.dequeueReusableCell(withReuseIdentifier: "sliderCell", for: indexPath)
        if let slideview = cell.viewWithTag(111) as? UIImageView {
            if imageURLArray.count > 0 {
            slideview.sd_setImage(with: URL(string: imageURLArray[indexPath.row])) { (image, error, cache, urls) in
                           if (error != nil) {
                            slideview.image = UIImage(named: "invest")
                        
                           } else {
                            slideview.image = image
                           }
                       }

            }else {
                slideview.image = UIImage(named: "invest")!
            }
            slideview.layer.cornerRadius = 10
        }
        
        
       return cell
    }
}
    



extension NewsVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sliderCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
//
//
//
extension NewsVC: NewsTableViewCellDelegate {
    
    func customCellDidPressSavedButton(_ yourTableCell: NewsCell) {
        guard let indexPath = newsTableView.indexPath(for: yourTableCell) else { return }
        print("Link button pressed at \(indexPath)")
        print(titleArray[indexPath.row])
        print(newsSourceArray[indexPath.row])
        print(imageURLArray[indexPath.row])
        print(newsStoryUrlArray[indexPath.row])
        let temptitle = titleArray[indexPath.row].letters
        
        let savednew = news(title: titleArray[indexPath.row], source: newsSourceArray[indexPath.row], imageurl: imageURLArray[indexPath.row], savenews: newsStoryUrlArray[indexPath.row])
        let newsItemRef = self.ref.child("ID").child(self.uid).child("news").child(temptitle)
                           newsItemRef.setValue(savednew.toAnyObject(), withCompletionBlock: { (error, ref) in
                           if error == nil {
                               let alertController = UIAlertController(title: "Success", message: "Saved Successfully", preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                alertController.addAction(defaultAction)
                                self.present(alertController, animated: true, completion: nil)
                             }
})
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        let savenews = Savednews(context: context)
//        savenews.title = titleArray[indexPath.row]
//        savenews.source = newsSourceArray[indexPath.row]
//        savenews.imageurl = imageURLArray[indexPath.row]
//        savenews.linkurl = newsStoryUrlArray[indexPath.row]
        
//        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
//        let alert = UIAlertController(title: "You save a news", message: "Your saved news can be view in Account -> Setting -> Saved News", preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: {
//            (action: UIAlertAction!) in
//            print("Saved news complete")
//        }))
//        present(alert, animated: true, completion: nil)
        
    }
}

    





