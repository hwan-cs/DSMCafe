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
    
    @IBOutlet var scrollText: UILabel!

    @IBOutlet var scrollView: UIScrollView!
    
    var timer: Timer?
    
    var flag = false
    
    var offset = 0
    
    @IBOutlet var scrollTextWidth: NSLayoutConstraint!
    
//    @IBOutlet var scrollTextWidth: NSLayoutConstraint!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(UINib(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        titleLabel.font = UIFont.systemFont(ofSize: 40.0)
        
        scrollText.text = "건국대 DSM일동은 일일카페 서빙팀 및 주방팀을 응원 합니다 - 초희G: 알감자 콩감자 돼지감자, 정환G: 건덧셈 최고!, 동운G: 건덧셈 화이팅~, 동운G: 건덧셈 최고!, 동운G: 철야 끝나고 뚝섬으로 집합, 병욱G: 솔직히 좋아해"
        
        scrollView.showsHorizontalScrollIndicator = true
        scrollText.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isUserInteractionEnabled = false
        scrollText.backgroundColor = .black
        scrollView.layer.cornerRadius = 12
        scrollText.layer.cornerRadius = 12
        scrollText.textColor = .white
        scrollTextWidth.constant = scrollText.intrinsicContentSize.width
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(moveText), userInfo: nil, repeats: true)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tripleTapped))
        tap.numberOfTapsRequired = 3
        adminImage.isUserInteractionEnabled = true
        adminImage.addGestureRecognizer(tap)
    }
    
    @objc func moveText()
    {
        self.scrollView.setContentOffset(CGPoint(x: self.offset, y: 0), animated: true)
        self.offset += 10
        if self.offset % 30 == 0
        {
            self.scrollText.textColor = .systemPink
        }
        else if self.offset % 20 == 0
        {
            self.scrollText.textColor = .magenta
        }
        else
        {
            self.scrollText.textColor = .white
        }
        if CGFloat(self.offset) > scrollText.intrinsicContentSize.width - 20
        {
            self.offset = 0
        }
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
}

extension ViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderViewController") as! OrderViewController
        vc.modalPresentationStyle = .fullScreen
        vc.tableNo = indexPath.row + 1
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
