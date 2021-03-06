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
    @IBOutlet weak var playAudioButton: UIButton!
    
    var indexPath : IndexPath!
    var dItem : DItem!
    let utilities = Utilities()
    
    weak var delegate: ListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }
    
    func configure(dItem: DItem, indexPath: IndexPath) {
        self.dItem = dItem
        self.indexPath = indexPath
        self.termLabel.text = dItem.term
        self.definitionLabel.text = dItem.definition
        
        utilities.setFavoriteState(button: favoriteButton, isFavorite: dItem.isFavorite)
    }
    
 
    @IBAction func favoriteButtonAction(_ sender: UIButton) {
        // MARK: to fix
        /*
        
        isFavorite = !isFavorite
        utilities.setFavoriteState(button: favoriteButton, isFavorite: isFavorite)
        delegate?.pressedFavoriteButton(sender: sender, indexPath: indexPath, itemID: self.itemID)*/
    }
    
    @IBAction func playAudioButtonAction(_ sender: UIButton) {
        print ("audio play button pressed")
    }
    
    
}
