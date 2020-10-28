//
//  FeedVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/20/20.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Firebase

class FeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    struct State {
       var itemCount: Int
       var fetchingMore: Bool
       static let empty = State(itemCount: 20, fetchingMore: false)
    }
    
    enum Action {
        case beginBatchFetch
        case endBatchFetch(resultCount: Int)
    }
    
    fileprivate(set) var state: State = .empty

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bView: UIView!
    
  
    var firstLoad = true
    var previousIndex = 0
    var itemList = [CategoryModel]()
    var tableNode: ASTableNode!
    var posts = [HighlightsModel]()
    var lastDocumentSnapshot: DocumentSnapshot!
    var query: Query!
    
    private var pullControl = UIRefreshControl()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
       
        bView.addSubview(tableNode.view)
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 1
        
        
        loadAddGame()
        
        pullControl.tintColor = UIColor.systemOrange
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableNode.view.refreshControl = pullControl
        } else {
            tableNode.view.addSubview(pullControl)
        }
        
    }
    
   
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        should_Play = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        should_Play = true
    }
  
   
    
    @objc private func refreshListData(_ sender: Any) {
       // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        self.posts.removeAll()
        lastDocumentSnapshot = nil
        self.tableNode.reloadData()
        
        
        
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        self.tableNode.frame = bView.bounds
        
    }
    
    
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.isPagingEnabled = true
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
        
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return itemList.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = itemList[indexPath.row]

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCategoryCell", for: indexPath) as? FeedCategoryCell {
            
            
            let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
            
            if item.isSelected == true {
                
                cell.shadowView.isHidden = true
                cell.backView.backgroundColor = selectedColor
                cell.layer.cornerRadius = 15
                
                if item.name == "For you" {
                    cell.Fylbl.textColor = UIColor.white
                }
                
            } else {
                
                cell.shadowView.isHidden = false
                cell.backView.backgroundColor = UIColor.white
                cell.layer.cornerRadius = 17
                
                if item.name == "For you" {
                    cell.Fylbl.textColor = UIColor.black
                }
                
            }
                  
            cell.configureCell(item)
         
            return cell
            
        } else {
            
            return FeedCategoryCell()
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if previousIndex != indexPath.row {
            
            self.itemList[indexPath.row]._isSelected = true
            self.itemList[previousIndex]._isSelected = false
            
            previousIndex = indexPath.row
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            
        }
  
    }
    
    func loadAddGame() {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Support_game").order(by: "name", descending: true)
            .addSnapshotListener { [self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if firstLoad == true {
                    
                    for item in snapshot.documents {
                        
                        if item.data()["status"] as! Bool == true {
                            
                            var i = item.data()
                            i.updateValue(false, forKey: "isSelected")
                            let item = CategoryModel(postKey: item.documentID, Game_model: i)
                            
                            if i["name"] as? String != "Others" {
                             
                                self.itemList.insert(item, at: 0)
                                
                            } else {
                                
                                self.itemList.append(item)
                                                  
                            }
                            
                        }
                        
                    }
                    
                    firstLoad =  false
        
                    let updateData: [String: Any] = ["name": "For you", "url": "", "url2": "", "status": true, "isSelected": true]
                    let item = CategoryModel(postKey: "For you", Game_model: updateData)
                    self.itemList.insert(item, at: 0)
                    self.collectionView.reloadData()
                    
    
                }
                
                snapshot.documentChanges.forEach { diff in
                    

                    if (diff.type == .modified) {
                        
                        if diff.document["status"] as! Bool == true {
                            
                            let checkItem = CategoryModel(postKey: diff.document.documentID, Game_model: diff.document.data())
                            let isIn = findDataInList(item: checkItem)
                            
                            if isIn == false {
                                
                                var data = diff.document.data()
                                
                                data.updateValue(false, forKey: "isSelected")
                                let item = CategoryModel(postKey: diff.document.documentID, Game_model: data)
                                
                                if diff.document["name"] as? String != "Others" {
                                    
                                    self.itemList.insert(item, at: 1)
                                    
                                } else {
                                    
                                    self.itemList.append(item)
                                        
                                }
                                
                                
                            } else {
                                
                                let item = CategoryModel(postKey: diff.document.documentID, Game_model: diff.document.data())
                                let index = findDataIndex(item: item)
                                
                                let selected = self.itemList[index].isSelected
                                
                                var data = diff.document.data()
                                data.updateValue(selected!, forKey: "isSelected")
                                
                                let Fitem = CategoryModel(postKey: diff.document.documentID, Game_model: data)
                                
                                self.itemList.remove(at: index)
                                self.itemList.insert(Fitem, at: index)
                                
                            
                            }
                            
                            self.collectionView.reloadData()
                            
                            
                        } else {
                            
                            
                            let item = CategoryModel(postKey: diff.document.documentID, Game_model: diff.document.data())
                            
                            let index = findDataIndex(item: item)
                            self.itemList.remove(at: index)
                            
                            
                            // delete processing goes here
                            
                            self.itemList[0]._isSelected = true
                
                            previousIndex = 0
                            self.collectionView.reloadData()
                            
                            
                        }
                        
              
                    } else if (diff.type == .removed) {
                        
                        let item = CategoryModel(postKey: diff.document.documentID, Game_model: diff.document.data())
                        
                        let index = findDataIndex(item: item)
                        self.itemList.remove(at: index)
                        
                        
                        // delete processing goes here
                        
                        self.itemList[0]._isSelected = true
                        previousIndex = 0
                        self.collectionView.reloadData()
                        
                        
                    } else if (diff.type == .added) {
                        
                        
                        if diff.document["status"] as! Bool == true {
                            
                            var data = diff.document.data()
                            data.updateValue(false, forKey: "isSelected")
                            
                            let item = CategoryModel(postKey: diff.document.documentID, Game_model: data)
                          
                            let isIn = findDataInList(item: item)
                            
                            if isIn == false {
                                
                                if diff.document["name"] as? String != "Others" {
                                    
                                    self.itemList.insert(item, at: 1)
                                    
                                } else {
                                    
                                    self.itemList.append(item)
                                    
                                }
 
                                                      
                            }
                            
                            self.collectionView.reloadData()
                            
                            
                        }
                        
                    }
                }
            }
        
    }
    
    func findDataInList(item: CategoryModel) -> Bool {
        
        for i in itemList {
            
            if i.name == item.name {
                
                return true
                
            }
          
        }
        
        return false
        
    }
    
    func findDataIndex(item: CategoryModel) -> Int {
        
        var count = 0
        
        for i in itemList {
            
            if i.name == item.name {
                
                break
                
            }
            
            count += 1
            
        }
        
        return count
        
    }
 
    // layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let item = self.itemList[indexPath.row]
        
        if item.isSelected == true {
            
            return CGSize(width: 120, height: self.collectionView.frame.height)
            
        } else {
            
            return CGSize(width: 70, height: self.collectionView.frame.height)
            
        }
        
    }
    
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("Dismiss")
    }

    // functions
    
    
    func shareVideo(item: HighlightsModel) {
        
        if let id = item.highlight_id, id != "" {
            
            let items: [Any] = ["Check out this highlight", URL(string: "https://www.dual.so/\(id)")!]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                
                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
                
            }
           
           
           present(ac, animated: true, completion: nil)
           NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "pauseVideo")), object: nil)
        
            
        }
        
       
        
    }
    
    func challenge(item: HighlightsModel) {
        
        print("Challenge to user: \(item.userUID) for assets \(item.Mux_assetID)")

    }
    
    func openLink(item: HighlightsModel) {
        
        if let link = item.stream_link, link != ""
        {
            guard let requestUrl = URL(string: link) else {
                return
            }

            if UIApplication.shared.canOpenURL(requestUrl) {
                 UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
            }
            
        } else {
            
            print("Empty link")
            
        }

    }
    
        
}
extension FeedVC: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let width = UIScreen.main.bounds.size.width;
        let min = CGSize(width: width, height: self.bView.layer.frame.height);
        let max = CGSize(width: width, height: self.bView.layer.frame.height);
        
        return ASSizeRangeMake(min, max);
    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        
        return true
        
    }
    
    
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
       
        
        self.retrieveNextPageWithCompletion { (newPosts) in
            
            self.insertNewRowsInTableNode(newPosts: newPosts)
            if self.pullControl.isRefreshing == true {
                self.pullControl.endRefreshing()
            }
      
            context.completeBatchFetching(true)
            
            
        }
 
    }
    
   
}

