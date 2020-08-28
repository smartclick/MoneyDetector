//
//  UIViewExtensions.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/10/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

extension UIView {
    func loadViewFromNib<T: UIView>(owner: T) -> UIView {
        let bundle = Bundle(for: type(of: owner))
        let nib = UINib(nibName: String(describing: type(of: owner)), bundle: bundle)
        let view = nib.instantiate(withOwner: owner, options: nil)[0] as? UIView
        return view ?? UIView()
    }

    func autopinToSuperviewEdges() {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self,
                           attribute: NSLayoutConstraint.Attribute.top,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: superview, attribute: NSLayoutConstraint.Attribute.top,
                           multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: NSLayoutConstraint.Attribute.leading,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: superview,
                           attribute: NSLayoutConstraint.Attribute.leading,
                           multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: NSLayoutConstraint.Attribute.trailing,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: superview, attribute: NSLayoutConstraint.Attribute.trailing,
                           multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: NSLayoutConstraint.Attribute.bottom,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: superview,
                           attribute: NSLayoutConstraint.Attribute.bottom,
                           multiplier: 1, constant: 0).isActive = true
    }

    func addBlurEffect(style: UIBlurEffect.Style = .dark) {
        removeBlurEffect()
        clipsToBounds = true
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.alpha = 1.0
        addSubview(blurEffectView)
        blurEffectView.autopinToSuperviewEdges()
        sendSubviewToBack(blurEffectView)
    }

    func removeBlurEffect() {
        let blurredEffectViews = self.subviews.filter {$0 is UIVisualEffectView}
        blurredEffectViews.forEach { blurView in
            blurView.removeFromSuperview()
        }
    }

    func dropShadow(offSet: CGSize, color: UIColor = .black, radius: CGFloat = 2, opacity: Float = 1.0) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
    }

    func dropCardShadow() {
        dropShadow(offSet: CGSize(width: 5, height: 5), color: .gray, radius: 10, opacity: 0.45)
    }

    func addShadowView(offSet: CGSize, color: UIColor, radius: CGFloat = 2, opacity: Float = 1.0, viewTag: Int = 99) {
        removeShadow(viewTag: viewTag)
        layer.masksToBounds = false
        let shadow = UIView(frame: bounds)
        shadow.isUserInteractionEnabled = false
        insertSubview(shadow, at: 0)
        shadow.autopinToSuperviewEdges()
        shadow.backgroundColor = backgroundColor
        shadow.layer.cornerRadius = layer.cornerRadius
        shadow.dropShadow(offSet: offSet, color: color, radius: radius, opacity: opacity)
        shadow.tag = viewTag
    }

    func addShadowView() {
        addShadowView(offSet: CGSize(width: 0, height: 2), color: .black, viewTag: 99)
    }

    func addShadow() {
        dropShadow(offSet: CGSize(width: 0, height: 0), color: .black, radius: 3, opacity: 0.1)
    }

    func removeShadow(viewTag: Int = 99) {
        viewWithTag(viewTag)?.removeFromSuperview()
    }
}

extension UIImage {
    func resizeImageWith(newSizeValue: CGFloat) -> UIImage? {
        var newWidth = newSizeValue
        var newHeight = newSizeValue
        if size.width > size.height {
            let scale = newWidth / size.width
            newHeight = size.height * scale
        } else {
            let scale = newHeight / size.height
            newWidth = size.width * scale
        }
        let newSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    class func imageWithView(_ view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0)
        defer { UIGraphicsEndImageContext() }
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIButton {
    func disableButton() {
        backgroundColor = .clear
        isEnabled = false
    }
}
