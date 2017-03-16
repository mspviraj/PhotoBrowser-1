//
//  PBCustomView.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/3/16.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

private let statusBarHeight = 20
private let waitingViewMargin: CGFloat = 10.0

class WaitingView: UIView {
    
    var logoView: UIImageView!
    var progress: CGFloat = 0 {
        
        willSet {
            if newValue > 1 {
                removeFromSuperview()
            }
        }
        
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        clipsToBounds = true
        
        let image = cacheCustomLogoImage()
        
        logoView = UIImageView.init(image: image)
        logoView.center = center
        addSubview(logoView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let currentContext = UIGraphicsGetCurrentContext()
        let centerX = rect.size.width / 2
        let centerY = rect.size.height / 2
        let center = CGPoint(x: centerX, y: centerY)
        
        UIColor.white.set()
        currentContext?.setLineWidth(2)
        currentContext?.setLineCap(CGLineCap.round)
        let end = CGFloat( -M_PI_2 + Double(progress) * M_PI * 2 + 0.05)
        let radius = min(rect.size.width, rect.size.height) / 2 - waitingViewMargin
        currentContext?.addArc(center: center, radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: end, clockwise: false)
        currentContext?.strokePath()
    }
    
    fileprivate func cacheCustomLogoImage() -> UIImage? {
        let cachesURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0]
        let fileURL = cachesURL.appendingPathComponent(customLogoURL)
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        } else {
            return UIImage.init(named: "icon-logo-white", in: Bundle.init(for: classForCoder), compatibleWith: nil)
        }
    }
    
}

class PBNavigationBar: UIView {

    var isFromPhotoPicker: Bool = false
    var imageSelected: Bool = false {
        didSet {
            if isFromPhotoPicker {
                let unselectedImage = UIImage(named: "checkmark_unselected", in: Bundle(for: classForCoder), compatibleWith: nil)
                let image = self.imageSelected ? self.cacheCustomCheckSelectedImage() : unselectedImage
                rightButton.setImage(image, for: .normal)
            }
        }
    }
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self.leftButton)
        view.addSubview(self.rightButton)
        view.addSubview(self.titleLabel)
        view.addSubview(self.indexLabel)
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self.rightButton, attribute: .centerY, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self.leftButton, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self.leftButton, attribute: .leading, multiplier: 1.0, constant: -8))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self.rightButton, attribute: .trailing, multiplier: 1.0, constant: 8))
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.titleLabel, attribute: .top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self.titleLabel, attribute: .centerX, multiplier: 1.0, constant: 0))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-60-[titleLabel]-60-|", options: [], metrics: nil, views: ["titleLabel": self.titleLabel]))
        
        view.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .bottom, relatedBy: .equal, toItem: self.indexLabel, attribute: .top, multiplier: 1.0, constant: -3))
        view.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self.indexLabel, attribute: .centerX, multiplier: 1.0, constant: 0))
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.text = "Index"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var leftButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "icon-cross", in: Bundle(for: classForCoder()), compatibleWith: nil)
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
        return button
    }()

    lazy var rightButton: UIButton = {
        let button = UIButton()
        var image = UIImage(named: "icon-share", in: Bundle(for: classForCoder()), compatibleWith: nil)
        if self.isFromPhotoPicker {
            let unselectedImage = UIImage(named: "checkmark_unselected", in: Bundle(for: classForCoder()), compatibleWith: nil)
            image = self.imageSelected ? self.cacheCustomCheckSelectedImage() : unselectedImage
        }
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
        return button
    }()

    var backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        addSubview(backgroundView)
        backgroundView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[contentView]-0-|", options: [], metrics: nil, views: ["contentView": contentView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-statusBarHeight-[contentView]-0-|", options: [], metrics: ["statusBarHeight":statusBarHeight], views: ["contentView": contentView]))
    }

    fileprivate func cacheCustomCheckSelectedImage() -> UIImage? {
        let cachesURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0]
        let fileURL = cachesURL.appendingPathComponent(customCheckSelectedURL)
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        } else {
            return UIImage(named: "checkmark_selected", in: Bundle(for: classForCoder), compatibleWith: nil)
        }
    }
}

open class PBToolbar: UIToolbar {
    
    var backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        clipsToBounds = true
        addSubview(backgroundView)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class GradientView: UIView {
    
    var colors: [AnyObject]? {
        get {
            return (layer as! CAGradientLayer).colors as [AnyObject]?
        }
        set {
            (layer as! CAGradientLayer).colors = newValue
        }
    }
    
    var startPoint: CGPoint {
        get {
            return (layer as! CAGradientLayer).startPoint
        }
        set {
            (layer as! CAGradientLayer).startPoint = newValue
        }
    }
    
    var endPoint: CGPoint {
        get {
            return (layer as! CAGradientLayer).endPoint
        }
        set {
            (layer as! CAGradientLayer).endPoint = newValue
        }
    }
    
    override class var layerClass : AnyClass {
        return CAGradientLayer.self
    }
}
