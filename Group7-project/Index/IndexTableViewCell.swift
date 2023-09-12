//
//  TableViewCell.swift
//
//
//  Created by Cindy Fu on 8/11/2019.
//  Copyright © 2019 CityUEE. All rights reserved.
//

import UIKit

class IndexTableViewCell: UITableViewCell {

    @IBOutlet weak var cellName: UILabel!
    @IBOutlet weak var cellData: UILabel!
    @IBOutlet weak var cellChanges: UILabel!
    @IBOutlet weak var cellNation: UILabel!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
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
