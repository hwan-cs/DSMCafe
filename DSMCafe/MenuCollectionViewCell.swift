//
//  MenuCollectionViewCell.swift
//  DSMCafe
//
//  Created by Jung Hwan Park on 2022/10/14.
//

import Foundation
import UIKit
import AMPopTip
import FirebaseFirestore

class MenuCollectionViewCell: UICollectionViewCell
{
    @IBOutlet var foodImage: UIImageView!
    
    @IBOutlet var foodPrice: UILabel!
    
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
        self.stepper.minimumValue = 0
        self.stepper.stepValue = 1.0
        self.stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
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
    
    @objc func stepperChanged(_ sender: UIStepper)
    {
        print("Stepper changed \(sender.value)")
        self.foodCount.text = "담은 수량: \(Int(sender.value))"
        self.foodCount.text = "담은 수량: \(Int(sender.value))"
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        for t in self.stepper.allTargets
        {
            self.stepper.removeTarget(self, action: t as? Selector, for: .valueChanged)
        }
    }
}
