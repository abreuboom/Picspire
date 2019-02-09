//
//  InsideTableViewCell.swift
//  HackBeanpot
//
//  Created by J. Lozano on 2/9/19.
//  Copyright © 2019 John Abreu. All rights reserved.
//

import UIKit
import Hero

class MainTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var photos:[(String, String)] = []
    var relevantTag:String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure (relevantTag: String, photos: [(String, String)]) {
        self.hero.isEnabled = true
        
        self.relevantTag = relevantTag
        self.photos = photos
        self.tagLabel.text = "#\(relevantTag.capitalized)"
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.alwaysBounceHorizontal = true
        self.collectionView.hero.modifiers = [.cascade]
        
        self.collectionView.reloadData()
        
        self.layoutIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 256, height: 256)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(integerLiteral: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.imageView.layer.cornerRadius = 25.0
        cell.imageView.layer.masksToBounds = true;
        cell.imageView.clipsToBounds = true;
        cell.imageView.layer.borderWidth = 1.0
        cell.imageView.layer.borderColor = UIColor.clear.cgColor
        
        cell.imageView.layer.shadowColor = UIColor.lightGray.cgColor
        cell.imageView.layer.shadowOffset = CGSize(width:0, height: 1.0)
        cell.imageView.layer.shadowRadius = 1.0
        cell.imageView.layer.shadowOpacity = 0.5
        cell.imageView.layer.masksToBounds = true;
        cell.imageView.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        
        cell.hero.modifiers = [.fade, .scale(0.5)]
        
        // Filling in data
        let url = photos[indexPath.row].0
        let caption = photos[indexPath.row].1
        print("saddos: \(url), \(caption)")
        cell.configure(with: url, caption: caption)
        
        
        return cell
    }

}
extension MainTableViewCell
{
    func setCollectionViewDataSourceDelegate <D: UICollectionViewDelegate & UICollectionViewDataSource> (_ dataSourceDelegate: D, forRow row:Int){
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        
        collectionView.reloadData()
    }
}
