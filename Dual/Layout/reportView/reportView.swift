//
//  reportView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

class reportView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Cpview: UIView!
    
    let mainList = ["It's spam", "Nudity or sexual activity", "Hate speech or symbols", "Violence or dangerous behaviors", "Bullying or harrasment", "Intellectual property violation","Sale of illegal or regulated stuffs", "Scam or fraud", "False information"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        self.tableView.register(UINib(nibName: "reportCell", bundle: nil), forCellReuseIdentifier: "reportCell")
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mainList.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = mainList[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell") as? reportCell {
            
            
            
            cell.cellConfigured(report: item)
            return cell
            
            
        } else {
            
            return UITableViewCell()
            
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let item = mainList[indexPath.row]
        print(item)
        
        
        self.tableView.isHidden = true
        self.Cpview.isHidden = false
        
       // self.dismiss(animated: true, completion: nil)
        
        
        
    }

    

}
