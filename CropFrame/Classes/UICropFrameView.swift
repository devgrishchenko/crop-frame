//
//  dragFrame.swift
//  frame
//
//  Created by Igor Grishchenko on 2018-05-14.
//  Copyright © 2018 Igor Grishchenko. All rights reserved.
//

import UIKit


@IBDesignable
public class UICropFrameView: UIView {
    
    // MARK: - Properties
    
    @IBInspectable var edges: Bool          = true
    @IBInspectable var sides: Bool          = true
    @IBInspectable var points: Bool         = true
    @IBInspectable var lines: Bool          = true
    @IBInspectable var border: Bool         = false
    @IBInspectable var shadow: Bool         = true
    
    @IBInspectable var resizeByCorner: Bool = true
    @IBInspectable var resizeByPinch: Bool  = true
    
    @IBInspectable var borderColor: UIColor = .gray
    @IBInspectable var edgesColor: UIColor  = .gray
    @IBInspectable var sidesColor: UIColor  = .gray
    @IBInspectable var pointsColor: UIColor = .gray
    @IBInspectable var linesColor: UIColor  = .gray
    
    @IBInspectable var borderWidth: CGFloat = 5 {
        
        didSet {
            
            if self.borderWidth > 10 {
                
                self.borderWidth = 10
            }
            else if self.borderWidth < 0 {
                
                self.borderWidth = 0
            }
        }
    }
    @IBInspectable var linesWidth: CGFloat  = 0.5 {
        
        didSet {
            
            if self.linesWidth > 5 {
                
                self.linesWidth = 5
            }
            else if self.linesWidth < 0 {
                
                self.linesWidth = 0
            }
        }
    }
    @IBInspectable var shadowAlpha: CGFloat = 0.5 {
        
        didSet {
            
            if self.shadowAlpha > 1 {
                
                self.shadowAlpha = 1
            }
            else if self.shadowAlpha < 0 {
                
                self.shadowAlpha = 0
            }
        }
    }
    
    
    private var initialTouchPosition: CGPoint?
    private var resizing: Bool!
    private var frameShadow: UICropFrameShadow?
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.config()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.config()
    }
    
    
    override public func draw(_ rect: CGRect) {
        
        if self.edges {self.drawEdges(in: rect)}
        if self.points {self.drawPoints(in: rect)}
        if self.lines {self.drawLines(in: rect)}
        if self.sides {self.drawSides(in: rect)}
        if self.border {self.drawBorder(in: rect)}
    }
    
    
    override public func layoutSubviews() {
        
        self.backgroundColor = .clear
        
        if self.shadow {
            
            //: Init and add only one instance of the shadow
            if let _ = self.frameShadow {return}
            self.frameShadow = UICropFrameShadow(self.shadowAlpha)
            self.addSubview(frameShadow!)
        }
    }
    
    
    private func config() {
        
        self.resizing = false
        self.backgroundColor = .clear
        
        if self.resizeByPinch {
            
            self.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.resizeByPinch(_:))))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangedOrientation(_:)), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    
    @objc
    private func didChangedOrientation(_ sender: AnyObject) {
        
        //: Swipes x & y and width & height to adjust frame for the orientation
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            
            self.frame = CGRect(x: self.frame.minY, y: self.frame.minX, width: self.frame.height, height: self.frame.width)
        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            
            self.frame = CGRect(x: self.frame.minY, y: self.frame.minX, width: self.frame.height, height: self.frame.width)
        }
        
        //: Redraw
        self.setNeedsDisplay()
        self.frameShadow?.frame = CGRect(x: 0 - self.frame.minX, y: 0 - self.frame.minY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.frameShadow?.setNeedsDisplay()
    }
}


// MARK: - Drag & Resize

extension UICropFrameView {
    
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        //: Init initial touch location
        if #available(iOS 9.1, *) {
            
