//
//  QuizDoneCellCollectionViewCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 8/23/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

//delegate function. Fire off when the user presses the reset quiz button

protocol QuizDoneCVCellDelegate: class {
    
    func retartButtonPressed ()  //trigger when the user presses the restart button
    
}

class QuizDoneCVCell: UICollectionViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var retakeButton: UIButton!
    
    weak var delegate: QuizDoneCVCellDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        cellView.layer.cornerRadius = myConstants.layout_cornerRadius
        cellView.layer.borderWidth = 1
        cellView.clipsToBounds = true
        
        retakeButton.layer.cornerRadius = myConstants.button_cornerRadius
    }
    
    override func layoutSubviews() {
        //TODO: probably need to remove this and add into trait collection
        //set color here to it responds to dark mode
        cellView.layer.borderColor = UIColor(named: "color card border")?.cgColor
    }
    
    
    @IBAction func retakeButtonAction(_ sender: Any) {
        delegate?.retartButtonPressed()
    }
}
