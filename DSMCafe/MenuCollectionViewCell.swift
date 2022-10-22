//
//  MenuCollectionViewCell.swift
//  DSMCafe
//
//  Created by Jung Hwan Park on 2022/10/14.
//

import Foundation
import UIKit
import AMPopTip

class MenuCollectionViewCell: UICollectionViewCell
{
    @IBOutlet var foodImage: UIImageView!
    
    @IBOutlet var foodName: UILabel!
    
    @IBOutlet var foodCount: UILabel!
    
    @IBOutlet var stepper: UIStepper!
    
    let infoPopTip = PopTip()
    
    var infoPopTipText: String?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        tap.numberOfTapsRequired = 1
        self.foodImage.isUserInteractionEnabled = true
        self.foodImage.addGestureRecognizer(tap)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        self.infoPopTip.bubbleColor = UIColor.systemIndigo
        self.infoPopTip.shouldDismissOnTap = true
        if self.infoPopTip.isVisible
        {
            self.infoPopTip.hide()
        }
        self.infoPopTip.show(text: self.infoPopTipText!, direction: .auto, maxWidth: 150, in: self.contentView, from: tappedImage.frame)
    }
}