            self.initialTouchPosition = touches.first?.preciseLocation(in: self)
        }
        else {
            
            self.initialTouchPosition = touches.first?.location(in: self)
        }
    }
    
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let touch = touches.first {
            
            if self.resizeByCorner {
                
                //: User finger's current point
                let currentPoint = touch.location(in: self)
                
                //: User is able to resize frame if he drags the corner
                if currentPoint.x > self.frame.width - 20 && currentPoint.y > self.frame.height - 20 {
                    
                    //: Resizing the frame
                    self.resizing = true
                    
                    UIView.animate(withDuration: 0.01) {
                        
                        //: Sets the minimum possible width and height
                        let width = max(currentPoint.x, 100)
                        let height = max(currentPoint.y, 100)
                        
                        self.frame = CGRect(x: self.frame.minX,
                                            y: self.frame.minY,
                                            width: width,
                                            height: height)
                    }
                }
                else {
                    
                    //: Should check if the frame is not resizing, otherwise, it will interrupt the resizing method
                    if !self.resizing {
                        
                        self.modifyBased(on: touch.location(in: self.superview))
                    }
                }
            }
            else {
                
                self.modifyBased(on: touch.location(in: self.superview))
            }
        }
        
        self.setNeedsDisplay()
        self.frameShadow?.setNeedsDisplay()
    }
    
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        //: Deinit initial touch location
        self.initialTouchPosition = nil
        self.resizing = false
    }
    
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        self.resizing = false
    }
    
    
    @objc
    private func resizeByPinch(_ sender: UIPinchGestureRecognizer) {
        
        if let view = sender.view {
            
            //: Scales the frame
            self.bounds = self.bounds.applying(view.transform.scaledBy(x: sender.scale, y: sender.scale))
            sender.scale = 1
            
            //: Sets the min size the user is able to scale to
            let width = min(max(view.frame.width, 100), (self.superview?.frame.width)!)
            let height = min(max(view.frame.height, 100), (self.superview?.frame.height)!)
            
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: width, height: height)
            
            self.modifyBased(on: sender.location(in: self.superview))
        }
        
        self.setNeedsDisplay()
        self.frameShadow?.setNeedsDisplay()
    }
    
    
    private func modifyBased(on location: CGPoint) {
        
        guard let localTouchPosition = self.initialTouchPosition else {return}
        
        var x: CGFloat = location.x - localTouchPosition.x
        var y: CGFloat = location.y - localTouchPosition.y
        
        //: Sets the min x & y in order not to go off the screen
        x = min(max(0, x), (self.superview?.frame.size.width)! - self.frame.width)
        y = min(max(0, y), (self.superview?.frame.size.height)! - self.frame.height)
        
        self.frame.origin = CGPoint(x: x, y: y)
    }
}


// MARK: - Drawing elements

extension UICropFrameView {
    
    
    private func drawSides(in rect: CGRect) {
        
        var direction = (x: CGFloat(0.0), y: CGFloat(0.0))
        let sides = [CGPoint(x: rect.minX, y: rect.midY),
                     CGPoint(x: rect.maxX, y: rect.midY),
                     CGPoint(x: rect.midX, y: rect.minY),
                     CGPoint(x: rect.midX, y: rect.maxY)]
        
        for i in 0 ..< sides.count {
            
            switch i {
            case 0...1:
                direction.x = 0
                direction.y = 5
            case 2...3:
                direction.x = 5
                direction.y = 0
            default:
                break
            }
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: sides[i].x - direction.x, y: sides[i].y - direction.y))
            path.addLine(to: CGPoint(x: sides[i].x + direction.x * 2, y: sides[i].y + direction.y * 2))
            path.close()
            
