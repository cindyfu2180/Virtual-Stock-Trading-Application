import UIKit

class StockTableCell: UITableViewCell {
    
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var dChange: UILabel!
    @IBOutlet weak var percentCh: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
