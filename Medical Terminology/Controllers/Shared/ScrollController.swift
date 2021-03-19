//
//  SVController.swift
//  CVScroll
//
//  Created by Zaigham Tahir on 7/22/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//


/*
 This class enables a collection view to paginate horizonally or vertically where each cell fills the collection view with the given top and side margins.
 
 It will trigger the delegate method CVCellChanged when the user manually scolls the collection view or uses the scroll methods to move it. So, controller using this will need to implement the protocol
 */

import UIKit

// delegate function. This will fire off when a new cell loads into the controller

protocol ScrollControllerDelegate: class {
    
    //when the scroll is fully at a stopped position of a new cell
    func CVCellChanged (cellIndex: Int)
    
    // when the scroll is being continusly being dragged by the user without it stopping.
    // Use this to update the UI elements that show where the user is in the stack of objects
    func CVCellDragging (cellIndex: Int)
}

class ScrollController: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: ScrollControllerDelegate?
    
    let HORIZONTAL = 0
    
    let VERTICAL = 1
    
    var topBottomMargin = CGFloat(integerLiteral: 10)
    
    var sideMargin = CGFloat(integerLiteral: 10)
    
    var showMoveAnimation = true
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: collectionView.frame.width - (2 * sideMargin), height: collectionView.frame.height - (2 * topBottomMargin))
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 2 * topBottomMargin
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: topBottomMargin, left: sideMargin, bottom: topBottomMargin, right: sideMargin)
    }
    
    //MARK: utility functions
    
    func getCellIndex (collectionView: UICollectionView) -> Int {
        
        //return what cell index the collection view is on
        
        var offset: CGFloat
        
        if getScrollDirection(collectionView: collectionView) == 0 {
            
            offset = collectionView.contentOffset.x / collectionView.frame.width
            
        } else {
            
            offset = collectionView.contentOffset.y / collectionView.frame.height
        }
        
        //will need to round and return the result
        let roundResult = round(offset)
        
        return Int(roundResult)
        
    }
        
    private func getScrollDirection (collectionView: UICollectionView) -> Int {
        
        //  return 0 = horizontal, 1 = vertical
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        if layout.scrollDirection == .horizontal {
            
            return HORIZONTAL
            
        } else {
            
            return VERTICAL
        }
        
    }
    
    func scrollToCell (collectionView: UICollectionView, cellIndex: Int, animated: Bool) {
        
        //error check
        let cellCount = collectionView.numberOfItems(inSection: 0)
        
        if (cellIndex < 0 || cellIndex > cellCount - 1) {
            print("scrollToCell error state: asking to scroll to cellIndex: \(cellIndex) which is outside range of cellCount: \(cellCount)")
            return
        }
    
        
        if getScrollDirection(collectionView: collectionView) == HORIZONTAL {
            
            collectionView.scrollToItem(at: IndexPath(row: cellIndex, section: 0), at: .centeredHorizontally, animated: animated)
            
        } else {
            
            collectionView.scrollToItem(at: IndexPath(row: cellIndex, section: 0), at: .centeredVertically, animated: animated)
        }
        
        //if animated is false, need to manually trigger an alert
        
        if !animated {
            
            scrollViewDidEndScrollingAnimation( collectionView as UIScrollView)
        }
    }
    
    func reloadCurrentCell (collectionView: UICollectionView) {
        //will refresh the current index path
        
        let currentCellIndex = getCellIndex(collectionView: collectionView)
        collectionView.reloadItems(at: [IndexPath(item: currentCellIndex, section: 0)])
    }
    
    //MARK: navigation button states
    
    func isPreviouButtonEnabled (collectionView: UICollectionView) -> Bool {
        
        let cellCount = collectionView.numberOfItems(inSection: 0)
        
        if cellCount == 0 {
            
            return false
        }
        
        let cellIndex = getCellIndex(collectionView: collectionView)
        
        if cellIndex == 0 {
            
            return false
            
        } else {
            
            return true
        }
    }
    
    func isRandomButtonEnabled (collectionView: UICollectionView) -> Bool  {
        
        let cellCount = collectionView.numberOfItems(inSection: 0)
        
        if cellCount > 2 {
            
            return true
            
        } else {
            
            return false
        }
    }
    
    func isNextButtonEnabled (collectionView: UICollectionView) -> Bool  {
        
        let cellCount = collectionView.numberOfItems(inSection: 0)
        
        if cellCount == 0 {
            
            return false
        }
        
        
        
        let cellIndex = getCellIndex(collectionView: collectionView)
        
        if cellIndex < cellCount - 1 {
            
            return true
            
        } else {
            
            return false
        }
        
    }
    
    //MARK: scroll functions
    
    func scrollNext (collectionView: UICollectionView, animated: Bool = true) {
        
        let cellCount = collectionView.numberOfItems(inSection: 0)
        
        let cellIndex = getCellIndex(collectionView: collectionView)
        
        if (cellIndex < cellCount - 1) {
            scrollToCell(collectionView: collectionView, cellIndex: cellIndex + 1, animated: animated)
        }
    }
    
    func scrollPrevious (collectionView: UICollectionView, animated: Bool = true) {
        
        let cellIndex = getCellIndex(collectionView: collectionView)
        
        if (cellIndex > 0) {
            scrollToCell(collectionView: collectionView, cellIndex: cellIndex - 1, animated: animated)
        }
    }
    
    func scrollRandom (collectionView: UICollectionView, animated: Bool = false) {
        
        let cellCount = collectionView.numberOfItems(inSection: 0)
        
        let randomIndex = Int.random(in: 0...(cellCount - 1))
        
        scrollToCell(collectionView: collectionView, cellIndex: randomIndex, animated: animated)
        
    }
    
    //trigger delegate functions on manual scrolling
    //does programatic scrolling trigger delegate too?
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //user manually scrolled the flash card, this will trigger when the scroll stops
        
        delegate?.CVCellChanged(cellIndex: getCellIndex(collectionView: scrollView as! UICollectionView))
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //to detect page changes while the user is dragging without stopping the scroll
        
        delegate?.CVCellDragging(cellIndex: getCellIndex(collectionView: scrollView as! UICollectionView))
        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //called when you programatically scroll the screen
        
        delegate?.CVCellChanged(cellIndex: getCellIndex(collectionView: scrollView as! UICollectionView))
    }
    
    func scrollToTop (collectionView: UICollectionView) {
        
        scrollToCell(collectionView: collectionView, cellIndex: 0, animated: false)
        
    }
}

