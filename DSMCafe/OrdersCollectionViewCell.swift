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
    
    @IBOutlet var saladTeam: UIButton!
    
    @IBOutlet var dbTeam: UIButton!
    
    @IBOutlet var pastaTeam: UIButton!
    
    @IBOutlet var drinkTeam: UIButton!
    
    @IBOutlet var dessertTeam: UIButton!
    
    var price: Int?
    
    let db = Firestore.firestore()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.orderDetail.textColor = .black
        
    }
    
    @IBAction func saladTeamDidTap(_ sender: UIButton)
    {
        self.db.collection("orders").document("list").getDocument
        { documentSnapshot, error in
            if let e = error
            {
                print("There was an issue retrieving data from Firestore \(e)")
            }
            else
            {
                if let data = documentSnapshot?.data()
                {
                    let foobar = self.orderNum.text!.components(separatedBy: " - ")[0]
                    let orderNum = foobar.components(separatedBy: "#")[1]
                    var foo = data[orderNum] as! [String: AnyHashable]
                    var salad = foo["salad"] as! Int
                    foo.updateValue(salad+1, forKey: "salad")
                    if salad+1 == 2
                    {
                        TTSManager.shared.play("샐러드팀 서빙 완료")
                    }
                    documentSnapshot?.reference.updateData([orderNum: foo])
                }
            }
        }
    }
    
    @IBAction func dbTeamDidTap(_ sender: UIButton)
    {
        self.db.collection("orders").document("list").getDocument
        { documentSnapshot, error in
            if let e = error
            {
                print("There was an issue retrieving data from Firestore \(e)")
            }
            else
            {
                if let data = documentSnapshot?.data()
                {
                    let foobar = self.orderNum.text!.components(separatedBy: " - ")[0]
                    let orderNum = foobar.components(separatedBy: "#")[1]
                    var foo = data[orderNum] as! [String: AnyHashable]
                    var db = foo["db"] as! Int
                    foo.updateValue(db+1, forKey: "db")
                    if db+1 == 2
                    {
                        TTSManager.shared.play("덮밥팀 서빙 완료")
                    }
                    documentSnapshot?.reference.updateData([orderNum: foo])
                }
            }
        }
    }
    
    @IBAction func pastaTeamDIdTap(_ sender: UIButton)
    {
        self.db.collection("orders").document("list").getDocument
        { documentSnapshot, error in
            if let e = error
            {
                print("There was an issue retrieving data from Firestore \(e)")
            }
            else
            {
                if let data = documentSnapshot?.data()
                {
                    let foobar = self.orderNum.text!.components(separatedBy: " - ")[0]
                    let orderNum = foobar.components(separatedBy: "#")[1]
                    var foo = data[orderNum] as! [String: AnyHashable]
                    var pasta = foo["pasta"] as! Int
                    foo.updateValue(pasta+1, forKey: "pasta")
                    if pasta+1 == 2
                    {
                        TTSManager.shared.play("파스타팀 서빙 완료")
                    }
                    documentSnapshot?.reference.updateData([orderNum: foo])
                }
            }
        }
    }
    
    @IBAction func drinkTeamDidTap(_ sender: UIButton)
    {
        self.db.collection("orders").document("list").getDocument
        { documentSnapshot, error in
            if let e = error
            {
                print("There was an issue retrieving data from Firestore \(e)")
            }
            else
            {
                if let data = documentSnapshot?.data()
                {
                    let foobar = self.orderNum.text!.components(separatedBy: " - ")[0]
                    let orderNum = foobar.components(separatedBy: "#")[1]
                    var foo = data[orderNum] as! [String: AnyHashable]
                    var drink = foo["drink"] as! Int
                    foo.updateValue(drink+1, forKey: "drink")
                    if drink+1 == 2
                    {
                        DispatchQueue.main.async
                        {
                            TTSManager.shared.play("음료팀 서빙 완료")
                        }
                    }
                    documentSnapshot?.reference.updateData([orderNum: foo])
                }
            }
        }
    }
    
    @IBAction func dessertTeamDidTap(_ sender: UIButton)
    {
        self.db.collection("orders").document("list").getDocument
        { documentSnapshot, error in
            if let e = error
            {
                print("There was an issue retrieving data from Firestore \(e)")
            }
            else
            {
                if let data = documentSnapshot?.data()
                {
                    let foobar = self.orderNum.text!.components(separatedBy: " - ")[0]
                    let orderNum = foobar.components(separatedBy: "#")[1]
                    var foo = data[orderNum] as! [String: AnyHashable]
                    var dessert = foo["dessert"] as! Int
                    foo.updateValue(dessert+1, forKey: "dessert")
                    if dessert+1 == 2
                    {
                        TTSManager.shared.play("디저트팀 서빙 완료")
                    }
                    documentSnapshot?.reference.updateData([orderNum: foo])
                }
            }
        }
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        self.saladTeam.setTitle("샐러드팀", for: .normal)
        self.saladTeam.tintColor = .blue
        self.saladTeam.isUserInteractionEnabled = true
        self.pastaTeam.setTitle("파스타팀", for: .normal)
        self.pastaTeam.tintColor = .blue
        self.pastaTeam.isUserInteractionEnabled = true
        self.dessertTeam.setTitle("디저트팀", for: .normal)
        self.dessertTeam.tintColor = .blue
        self.dessertTeam.isUserInteractionEnabled = true
        self.drinkTeam.setTitle("음료팀", for: .normal)
        self.drinkTeam.tintColor = .blue
        self.drinkTeam.isUserInteractionEnabled = true
        self.dbTeam.setTitle("덮밥팀", for: .normal)
        self.dbTeam.tintColor = .blue
        self.dbTeam.isUserInteractionEnabled = true
    }
}
