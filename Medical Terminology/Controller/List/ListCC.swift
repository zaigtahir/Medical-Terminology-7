//
//  ListCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/9/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol ListCellDelegate: class {
    func pressedFavoriteButton (sender: UIButton, indexPath: IndexPath, itemID: Int)
}

class ListCC: UITableViewCell {

    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var cellView: UIView!
    
    var indexPath : IndexPath!
    let utilities = Utilities()
    
    //to keep info for favorites
    var itemID : Int!
    var isFavorite: Bool!
    
    weak var delegate: ListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }
    
    func configure (itemID: Int, term: String, definition: String, isFavorite: Bool, indexPath: IndexPath) {
        self.itemID = itemID
        self.isFavorite = isFavorite
        
        termLabel.text = term
        definitionLabel.text = definition
        self.indexPath = indexPath
        
        //set favorite button
        utilities.setFavoriteState(button: favoriteButton, isFavorite: isFavorite)
    }
    
    @IBAction func favoriteButtonAction(_ sender: UIButton) {
        isFavorite = !isFavorite
        utilities.setFavoriteState(button: favoriteButton, isFavorite: isFavorite)
        delegate?.pressedFavoriteButton(sender: sender, indexPath: indexPath, itemID: self.itemID)
    }
    
}
