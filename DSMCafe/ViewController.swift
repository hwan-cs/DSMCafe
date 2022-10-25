//
//  ViewController.swift
//  DSMCafe
//
//  Created by Jung Hwan Park on 2022/10/14.
//

import UIKit
import LTMorphingLabel

class ViewController: UIViewController
{

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var titleLabel: LTMorphingLabel!
    
    @IBOutlet var adminImage: UIImageView!
    
    var timer: Timer?
    
    var flag = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(UINib(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
        titleLabel.font = UIFont.systemFont(ofSize: 40.0)
        titleLabel.morphingEffect = .burn
        titleLabel.morphingDuration = 1.5
        titleLabel.text = ""
        titleLabel.text = "환영합니다"
        titleLabel.start()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tripleTapped))
        tap.numberOfTapsRequired = 3
        adminImage.isUserInteractionEnabled = true
        adminImage.addGestureRecognizer(tap)
    }
    
    @objc func tripleTapped()
    {
        let alertController = UIAlertController(title: "비밀번호를 입력하세요", message: "^___^", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            if textField.text == "0191"
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AdminViewController") as! AdminViewController
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "비밀번호"
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func fire()
    {
        flag.toggle()
        titleLabel.text = ""
        titleLabel.text = flag ? "테이블을 선택해주세요" : "환영합니다"
        titleLabel.start()
    }
}

extension ViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderViewController") as! OrderViewController
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! MyCollectionViewCell
        
        cell.cellImage.image = UIImage(systemName: "fork.knife.circle.fill")
        cell.cellImage.contentMode = .scaleAspectFit
        cell.cellTitle.text = "테이블 #\(indexPath.item+1)"
        cell.backgroundColor = .gray
        cell.contentView.backgroundColor = .systemIndigo
        cell.layer.cornerRadius = 8.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.lightGray.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 20
    }
    
}
