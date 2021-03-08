//
//  LearnDoneCVCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 8/23/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

//delegate function. Fire off when the user presses the reset quiz button

protocol LearnDoneCVCellDelegate: class {
    
    func retartButtonPressed ()  //trigger when the user presses the restart button
    
}

class LearnDoneCVCell: UICollectionViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var doneLabel: UILabel!
    
    weak var delegate: LearnDoneCVCellDelegate?

    override func awakeFromNib() {
           
           super.awakeFromNib()
           // Initialization code
           cellView.layer.cornerRadius = myConstants.layout_cornerRadius
           cellView.layer.borderWidth = 1
           cellView.clipsToBounds = true
           
       }
       
       override func layoutSubviews() {
           //set color here to it responds to dark mode
           cellView.layer.borderColor = UIColor(named: "color card border")?.cgColor
       }
    
    @IBAction func restartButtonAction(_ sender: Any) {
        
        delegate?.retartButtonPressed()
        
    }
    
}
