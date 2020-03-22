//
//  TestVCViewController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/19/20.
//  Copyright © 2020 Zaigham Tahir. All rights reserved.
//

import UIKit

class TestVCViewController: UIViewController {

    @IBOutlet weak var circleBarView: UIView!
     var progressBar: CircularBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        updateDisplay()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
           //redraw the progress bar
           updateDisplay()
       }
       
       override func viewWillAppear(_ animated: Bool) {
           
           //updateDisplay()
       }

    private func updateDisplay () {
           
           let foregroundColor = myTheme.colorLhPbForeground?.cgColor
           let backgroundColor = myTheme.colorLhPbBackground?.cgColor
           let fillColor =  myTheme.colorLhPbFill?.cgColor
       
           progressBar = CircularBar(referenceView: circleBarView, foregroundColor: foregroundColor!, backgroundColor: backgroundColor!, fillColor: fillColor!
               , lineWidth: 15)
       
           progressBar.setStrokeEnd(partialCount: 20, totalCount: 80)
    
   
    }
}
