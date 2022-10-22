//
//  AdminViewController.swift
//  DSMCafe
//
//  Created by Jung Hwan Park on 2022/10/23.
//

import Foundation
import UIKit
import FirebaseFirestore


class AdminViewController: UIViewController
{
    @IBOutlet var collectionView: UICollectionView!
    
    var orders : [String: [String:Int]] = [:]
    
    var listener: ListenerRegistration?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "OrdersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OrdersCollectionVC")
        listener = self.db.collection("users").document("list").addSnapshotListener(
        { documentSnapshot, error in
            guard documentSnapshot != nil
            else
            {
                print("Error fetching document: \(error!)")
                return
            }
            Task.init
            {
                let data = try await self.db.collection("orders").document("list").getDocument().data()
                self.orders = data as! [String:[String:Int]]
                self.collectionView.reloadData()
            }
        })
    }
}

extension AdminViewController: UICollectionViewDelegate
{
    
}

extension AdminViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrdersCollectionVC", for: indexPath) as! OrdersCollectionViewCell
        
        let num = String(indexPath.row).formatToOrderNum()
        cell.orderNum.text = "#\(num)"
        var txt = ""
        let key = Array(self.orders[num]!.keys)
        let val = Array(self.orders[num]!.values)
        for i in 0..<key.count
        {
            if key[i] == "price"
            {
                continue
            }
            txt += "\(key[i])\t\(val[i])\n"
        }
        cell.orderDetail.text = txt
        
        cell.backgroundColor = .gray
        cell.contentView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.86, alpha: 1.00)
        cell.layer.cornerRadius = 8.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return orders.count
    }
}
