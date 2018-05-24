//
//  frameShadow.swift
//  frame
//
//  Created by Igor Grishchenko on 2018-05-14.
//  Copyright © 2018 Igor Grishchenko. All rights reserved.
//

import UIKit


public class UIFrameShadow: UIView {
    
    private var shadowAlpha: CGFloat!
    
    
    public init(_ shadowAlpha: CGFloat) {
        super.init(frame: CGRect())
        
        self.shadowAlpha = shadowAlpha
        self.backgroundColor = .clear
        self.frame = CGRect(x: 0 - self.frame.minX, y: 0 - self.frame.minY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override public func draw(_ rect: CGRect) {
        
        //: Updates shadow's frame
        self.frame = CGRect(x: -(self.superview?.frame.minX)!, y: -(self.superview?.frame.minY)!, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        //: Draws shadow around the frame. Superview is a frame
        let shadow = UIBezierPath()
        
        shadow.move(to: CGPoint(x: rect.minX, y: rect.minY))
        shadow.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        shadow.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        shadow.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        shadow.addLine(to: CGPoint(x: (self.superview?.frame.maxX)!, y: (self.superview?.frame.minY)!))
        shadow.addLine(to: CGPoint(x: (self.superview?.frame.maxX)!, y: (self.superview?.frame.maxY)!))
        shadow.addLine(to: CGPoint(x: (self.superview?.frame.minX)!, y: (self.superview?.frame.maxY)!))
        shadow.addLine(to: CGPoint(x: (self.superview?.frame.minX)!, y: (self.superview?.frame.minY)!))
        shadow.addLine(to: CGPoint(x: (self.superview?.frame.maxX)!, y: (self.superview?.frame.minY)!))
        shadow.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        shadow.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        
        shadow.close()
        
        shadow.lineWidth = 5
        UIColor.gray.set()
        shadow.fill(with: .normal, alpha: self.shadowAlpha)
    }
}
