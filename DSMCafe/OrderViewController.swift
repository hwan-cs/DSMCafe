//
//  OrderViewController.swift
//  DSMCafe
//
//  Created by Jung Hwan Park on 2022/10/14.
//

import Foundation
import UIKit
import FirebaseFirestore
import Firebase

class OrderViewController: UIViewController
{
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var orderButton: UIButton!
    
    var foodName = [0:"<식사류>\n어묵탕 + 치킨마요", 1: "<식사류>\n라구파스타", 2: "<사이드메뉴>\n어묵탕", 3: "<사이드메뉴>\n연어샐러드/리코타샐러드", 4: "<디저트류>\n크로플 (with 아이스크림)", 5: "<디저트류>\n치즈케이크", 6: "<디저트류>\n브라우니 (with 아이스크림)", 7:"<디저트류>\n붕어빵",
                    8: "<음료>\n아메리카노", 9:"<음료>\n카페라떼", 10:"<음료>\n아샷추", 11:"<음료>\n레몬/자몽에이드", 12: "<음료>\n캐모마일/페퍼민트/얼그레이 티", 13:"<음료>\n탄산음료 2잔(사이다/콜라)", 14: "<음료>\n탄산음료 2잔(사이다/사이다)", 15:"<음료>\n탄산음료 2잔(콜라/콜라)"]
    
    var menuArray = ["<식사류>\n어묵탕 + 치킨마요":[10000, 0], "<식사류>\n라구파스타":[10000, 0], "<사이드메뉴>\n어묵탕":[5000,0], "<사이드메뉴>\n연어샐러드/리코타샐러드":[5000, 0], "<디저트류>\n크로플 (with 아이스크림)":[5000, 0], "<디저트류>\n치즈케이크":[5000, 0], "<디저트류>\n브라우니 (with 아이스크림)":[5000, 0], "<디저트류>\n붕어빵":[5000, 0], "<음료>\n아메리카노":[5000, 0], "<음료>\n카페라떼":[5000, 0], "<음료>\n아샷추":[5000, 0], "<음료>\n레몬/자몽에이드":[5000, 0], "<음료>\n캐모마일/페퍼민트/얼그레이 티":[5000, 0], "<음료>\n탄산음료 2잔(사이다/콜라)":[5000, 0], "<음료>\n탄산음료 2잔(사이다/사이다)":[5000, 0], "<음료>\n탄산음료 2잔(콜라/콜라)":[5000, 0]]
    
    var orderArray = [String]()
    
    let db = Firestore.firestore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.register(UINib(nibName: "MenuCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MenuCollectionViewCell")
    }
    
    @objc func stepperChanged(_ sender: UIStepper!)
    {
        menuArray[self.foodName[sender.tag]!]![1] = Int(sender.value)
        var flag = sender.value > 0 ? true:false
        let cell = self.collectionView.cellForItem(at: IndexPath(item: sender.tag, section: 0)) as! MenuCollectionViewCell
        cell.foodCount.text = "담은 수량: \(Int(sender.value))"
        cell.contentView.backgroundColor = flag ? .systemOrange : UIColor(red: 0.92, green: 0.35, blue: 0.41, alpha: 1.00)
        if !(self.orderArray.contains(self.foodName[sender.tag]!)) && Int(sender.value) > 0
        {
            self.orderArray.append(self.foodName[sender.tag]!)
        }
        else if Int(sender.value) == 0
        {
            self.orderArray.remove(at: self.orderArray.firstIndex(of: self.foodName[sender.tag]!)!)
        }
        self.tableView.reloadData()
    }
    
    @IBAction func orderTapped(_ sender: UIButton)
    {
        var maxOrderNum = "0001"
        Task.init
        {
            if let data = try await self.db.collection("orders").document("list").getDocument().data()
            {
                if let num = data.keys.sorted().suffix(1).first
                {
                    maxOrderNum = num.formatToOrderNum()
                }
            }
        }
        var total = 0
        var foo = "\n\n"
        var dict : [String:Int] = [:]
        for i in 0..<self.orderArray.count
        {
            foo += "\(self.orderArray[i]) \(self.menuArray[self.orderArray[i]]![1])개\n"
            dict[self.orderArray[i]] = self.menuArray[self.orderArray[i]]![1]
            total += self.menuArray[self.orderArray[i]]![1] * self.menuArray[self.orderArray[i]]![0]
        }
        dict["price"] = total
        let alert = UIAlertController(title: "주문", message: "주문 하시겠습니까?\(foo)\n\(total)원", preferredStyle: .alert)
        //예외처리 해야됨
        let action = UIAlertAction(title: "예", style: .default)
        { (action) in
            Task.init
            {
                try await self.db.collection("orders").document("list").updateData([maxOrderNum : dict])
            }
            self.dismiss(animated: true)
            {
                self.dismiss(animated: true)
            }
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "아니오", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Alert dismissed")
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension String
{
    func formatToOrderNum() -> String
    {
        if var orderNum = Int(self)
        {
            orderNum += 1
            if orderNum < 10
            {
                return "000\(String(orderNum))"
            }
            else if orderNum < 100
            {
                return "00\(String(orderNum))"
            }
            else if orderNum < 1000
            {
                return "0\(String(orderNum))"
            }
            return String(orderNum)
        }
        return self
    }
}

extension OrderViewController
{
    fileprivate func createCompositionalLayout() -> UICollectionViewLayout
    {
        let layout = UICollectionViewCompositionalLayout
        { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/5), heightDimension: .fractionalHeight(0.5))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: itemSize.heightDimension)
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item, item, item, item, item])
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        return layout
    }
}

extension OrderViewController: UICollectionViewDelegate
{
    
}

extension OrderViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCollectionViewCell", for: indexPath) as! MenuCollectionViewCell
        
        cell.foodImage.image = UIImage(systemName: "eyes.inverse")
        cell.foodName.text = self.foodName[indexPath.item]
        cell.foodCount.text = "담은 수량: \(menuArray[self.foodName[indexPath.item]!]![1])"
        cell.foodPrice.text = "\((menuArray[self.foodName[indexPath.item]!]![0]))원"
        cell.stepper.minimumValue = 0
        cell.stepper.tag = indexPath.item
        cell.infoPopTipText = "이게 무슨음식일까요?"
        cell.stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        cell.backgroundColor = .gray
        var color = UIColor.systemBrown
        if self.foodName[indexPath.item]!.contains("식사류")
        {
            color = UIColor(red: 0.92, green: 0.35, blue: 0.41, alpha: 1.00)
        }
        else if self.foodName[indexPath.item]!.contains("사이드메뉴")
        {
            color = .systemTeal
        }
        else if self.foodName[indexPath.item]!.contains("디저트류")
        {
            color = .systemPurple
        }
        cell.contentView.backgroundColor = cell.stepper.value > 0 ? .systemOrange : color
        cell.layer.cornerRadius = 8.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.lightGray.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return foodName.count
    }
}

extension OrderViewController: UITableViewDelegate
{
    
}

extension OrderViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = self.orderArray[indexPath.row]
        config.secondaryText = "\(String(menuArray[self.orderArray[indexPath.row]]![1]))개"
        cell.contentConfiguration = config
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.orderArray.count
    }
}



