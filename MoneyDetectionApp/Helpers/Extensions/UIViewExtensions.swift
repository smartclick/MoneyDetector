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

    func addBlurEffect() {
        removeBlurEffect()
        clipsToBounds = true
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.alpha = 0.9
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