extension FeedVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    
        return self.posts.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let post = self.posts[indexPath.row]
           
        return {
            let node = PostNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            node.shareBtn = { (node) in
                
                self.shareVideo(item: post)
                  
            }
            
            node.challengeBtn = { (node) in
                
                self.challenge(item: post)
                
            }
            
            
            node.linkBtn = { (node) in
                
                self.openLink(item: post)
                
            }
            
            return node
        }
        
   
            
    }
    

    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        
        guard let cell = node as? PostNode else { return }
        
        if cell.animatedLabel != nil {
            
            cell.animatedLabel.restartLabel()
            
        }
        
        cell.startObserve()
    
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode) {
    
        
        guard let cell = node as? PostNode else { return }
        
        if cell.PlayViews != nil {
            cell.PlayViews.playImg.image = nil
        }
        
        
        cell.removeAllobserve()
        
    }
    

    
}

extension FeedVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([QueryDocumentSnapshot]) -> Void) {
        
        let db = DataService.instance.mainFireStoreRef
        
        // whereField("userUID", isNotEqualTo: "your uid")
        
        if lastDocumentSnapshot == nil {
            
            query = db.collection("Highlights").order(by: "post_time", descending: true).whereField("status", isEqualTo: "Ready").limit(to: 2)
            
            
        } else {
            
            query = db.collection("Highlights").order(by: "post_time", descending: true).whereField("status", isEqualTo: "Ready").limit(to: 2).start(afterDocument: lastDocumentSnapshot)
        }
        
        query.getDocuments { [self] (snap, err) in
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
                
            if snap?.isEmpty != true {
                
                print("Successfully retrieved \(snap!.count) posts.")
                let items = snap?.documents
                self.lastDocumentSnapshot = snap!.documents.last
                DispatchQueue.main.async {
                    block(items!)
                }
                
            } else {
                
                let items = snap?.documents
                DispatchQueue.main.async {
                    block(items!)
                }
              
                
            }
            
            
        }
        
    }
    
    func insertNewRowsInTableNode(newPosts: [QueryDocumentSnapshot]) {
        
        guard newPosts.count > 0 else {
            return
        }
        
        let section = 0
        var items = [HighlightsModel]()
        var indexPaths: [IndexPath] = []
        let total = self.posts.count + newPosts.count
        
        for row in self.posts.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in newPosts {
            
            let item = HighlightsModel(postKey: i.documentID, Highlight_model: i.data())
            items.append(item)
          
        }
        
    
        self.posts.append(contentsOf: items)
        self.tableNode.insertRows(at: indexPaths, with: .none)
        
        
    }
    
    
}
