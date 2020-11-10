//
//  SettingCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/2/20.
//

import UIKit

class SettingCell: UITableViewCell {

    @IBOutlet var icon: UIImageView!
    @IBOutlet var name: UILabel!
    
    var info: String!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureCell(_ Information: String) {
        
        self.info = Information
        name.text = self.info
        
        if self.info == "Edit profile" {
            
            icon.image = UIImage(named: "SelectedOnlyMe")
            
        } else {
            
            icon.image = UIImage(named: "\(Information)")
            
        }

        
    }
 

}
