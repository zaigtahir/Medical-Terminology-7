//
//  ListViewController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 10/27/18.
//  Copyright © 2018 Zaigham Tahir. All rights reserved.
//

import UIKit
import SQLite3
class ListVC: UIViewController, ListTCDelagate {
    
    //will use ListTC as the table datasource
    //use this VC to use as the table delegate as lots of actions happen based on selection including segue
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var favoritesLabel: UILabel!
    @IBOutlet weak var favoritesSwitch: UISwitch!
    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var noFavoritesLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemID = 0 //will hold the itemID based on the row the user clicks, will be used for performing the detail seque
    var listTC: ListVCH! //need to keep a reference here
    
    let dIC = DItemController()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //setting my ListTC class as the tableview datasource and delegate
        listTC = ListVCH()
        tableView.dataSource = listTC
        tableView.delegate = listTC
        
        //formatting
        favoritesSwitch.layer.cornerRadius = 16
        favoritesSwitch.clipsToBounds = true
        favoritesSwitch.onTintColor = myTheme.colorFavorite
        favoritesSwitch.isOn = listTC.isFavoritesOnly()
        
        //setting the same instance of ListTC and set its delegate to SELF to it can message back to me here
        listTC.delegate = self
        listTC.tableViewReference = tableView
        
        noFavoritesLabel.text = myConstants.noFavoritesAvailableText
        
        //need this here so cancel button does not get hidden.... seems like a hack
        searchBar.searchBarStyle = .prominent
        searchBar.delegate = listTC
        updateDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        listTC.refreshList()
        updateDisplay()
    }
    
    private func updateDisplay () {
        //call this function to update the display
        //remember to use listTC.makeList function to refresh the data before using tableView.reload
        updateCounter()
        let favCount = dIC.getCount(favoriteState: 1, learnedState: -1)
        
        if listTC.isFavoritesOnly() {
            favoritesSwitch.isOn = true
        } else {
            favoritesSwitch.isOn = false
        }
        
        //  if you are searching, you have to show a table regardless with some or no results
        //  regardless of the favorite button
        
        if listTC.isSearching() {
            //in search mode
            tableView.isHidden = false
            noFavoritesLabel.isHidden = true
            heartImage.isHidden = true
            
            
        } else {
            //not in search mode. need to see if we are showing only favorites and the favorite count is 0
            
            if favCount == 0 && listTC.isFavoritesOnly() {
                //favorite list is empty. do not show the table Need to show the list is empty message
                tableView.isHidden = true
                noFavoritesLabel.isHidden = false
                heartImage.isHidden = false
                
            } else {
                //need to show table data
                tableView.isHidden = false
                noFavoritesLabel.isHidden = true
                heartImage.isHidden = true
            }
        }
    }
    
    private func updateCounter () {
        let favCount = dIC.getCount(favoriteState: 1, learnedState: -1)
        favoritesLabel.text = "\(favCount)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: delegate functions
    func selectedItemID(itemID: Int) {
        self.itemID = itemID    //save as a class varialbe to that prepare for segue can use this value
        performSegue(withIdentifier: "showDItemSegue", sender: self)
    }
    
    func favoriteItemChanged(newFavoriteState: Bool) {
        
        if listTC.isFavoritesOnly() {
            if newFavoriteState == false {
                updateDisplay()
            }
        } else {
            //just update the counter
            updateCounter()
        }        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //can have only one seque so don't need to worry about testing for it
        let destVC = segue.destination as! DItemVC
        destVC.itemID = self.itemID
    }
    
    @IBAction func favoritesOnlySwitchAction(_ sender: UISwitch) {
        listTC.makeList(favoritesOnly: sender.isOn, searchText: searchBar.text ?? "")
        
        updateDisplay()
    }
}
