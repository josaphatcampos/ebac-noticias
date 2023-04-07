//
//  NetworkTableViewCell.swift
//  ebac-noticias
//
//  Created by Josaphat Campos Pereira on 28/03/23.
//

import UIKit

class NetworkTableViewCell: UITableViewCell {
    
    @IBOutlet var celltitlelabel: UILabel!
    @IBOutlet var cellimageview: UIImageView!
    @IBOutlet var bylinelabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellimageview?.layer.borderWidth = 1
        cellimageview?.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
