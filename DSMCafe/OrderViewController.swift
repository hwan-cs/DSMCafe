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
    
    @IBOutlet var paymentInfo: UIView!
    
    @IBOutlet var transferNum: UITextField!
    
    @IBOutlet var transferName: UITextField!
    
    @IBOutlet var cashAmount: UITextField!
    
    @IBOutlet var ticketNum: UITextField!
    
    var tableNo = 0
    
    var foodName = ["<식사류>\n어묵탕 + 치킨마요", "<식사류>\n라구파스타", "<사이드메뉴>\n어묵탕", "<사이드메뉴>\n연어샐러드", "<사이드메뉴>\n리코타샐러드", "<디저트류>\n크로플 (with 아이스크림)", "<디저트류>\n치즈케이크", "<디저트류>\n브라우니 (with 아이스크림)", "<디저트류>\n붕어빵",
                    "<음료>\n아메리카노", "<음료>\n카페라떼", "<음료>\n아샷추", "<음료>\n레몬에이드", "<음료>\n자몽에이드", "<음료>\n캐모마일 티", "<음료>\n페퍼민트 티", "<음료>\n얼그레이 티", "<음료>\n탄산음료 2잔(사이다/콜라)", "<음료>\n탄산음료 2잔(사이다/사이다)", "<음료>\n탄산음료 2잔(콜라/콜라)", "<식사류 음료>\n콜라", "<식사류 음료>\n사이다"]
    
    var menuArray = ["<식사류>\n어묵탕 + 치킨마요":[10000, 0], "<식사류>\n라구파스타":[10000, 0], "<사이드메뉴>\n어묵탕":[5000,0], "<사이드메뉴>\n연어샐러드":[5000, 0], "<사이드메뉴>\n리코타샐러드":[5000, 0],"<디저트류>\n크로플 (with 아이스크림)":[5000, 0], "<디저트류>\n치즈케이크":[5000, 0], "<디저트류>\n브라우니 (with 아이스크림)":[5000, 0], "<디저트류>\n붕어빵":[5000, 0], "<음료>\n아메리카노":[5000, 0], "<음료>\n카페라떼":[5000, 0], "<음료>\n아샷추":[5000, 0], "<음료>\n레몬에이드":[5000, 0], "<음료>\n자몽에이드":[5000, 0], "<음료>\n캐모마일 티":[5000, 0], "<음료>\n페퍼민트 티":[5000, 0], "<음료>\n얼그레이 티":[5000, 0], "<음료>\n탄산음료 2잔(사이다/콜라)":[5000, 0], "<음료>\n탄산음료 2잔(사이다/사이다)":[5000, 0], "<음료>\n탄산음료 2잔(콜라/콜라)":[5000, 0], "<식사류 음료>\n콜라":[0,0], "<식사류 음료>\n사이다" : [0,0]]
    
    var orderArray = [String]()
    
    let db = Firestore.firestore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        K.frameHeight = self.view.frame.origin.y
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.register(UINib(nibName: "MenuCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MenuCollectionViewCell")
        paymentInfo.isHidden = true
        paymentInfo.isUserInteractionEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func stepperChanged(_ sender: UIStepper!)
    {
        menuArray[self.foodName[sender.tag]]![1] = Int(sender.value)

        if !(self.orderArray.contains(self.foodName[sender.tag])) && Int(sender.value) > 0
        {
            self.orderArray.append(self.foodName[sender.tag])
        }
        else if Int(sender.value) == 0
        {
            self.orderArray.remove(at: self.orderArray.firstIndex(of: self.foodName[sender.tag])!)
        }
        self.collectionView.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
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
        var dict : [String:AnyHashable] = [:]
        for i in 0..<self.orderArray.count
        {
            foo += "\(self.orderArray[i]) \(self.menuArray[self.orderArray[i]]![1])개\n"
            dict[self.orderArray[i]] = self.menuArray[self.orderArray[i]]![1]
            total += self.menuArray[self.orderArray[i]]![1] * self.menuArray[self.orderArray[i]]![0]
        }
        dict["price"] = total
        dict["tableNo"] = self.tableNo
        dict["salad"] = 0
        dict["db"] = 0
        dict["pasta"] = 0
        dict["drink"] = 0
        dict["dessert"] = 0
        dict["transferAmount"] = self.transferNum.text!
        dict["transferName"] = self.transferName.text!
        dict["cashAmount"] = self.cashAmount.text!
        dict["ticketNum"] = self.ticketNum.text!
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
    
    @objc func keyboardWillShow(notification: NSNotification)
    {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            if K.frameHeight == self.view.frame.origin.y
            {
                self.view.frame.origin.y -= keyboardSize.height-90
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification)
    {
        print("hide")
        self.view.frame.origin.y = 0
    }
    
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard()
    {
        view.endEditing(true)
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
        cell.foodName.text = self.foodName[indexPath.row]
        cell.foodCount.text = "담은 수량: \(menuArray[self.foodName[indexPath.row]]![1])"
        cell.foodPrice.text = "\((menuArray[self.foodName[indexPath.row]]![0]))원"
        cell.stepper.tag = indexPath.row
        cell.stepper.value = Double(menuArray[self.foodName[indexPath.row]]![1])
        cell.infoPopTipText = "이게 무슨음식일까요?"
        if cell.stepper.allTargets.count == 1
        {
            cell.stepper.addTarget(self, action: #selector(stepperChanged(_ :)), for: .valueChanged)
        }
        var color = UIColor.systemBrown
        if cell.foodName.text!.contains("식사류")
        {
            color = UIColor(red: 0.92, green: 0.35, blue: 0.41, alpha: 1.00)
        }
        else if cell.foodName.text!.contains("사이드메뉴")
        {
            color = .systemTeal
        }
        else if cell.foodName.text!.contains("디저트류")
        {
            color = .systemPurple
        }
        cell.foodImage.image = UIImage(named: String(indexPath.row+1))
        cell.backgroundColor = menuArray[self.foodName[indexPath.row]]![1] > 0 ? .systemOrange : color
        cell.layer.cornerRadius = 8.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        if indexPath.row+1 == 22
        {
            self.paymentInfo.isUserInteractionEnabled = true
            self.paymentInfo.layer.cornerRadius = 12
            self.paymentInfo.isHidden = false
            self.collectionView.addSubview(self.paymentInfo)
        }
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
        cell.selectionStyle = .none
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



