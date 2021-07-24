//
//  CircularBar.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/29/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit
/**
 Will create a circular bar at based on the center of the UIView and radius will be 1/2 of width
 */


class CircularBar {
        
    let barLayer = CAShapeLayer()
    
    init (referenceView view: UIView, foregroundColor: CGColor, backgroundColor: CGColor, fillColor: CGColor, lineWidth: CGFloat) {
        
        //calculate center as the center will be center of referenceView
        
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        let radius = view.bounds.midX
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi/2, endAngle: 2 * CGFloat.pi - CGFloat.pi/2, clockwise: true)
        
        
        barLayer.fillColor = UIColor.clear.cgColor
        barLayer.strokeColor = foregroundColor
        barLayer.lineWidth = lineWidth
       //barLayer.lineCap = .round
        barLayer.path = circularPath.cgPath
        
        
        let backLayer = CAShapeLayer()
        backLayer.fillColor = UIColor.clear.cgColor
        backLayer.fillColor = fillColor
        backLayer.strokeColor = backgroundColor
        backLayer.lineWidth = lineWidth
       // backLayer.lineCap = .round
        backLayer.path = circularPath.cgPath
        
        
        //clear the background color of the view
        view.backgroundColor = UIColor.clear
        
        view.layer.addSublayer(backLayer)
        view.layer.addSublayer(barLayer)
        
        barLayer.strokeEnd = 0.0
        
    }
    
    /**
     Sets the end of the stroke
     *values*
     'strokeEnd' value 0.0 to 1.0
     */
    func setStokeEnd (strokeEnd: CGFloat) {
		
		// set a minimum value for strokeEnt as tiny values like 0.1% are too hard to see, and I think it
		// would be best to see even tiny values
		
		let minValue = CGFloat(0.02)
		var drawValue : CGFloat
		
		if strokeEnd == 0 {
			drawValue = 0
		} else if (strokeEnd < minValue){
			drawValue = minValue
		} else {
			drawValue = strokeEnd
		}
		
        barLayer.strokeEnd = drawValue
        
    }
    
    func setStrokeEnd (partialCount: Int, totalCount: Int) {
        
        let strokeEnd = Float(partialCount)/Float(totalCount)
        
        setStokeEnd(strokeEnd: CGFloat(strokeEnd))
    }

}
