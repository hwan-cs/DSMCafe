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
    
    var orderInfoListener: ListenerRegistration?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "OrdersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OrdersCollectionVC")
        
        self.db.collection("orders").document("list").addSnapshotListener(
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
                var foobar = [String: [String:Int]]()
                if self.orders.count > 0
                {
                    let order = data as! [String:[String:Int]]
                    for i in order
                    {
                        if self.orders.contains(where: { key, value in
                            key == i.key
                        })
                        {
                            continue
                        }
                        else
                        {
                            foobar[i.key] = i.value
                        }
                    }
                }
                self.orders = data as! [String:[String:Int]]
                self.collectionView.reloadData()
                self.collectionView.performBatchUpdates(nil)
                { result in
                    var textToSay = ""
                    for i in foobar
                    {
                        textToSay += "주문번호 \(i.key)"
                        for j in i.value
                        {
                            if j.key == "price"
                            {
                                continue
                            }
                            textToSay += "\(j.key) \(j.value)개, "
                        }
                    }
                    TTSManager.shared.play(textToSay)
                }
            }
        })
        
        self.db.collection("orders").document("orderInfo").addSnapshotListener(
        { documentSnapshot, error in
            guard let document = documentSnapshot
            else
            {
                print("Error fetching document: \(error!)")
                return
            }
            Task.init
            {
                guard let data = document.data()
                else
                {
                    print("Document data was empty.")
                            return
                }
                K.completedOrders = data["completedOrders"] as! [String]
                for i in K.completedOrders
                {
                    let orderNum = Int(i.components(separatedBy: "#")[1])
                    if self.collectionView.dequeueReusableCell(withReuseIdentifier: "OrdersCollectionVC", for: IndexPath(row: self.orders.count - orderNum! - 2, section: 0)) is OrdersCollectionViewCell
                    {
                        self.collectionView.reloadItems(at: [IndexPath(row: self.orders.count - orderNum! - 2, section: 0)])
                    }
                }
            }
        })
    }
}

extension AdminViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let height = view.frame.size.height
        let width = view.frame.size.width
        // in case you you want the cell to be 40% of your controllers view
        return CGSize(width: width * 0.2, height: height * 0.4)
    }
}

extension AdminViewController: UICollectionViewDelegate
{
    
}

extension AdminViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrdersCollectionVC", for: indexPath) as! OrdersCollectionViewCell
        let num = String(self.orders.count - indexPath.row - 1).formatToOrderNum()
        cell.orderNum.text = "#\(num)"
        var txt = ""
        let key = Array(self.orders[num]!.keys)
        let val = Array(self.orders[num]!.values)
        for i in 0..<key.count
        {
            if key[i] == "price"
            {
                cell.price = val[i]
                continue
            }
            let k = key[i] as! String
            txt += "\(k.components(separatedBy: "\n")[1])\t- \(val[i])\n"
        }
        cell.orderDetail.text = txt
        
        cell.backgroundColor = .gray
        cell.contentView.backgroundColor = K.completedOrders.contains("#\(num)") ? .systemMint : UIColor(red: 0.92, green: 0.35, blue: 0.401, alpha: 1.00)
        cell.orderCompleteButton.tintColor = K.completedOrders.contains("#\(num)") ? .lightGray : .tintColor
        cell.orderCompleteButton.isUserInteractionEnabled = !K.completedOrders.contains("#\(num)")
        cell.orderCompleteButton.setTitle(K.completedOrders.contains("#\(num)") ? "완료된 주문입니다" : "완료", for: .normal)
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