            path.lineWidth = 5
            self.sidesColor.set()
            path.stroke()
        }
    }
    
    
    private func drawEdges(in rect: CGRect) {
        
        var sides = (x: CGFloat(0.0), y: CGFloat(0.0))
        var edges = [CGPoint(x: rect.minX, y: rect.minY),
                     CGPoint(x: rect.minX, y: rect.maxY),
                     CGPoint(x: rect.maxX, y: rect.minY)]
        
        //: Adds the last edge if the user removes the handle
        if !self.points {
            
            edges.append(CGPoint(x: rect.maxX, y: rect.maxY))
        }
        
        for i in 0 ..< edges.count {
            
            switch i {
            case 0:
                sides.x = 15
                sides.y = 15
            case 1:
                sides.x = 15
                sides.y = -15
            case 2:
                sides.x = -15
                sides.y = 15
            case 3:
                sides.x = -15
                sides.y = -15
            default:
                break
            }
            
            let path = UIBezierPath()
            
            path.move(to: CGPoint(x: edges[i].x + sides.x, y: edges[i].y))
            path.addLine(to: CGPoint(x: edges[i].x, y: edges[i].y))
            path.addLine(to: CGPoint(x: edges[i].x, y: edges[i].y + sides.y))
            path.addLine(to: CGPoint(x: edges[i].x, y: edges[i].y))
            
            path.close()
            
            path.lineWidth = 5
            self.edgesColor.set()
            path.stroke()
        }
    }
    
    
    private func drawPoints(in rect: CGRect) {
        
        //: Draws points for the handle
        var points = (x: CGFloat(0.0), y: CGFloat(0.0))
        
        for i in 0 ..< 7 {
            
            switch i {
            case 0:
                points.x = -2
                points.y = -2
            case 1:
                points.x = -8
                points.y = -2
            case 2:
                points.x = -14
                points.y = -2
            case 3:
                points.x = -2
                points.y = -8
            case 4:
                points.x = -2
                points.y = -14
            case 5:
                points.x = -14
                points.y = -2
            case 6:
                points.x = -8
                points.y = -8
            default:
                break
            }
            
            let circlePath = UIBezierPath(arcCenter:  CGPoint(x: rect.maxX + points.x, y: rect.maxY + points.y),
                                          radius: 2,
                                          startAngle: CGFloat(0),
                                          endAngle:CGFloat(Double.pi * 2),
                                          clockwise: true)
            
            circlePath.close()
            
            self.pointsColor.set()
            circlePath.fill()
        }
    }
    
    
    private func drawBorder(in rect: CGRect) {
        
        //: Draws frame's border
        let border = UIBezierPath()
        
        border.move(to: CGPoint(x: rect.minX, y: rect.minY))
        border.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        border.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        border.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        border.close()
        
        border.lineWidth = self.borderWidth
        self.borderColor.set()
        border.stroke()
    }
    
    
    private func drawLines(in rect: CGRect) {
        
        var xCoord = self.frame.width / 6
        var yCoord = self.frame.height / 6
        
        //: Lines from top to bottom
        for _ in 0 ..< 5 {
            
            let line = UIBezierPath()
            
            line.move(to: CGPoint(x: xCoord - 0.05, y: rect.minY))
            line.addLine(to: CGPoint(x: xCoord - 0.05, y: rect.maxY))
            
            line.close()
            
            line.lineWidth = self.linesWidth
            self.linesColor.set()
            line.stroke()
            
            xCoord += self.frame.width / 6
        }
        
        //: Lines from left to right
        for _ in 0 ..< 5 {
            
            let line = UIBezierPath()
            
            line.move(to: CGPoint(x: rect.minX, y: yCoord - 0.05))
            line.addLine(to: CGPoint(x: rect.maxX, y: yCoord - 0.05))
            
            line.close()
            
            line.lineWidth = self.linesWidth
            self.linesColor.set()
            line.stroke()
            
            yCoord += self.frame.height / 6
        }
    }
}


extension UICropFrameView {
    
    
    private func switchDrawings(_ initials: [Bool]? = nil) -> [Bool]? {
        
        //: Returns initial state of the drawings
        if let initials = initials {
            
            self.edges  = initials[0]
            self.sides  = initials[1]
            self.points = initials[2]
            self.lines  = initials[3]
            self.border = initials[4]
            
            self.setNeedsDisplay()
            
            return nil
        }
        else {
            
            //: Hides all the drawings
            let initialStates = [self.edges, self.sides, self.points, self.lines, self.border]
            
            self.edges  = false
            self.sides  = false
            self.points = false
            self.lines  = false
            self.border = false
            
            self.setNeedsDisplay()
            
            return initialStates
        }
    }
    
    
    public var crop: UIImage {
        
        get {
            
            let initials = self.switchDrawings()
            
            self.setNeedsDisplay()
            
            let image: UIImage = {
                
                if #available(iOS 10.0, *) {
                    
                    //: >= iOS 10
                    return UIGraphicsImageRenderer(size: (self.superview?.frame.size)!).image { _ in
                        
                        self.superview?.drawHierarchy(in: (self.superview?.frame)!, afterScreenUpdates: true)
                    }
                }
                else {
                    
                    //: < iOS 10
                    UIGraphicsBeginImageContextWithOptions((self.superview?.bounds.size)!, false, 0.0)
                    self.superview?.drawHierarchy(in: (self.superview?.bounds)!, afterScreenUpdates: true)
                    let image = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    return image!
                }
            }()
            
            //: Scales frame bounds by 2 and crops it from the image
            let imageRef = image.cgImage?.cropping(to: CGRect(x: self.frame.minX * 2, y: self.frame.minY * 2,
                                                              width: self.frame.width * 2, height: self.frame.height * 2))
            
            _ = self.switchDrawings(initials!)
            
            self.setNeedsDisplay()
            
            return UIImage(cgImage: imageRef!)
        }
    }
}


public class UICropFrameShadow: UIView {
    
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
