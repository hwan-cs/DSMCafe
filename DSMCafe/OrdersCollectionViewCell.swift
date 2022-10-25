//
//  OrdersCollectionViewCell.swift
//  DSMCafe
//
//  Created by Jung Hwan Park on 2022/10/23.
//

import FirebaseFirestore
import UIKit

class OrdersCollectionViewCell: UICollectionViewCell
{
    @IBOutlet var orderNum: UILabel!
    
    @IBOutlet var orderDetail: UILabel!
    
    @IBOutlet var orderCompleteButton: UIButton!
    
    var price: Int?
    
    let db = Firestore.firestore()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.orderCompleteButton.titleLabel?.numberOfLines = 0
    }
    
    @IBAction func didTapComplete(_ sender: UIButton)
    {
        Task.init
        {
            if var arr = try await self.db.collection("orders").document("orderInfo").getDocument().data()?["completedOrders"] as? [String]
            {
                arr.append(orderNum.text!)
                try await self.db.collection("orders").document("orderInfo").updateData(["completedOrders" : arr])
            }
            if var total = try await self.db.collection("orders").document("orderInfo").getDocument().data()?["total"] as? Int
            {
                total += self.price!
                try await self.db.collection("orders").document("orderInfo").updateData(["total" : total])
            }
        }
    }
}
