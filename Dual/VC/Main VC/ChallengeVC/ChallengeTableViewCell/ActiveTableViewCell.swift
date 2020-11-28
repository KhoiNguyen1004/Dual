//
//  ActiveTableViewCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/21/20.
//

import UIKit

class ActiveTableViewCell: UITableViewCell {
    
    @IBOutlet var avatarImg: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var messages: UILabel!
    
    var info: ChallengeModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
          super.layoutSubviews()
          //set the values for top,left,bottom,right margins
          let margins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
          contentView.frame = contentView.frame.inset(by: margins)
          contentView.layer.cornerRadius = 25
        
    }
    
    
    func configureCell(_ Information: ChallengeModel) {
        
        self.info = Information
        
        loadInfo(uid: self.info.sender_ID)
        self.info.started_timeStamp.dateValue()
        let date = self.info.started_timeStamp.dateValue()
        messages.text = "Actives \(timeAgoSinceDate(date, numericDates: true))"

        
    }
    
    func loadInfo(uid: String) {
        
        DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: uid).getDocuments { [self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
            
                if snapshot.isEmpty == true {
                    
                    username.text = "Undefined"
                    return
                }
                
                for item in snapshot.documents {
                
                    if let usern = item.data()["username"] as? String {
                        
                        //
                        
                        username.text = "@\(usern)"
                        
                        if let avatarUrl = item["avatarUrl"] as? String {
                            
                            let imageNode = ASNetworkImageNode()
                            imageNode.contentMode = .scaleAspectFit
                            imageNode.shouldRenderProgressImages = true
                            imageNode.url = URL.init(string: avatarUrl)
                            imageNode.frame = avatarImg.layer.bounds
                            avatarImg.image = nil
                            
                            
                            avatarImg.addSubnode(imageNode)
                            
                        }
                        
   
                    }
            }
            
        }
        
    }

}
