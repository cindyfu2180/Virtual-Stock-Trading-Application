//
//  SavednewsTableViewCell.swift
//  Group7-project
//
//  Created by Jeffrey Wong on 11/11/2019.
//  Copyright © 2019 ee4304-gp7-project. All rights reserved.
//

import UIKit

class SavednewsTableViewCell: UITableViewCell {
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
    func configureCell( newsTitle: String, newsSource: String) {
        self.title.text = newsTitle
        self.source.text = newsSource
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
