//
//  FlashCardController2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/17/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//



import Foundation

//Will manage an array of lists. Each list will be an array of Integers representing itemIDs
//if by chance no items are found, the lists will be empty (count = 0)


//TODO: need to think about refreshing favorites list from the DB as a card may be unfavorited in another view

class FlashCardController {
    
    private var fullList = DList ()
    private var favoriteList = DList ()
    private var lists = [DList] ()
    
    private var currentListIndex = myConstants.listType_Full
    
    private var dIC = DItemController()
    
    init() {

        lists.append(fullList)      //appended as index = 0 which will match the shared constant
        lists.append(favoriteList)  //appended as index = 1 which will match the shared constant
        
        loadFullList()
        loadFavoriteList()
    }
    
    private func loadFullList() {
        
        lists[myConstants.listType_Full].itemIDs = dIC.getItemIDs(favoriteState: -1, learnedState: -1, orderBy: 1, limit: -1)
        lists[myConstants.listType_Full].itemIndex = 0
    }
    
    func loadFavoriteList() {
        lists[myConstants.listType_Favorite].itemIDs = dIC.getItemIDs(favoriteState: 1, learnedState: -1, orderBy: 1, limit: -1)
        lists[myConstants.listType_Favorite].itemIndex = 0
    }
    
    private func removeItem () {
        //this will remove the item at the index
        //the index will need to adjust itself if the last item is removed
        
        let currentList = lists[currentListIndex]
        currentList.itemIDs.remove(at: currentList.itemIndex)
        
        //reset the index to max value if the last item was removed
        if currentList.itemIndex > currentList.itemIDs.count - 1 {
            currentList.itemIndex = currentList.itemIDs.count - 1
        }
    }
    
    private func listIsEmpty () -> Bool {
        if lists[currentListIndex].itemIDs.count == 0 {
            return true
        } else {
            return false
        }
    }
    
    func getItemID () -> Int {
        let currentList = lists[currentListIndex]
        return currentList.itemIDs[currentList.itemIndex]
    }
    
    func getItemIndex () -> Int {
        return lists[currentListIndex].itemIndex
    }
    
    func getItemCount () -> Int {
        return lists[currentListIndex].itemIDs.count
    }
    
    func getItem () -> DItem? {
        
        //returns the item from the Database based using the itemID
        
        let currentList  = lists[currentListIndex]
        
        if currentList.itemIDs.count == 0 {
            return nil
        }
        
        let itemID = currentList.itemIDs[currentList.itemIndex]
        
        return dIC.getDItem(itemID: itemID)
    }
    
    func getList () -> DList {
        return lists[currentListIndex]
    }
    
    func setListIndex (listIndex: Int) {
        
        if listIndex == 0{
            //load the full list
            currentListIndex = 0
        } else {
            //load favorite list
            loadFavoriteList() //will reload the list so that it will refresh from the database
            currentListIndex = 1
        }
    }
    
    func getListIndex () -> Int {
        return currentListIndex
    }
    
    func setItemIndex (itemIndex: Int) {
        //only allow to set to list.count - 1
        let maxIndex = lists[currentListIndex].itemIDs.count - 1
        
        if itemIndex > maxIndex {
            lists[currentListIndex].itemIndex = maxIndex
        }
        
        lists[currentListIndex].itemIndex = itemIndex
    }
    
    func moveNext () {
        
        let currentList = lists[currentListIndex]
        
        if currentList.itemIDs.count <= 1 {
            return  //return without doing anything
        }
        
        if currentList.markForRemoval == true {
            removeItem()
            currentList.markForRemoval = false
            return //return without moving the index
        }
        
        if currentList.itemIndex < currentList.itemIDs.count - 1 {
            currentList.itemIndex += 1
        }
    }
    
    func movePrev () {
        
        let currentList = lists[currentListIndex]
        
        if currentList.itemIDs.count <= 1 {
            return  //return without doing anything
        }
        
        if currentList.markForRemoval == true {
            removeItem()
            currentList.markForRemoval = false
            return //return without moving the index
        }
        
        if currentList.itemIndex > 0  {
            currentList.itemIndex -= 1
        }
        
    }
    
    func moveRandom () {
        
        let currentList = lists[currentListIndex]
        
        if currentList.itemIDs.count <= 1 {
            return  //return without doing anything
        }
        
        if currentList.markForRemoval == true {
            currentList.markForRemoval = false
            removeItem()
            return //return without moving the index
        }
        
        var indexArray  = Array(0...currentList.itemIDs.count - 1) //make an array of just the indexes
        
        indexArray.remove(at: currentList.itemIndex)    //remove the current index so it is not picked in the random function
        
        let randomIndex = Int(arc4random_uniform(UInt32(indexArray.count))) // 0 to count -1
        currentList.itemIndex = indexArray[randomIndex]
    }
    
    func toggleFavorite () -> Bool {
        //change the isFavorite state of the item locally
        //update the isFavorite state in the db
        //if you are viewing the favorite list, and the user unfav's the item, mark the list item for deletion. However, if this is was the last item on the favorites list, just remove it from the list so the view can update to show that the favorites list is empty
        //the list item is deleted when the user presses one of the navigation buttons, but the database item is updated before that
        
        /*
         If you are viewing the favorites list and the user UNFAVORITES an item:
         
         -If this was the LAST item on the list and the user unfavorites it then do the following:
         1. update the database isFavorite state
         2. remove the item from the local list immediately. This is so that the displayFlashcard and then show the list is empty
         
         -If this was NOT THE LAST item on the list and the user unfavorites it then do the following:
         1. update the database isFavorite state
         2. mark the tiem for removal. The list controller will actually remove the item from the local list after a navigation button is pressed
         
         */
        
        if listIsEmpty() {
            return false //do nothing if the list is empty
        }
        
        let currentList = lists[currentListIndex]
        let itemID = currentList.itemIDs[currentList.itemIndex]
        
        let item = dIC.getDItem(itemID: itemID) 
        
        //update the database
        
        dIC.saveFavorite(itemID: itemID, isFavorite: !item.isFavorite)
        
        //if this is the favorites list and the user unfavorites the very last favorite item then remove it from the local list immediately
        if currentListIndex == 1 && item.isFavorite == true && currentList.itemIDs.count == 1 {
            print("you are going to unfavorite the last item on the favorite list!")
            removeItem()
        }
        
        //if this is favorite's list and user unfav's an item, mark it for deletion
        if currentListIndex == 1 && item.isFavorite {
            lists[currentListIndex].markForRemoval = true
        }
        
        return !item.isFavorite //return the new isFavorite state
        
    }
    
}


