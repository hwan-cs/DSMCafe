//
//  OrdersCollectionViewCell.swift
//  DSMCafe
//
//  Created by Jung Hwan Park on 2022/10/23.
//

import UIKit

class OrdersCollectionViewCell: UICollectionViewCell
{
    @IBOutlet var orderNum: UILabel!
    
    @IBOutlet var orderDetail: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func didTapComplete(_ sender: UIButton)
    {
        
    }
}
