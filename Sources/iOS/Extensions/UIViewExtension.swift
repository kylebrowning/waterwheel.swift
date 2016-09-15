//
//  ViewExtension.swift
//  Pods
//
//  Created by Kyle Browning on 8/9/16.
//
//

import UIKit

@available(iOS 9.0, *)
extension UIView {
    public func constrainEqual(_ attribute: NSLayoutAttribute, to: AnyObject, multiplier: CGFloat = 1, constant: CGFloat = 0) {
        constrainEqual(attribute, to: to, attribute, multiplier: multiplier, constant: constant)
    }

    public func constrainEqual(_ attribute: NSLayoutAttribute, to: AnyObject, _ toAttribute: NSLayoutAttribute, multiplier: CGFloat = 1, constant: CGFloat = 0) {
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: to, attribute: toAttribute, multiplier: multiplier, constant: constant)
            ])
    }

    public func constrainEdges(to view: UIView) {
        constrainEqual(.top, to: view, .top)
        constrainEqual(.leading, to: view, .leading)
        constrainEqual(.trailing, to: view, .trailing)
        constrainEqual(.bottom, to: view, .bottom)
    }

    /// If the `view` is nil, we take the superview.
//    public func center(in view: UIView? = nil) {
//        guard let container = view ?? self.superview else { fatalError() }
////        centerXAnchor.constrainEqualS(acnhor: container.centerXAnchor)
////        centerYAnchor.constrainEqualS(acnhor: container.centerYAnchor)
//    }
}

//@available(iOS 9.0, *)
//extension NSLayoutAnchor {
//    public func constrainEqualS(acnhor anchor: NSLayoutAnchor, constant: CGFloat = 0) {
//        let constraint = self.constraint(equalTo: anchor, constant: constant)
//        constraint.isActive = true
//    }
//}
