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
    
    var foodName = [0:"햄버거", 1: "피자", 2: "치킨", 3: "시금치", 4: "김치", 5: "가지볶음", 6: "치즈", 7:"감자튀김",
                    8: "샐러드", 9:"파스타", 10:"부리또", 11:"타코", 12: "설렁탕", 13:"순대국밥", 14: "케밥", 15:"아무거나",
                    16: "짜장면", 17:"짬뽕", 18:"탕수육", 19:"샌드위치", 20:"빼빼로"]
    
    var menuArray = ["햄버거":[5000, 0], "피자":[8000, 0], "치킨":[7800,0], "시금치":[2000, 0], "김치":[500, 0], "가지볶음":[3200, 0], "치즈":[900, 0], "감자튀김":[1200, 0], "샐러드":[5000, 0], "파스타":[5000, 0], "부리또":[5000, 0], "타코":[5000, 0], "설렁탕":[5000, 0], "순대국밥":[8000, 0], "케밥":[5000, 0], "아무거나":[8000, 0], "짜장면":[8000, 0], "짬뽕":[8000, 0], "탕수육":[12000, 0], "샌드위치":[5000, 0], "빼빼로":[1000, 0]]
    
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
        cell.contentView.backgroundColor = flag ? .systemRed : UIColor(red: 0.96, green: 0.96, blue: 0.86, alpha: 1.00)
        
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
            try await db.collection("orders").getDocuments
            { querySnapshot, error in
                if let error = error
                {
                    print(error.localizedDescription)
                }
                else
                {
                    if let snapshotDocuments = querySnapshot?.documents
                    {
                        for doc in snapshotDocuments
                        {
                            let data = doc.data()
                            maxOrderNum = data.keys.sorted().suffix(1).first!
                            maxOrderNum = maxOrderNum.formatToOrderNum()
                        }
                    }
                }
            }
        }
        var foo = "\n"
        var dict : [String:Int] = [:]
        for i in 0..<self.orderArray.count
        {
            foo += "\(self.orderArray[i]) \(self.menuArray[self.orderArray[i]]![1])개\n"
            dict[self.orderArray[i]] = self.menuArray[self.orderArray[i]]![1]
        }
        let alert = UIAlertController(title: "주문", message: "주문 하시겠습니까?\(foo)", preferredStyle: .alert)
        //예외처리 해야됨
        let action = UIAlertAction(title: "예", style: .default)
        { (action) in
            Task.init
            {
                try await self.db.collection("orders").document().setData([maxOrderNum : dict])
            }
            self.dismiss(animated: true, completion: nil)
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
        cell.stepper.minimumValue = 0
        cell.stepper.tag = indexPath.item
        cell.infoPopTipText = "이게 무슨음식일까요?"
        cell.stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        cell.backgroundColor = .gray
        cell.contentView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.86, alpha: 1.00)
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



