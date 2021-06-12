//
//  AnswerTCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 6/13/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

/**
 Used for the table cell that shows the answers to questions for the quiz or learning set
 */


import UIKit

protocol AnswerSelected {
	func answerSelected()
}

class AnswerTCell: UITableViewCell {

    @IBOutlet weak var answerImage: UIImageView!
    @IBOutlet weak var answerNumberLabel: UILabel!
    @IBOutlet weak var answerText: UILabel!
	@IBOutlet weak var selectAnswerButton: UIButton!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	@IBAction func selectAnswerButtonAction(_ sender: UIButton) {
		print ("code for answer selected")
	}
	
}
