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
    
    var orders : [String: [String:AnyHashable]] = [:]
    
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
                var foobar = [String: [String:AnyHashable]]()
                if self.orders.count > 0
                {
                    let order = data as! [String:[String:AnyHashable]]
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
                if self.orders != data as! [String: [String:AnyHashable]]
                {
                    self.orders = data as! [String: [String: AnyHashable]]
                }
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
                if let d = data["completedOrders"] as? [String]
                {
                    if d != K.completedOrders
                    {
                        K.completedOrders = d
                    }
                }
                for i in K.completedOrders
                {
                    let foobar = i.components(separatedBy: " - ")[0]
                    let orderNum = Int(foobar.components(separatedBy: "#")[1])
                    if self.collectionView.dequeueReusableCell(withReuseIdentifier: "OrdersCollectionVC", for: IndexPath(row: self.orders.count - orderNum!, section: 0)) is OrdersCollectionViewCell
                    {
                        self.collectionView.reloadItems(at: [IndexPath(row: self.orders.count - orderNum! - 2, section: 0)])
                        TTSManager.shared.play("주문번호 \(orderNum!)번 완료")
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
        return CGSize(width: width * 0.3, height: height * 0.55)
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
        var txt = ""
        let key = Array(self.orders[num]!.keys)
        let val = Array(self.orders[num]!.values)
        var dict: [String: AnyHashable] = [:]
        for i in 0..<key.count
        {
            if key[i] == "price"
            {
                cell.price = (val[i] as! Int)
                continue
            }
            else if key[i] == "tableNo"
            {
                cell.orderNum.text = "#\(num) - #\(val[i])"
                continue
            }
            else if key[i] == "salad"
            {
                if (val[i] as! Int) == 1
                {
                    cell.saladTeam.tintColor = .magenta
                    cell.saladTeam.setTitle("샐러드팀 서빙 중", for: .normal)
                }
                else if (val[i] as! Int) == 2
                {
                    cell.saladTeam.isUserInteractionEnabled = false
                    cell.saladTeam.tintColor = .lightGray
                    cell.saladTeam.setTitle("서빙 완료", for: .normal)
                }
                continue
            }
            else if key[i] == "pasta"
            {
                if (val[i] as! Int) == 1
                {
                    cell.pastaTeam.tintColor = .magenta
                    cell.pastaTeam.setTitle("파스타팀 서빙 중", for: .normal)
                }
                else if (val[i] as! Int) == 2
                {
                    cell.pastaTeam.isUserInteractionEnabled = false
                    cell.pastaTeam.tintColor = .lightGray
                    cell.pastaTeam.setTitle("서빙 완료", for: .normal)
                }
                continue
            }
            else if key[i] == "db"
            {
                if (val[i] as! Int) == 1
                {
                    cell.dbTeam.tintColor = .magenta
                    cell.dbTeam.setTitle("덮밥팀 서빙 중", for: .normal)
                }
                else if (val[i] as! Int) == 2
                {
                    cell.dbTeam.isUserInteractionEnabled = false
                    cell.dbTeam.tintColor = .lightGray
                    cell.dbTeam.setTitle("서빙 완료", for: .normal)
                }
                continue
            }
            else if key[i] == "dessert"
            {
                if (val[i] as! Int) == 1
                {
                    cell.dessertTeam.tintColor = .magenta
                    cell.dessertTeam.setTitle("디저트팀 서빙 중", for: .normal)
                }
                else if (val[i] as! Int) == 2
                {
                    cell.dessertTeam.isUserInteractionEnabled = false
                    cell.dessertTeam.tintColor = .lightGray
                    cell.dessertTeam.setTitle("서빙 완료", for: .normal)
                }
                continue
            }
            else if key[i] == "drink"
            {
                if (val[i] as! Int) == 1
                {
                    cell.drinkTeam.tintColor = .magenta
                    cell.drinkTeam.setTitle("음료팀 서빙 중", for: .normal)
                }
                else if (val[i] as! Int) == 2
                {
                    cell.drinkTeam.isUserInteractionEnabled = false
                    cell.drinkTeam.tintColor = .lightGray
                    cell.drinkTeam.setTitle("서빙 완료", for: .normal)
                }
                continue
            }
            else if ["transferAmount", "transferName", "cashAmount", "ticketNum"].contains(key[i])
            {
                continue
            }
            let k = key[i]
            dict[k.components(separatedBy: "\n")[1]] = val[i]
        }
        for i in Array(dict.keys).sorted()
        {
            txt += "\(i)\t - \(dict[i]!)\n"
        }
        cell.orderDetail.text = txt
        
        cell.backgroundColor = .gray
        var flag = false
        for i in K.completedOrders
        {
            if i.contains("#\(num)")
            {
                flag = true
            }
        }
        cell.contentView.backgroundColor = flag ? .systemMint : UIColor(red: 0.92, green: 0.35, blue: 0.401, alpha: 1.00)
        cell.layer.cornerRadius = 8.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        if !cell.drinkTeam.isUserInteractionEnabled && !cell.dbTeam.isUserInteractionEnabled && !cell.dessertTeam.isUserInteractionEnabled && !cell.pastaTeam.isUserInteractionEnabled && !cell.saladTeam.isUserInteractionEnabled
        {
            Task.init
            {
                if var arr = try await self.db.collection("orders").document("orderInfo").getDocument().data()?["completedOrders"] as? [String]
                {
                    if arr.contains(cell.orderNum.text!)
                    {
                        return
                    }
                    else
                    {
                        arr.append(cell.orderNum.text!)
                    }
                    try await self.db.collection("orders").document("orderInfo").updateData(["completedOrders" : arr])
                }
                if var total = try await self.db.collection("orders").document("orderInfo").getDocument().data()?["total"] as? Int
                {
                    total += cell.price!
                    try await self.db.collection("orders").document("orderInfo").updateData(["total" : total])
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return orders.count
    }
}
