//
//  InsideTableViewCell.swift
//  HackBeanpot
//
//  Created by J. Lozano on 2/9/19.
//  Copyright © 2019 John Abreu. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
