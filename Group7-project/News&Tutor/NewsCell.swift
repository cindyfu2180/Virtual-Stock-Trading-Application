//
//  NewsCell.swift
//  News-App
//
//  

import UIKit

protocol NewsTableViewCellDelegate: class {
    func customCellDidPressSavedButton(_ yourTableCell: NewsCell)
}

class NewsCell: UITableViewCell {

    
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsSource: UILabel!
    
    func configureCell( newsTitle: String, newsSource: String) {
    //    self.newsImage.image = newsImage
        self.newsTitle.text = newsTitle
        self.newsSource.text = newsSource
    }
    
    weak var delegate: NewsTableViewCellDelegate?

    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.customCellDidPressSavedButton(self)
    }
    
    
    
}
