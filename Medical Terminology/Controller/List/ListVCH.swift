//
//  ListTC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/7/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit
//  will serve as the table view source and delegate for the list table

//  will generate an alphaList when not searching:  an AlphaList object
//  will generate an array of [DItems] when searching: (one dimension array)
//  will configure and show the data appropriately on the table with single array or the AlphaList

protocol ListTCDelagate: class {
    func selectedItemID (itemID: Int)   //will return the dItem the user selects
    func favoriteItemChanged(newFavoriteState: Bool)  //when the user changes the state of a favorite item
}

//Have to incude NSObject to that ListVCH can implement the table view and search bar delegates
class ListVCH: NSObject, UITableViewDataSource, UITableViewDelegate, ListCellDelegate, UISearchBarDelegate
{
    private var searchText = ""
    private var favoritesOnly = false
    private var alphaList = AlphaList()
    private var dIC = DItemController()
    private var searchList = [DItem]()
    private let searchLists = SearchLists()
    weak var delegate: ListTCDelagate?
    var tableViewReference = UITableView()
    
    override init() {
        //Initialize the alphalist to show all
        super.init()
        makeList(favoritesOnly: favoritesOnly, searchText: searchText)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        if showAlphaList() {
            return alphaList.sections.count
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showAlphaList() {
            return alphaList.listItems[section].count
        } else {
            return searchList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //use a default cell with subtitle setting in the story board
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! ListCC
        //get the dItem for which ever list is set
        
        var dItem: DItem
        
        if showAlphaList() {
            dItem = alphaList.getDItemFromList(indexPath: indexPath)
        } else {
            dItem = searchList[indexPath.row]
        }
        
        cell.configure(dItem: dItem, indexPath: indexPath)
        cell.delegate = self   //assigning self for deligate
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //assign section title(s)
        
        if isFavoritesOnly() {
            
            if isSearching() {
                return "Searching Favorites"
                
            }else {
                return "Favorites List"
            }
            
        } else {
            
            if isSearching() {
                return "Searching"
            }else {
                return alphaList.sections[section]
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
       
        /*
        
        view.tintColor = myTheme.color_section_header
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = myTheme.color_section_text
 */
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        if showAlphaList() {
            return alphaList.sections
        } else {
            return nil
        }
        
    }
    
    // table delegate functions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //save the dItem user selected based on section and row
        
        // MARK: to fix
        /*
        if let cell = tableView.cellForRow(at: indexPath) as? ListCC {
            delegate?.selectedItemID(itemID: cell.itemID)
        } else {
            print("problem getting cell in ListTC didSelectRow")
        }*/
        
    }
    
    //ListCC delegate function
    func pressedFavoriteButton(sender: UIButton, indexPath: IndexPath, itemID: Int) {
        
        //if you are seeing the favorites list and you unfavorite an item, need to refresh the data list and delete the table row with animation
        
        let tempItem = dIC.getDItem(itemID: itemID)
        
        dIC.saveFavorite(itemID: itemID, isFavorite: !tempItem.isFavorite)
        
        refreshList()   //update the currently used list from the database
        
        delegate?.favoriteItemChanged(newFavoriteState: !tempItem.isFavorite) //return the new state of the favorite
        
        
    }
    
    //TODO: probably try to remove this maybe?
    func refreshList () {
        //will just use the stored settings to remake the list
        //use this primarily when the user deselects a favorite item on the favorite only lists
        makeList(favoritesOnly: isFavoritesOnly(), searchText: searchText)
        tableViewReference.reloadData()
    }
    
    // other functions for this class
    func makeList (favoritesOnly: Bool, searchText: String) {
        
        self.searchText = searchText
        self.favoritesOnly = favoritesOnly
        
        if showAlphaList() {
            alphaList = searchLists.makeAlphaList(favoritesOnly: favoritesOnly)
            
        } else {
            searchList = searchLists.makeSearchList(favoritesOnly: favoritesOnly, searchText: searchText)
        }
        
        tableViewReference.reloadData()
        
    }
    
    private func showAlphaList () -> Bool {
        if favoritesOnly == false && searchText == "" {
            return true
        } else {
            return false
        }
    }
    
    func isSearching () -> Bool {
        
        if searchText == "" {
            return false
        } else {
            return true
        }
    }
    
    func isFavoritesOnly () -> Bool {
        return self.favoritesOnly
    }
 
    //search bar delegate functions
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.showsCancelButton == false {
            searchBar.showsCancelButton = true
        }
        makeList(favoritesOnly: favoritesOnly, searchText: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        searchText = ""
        // Hide the cancel button
        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
        searchBar.endEditing(true)
        
        
        makeList(favoritesOnly: favoritesOnly, searchText: searchText)
    }
    
}
