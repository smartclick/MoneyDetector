//
//  PolygonView.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/11/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

class PolygonView: UIView {
    func addRectangleFromPoints(points: [CGPoint], fillColor: UIColor = .clear, strokeColor: UIColor = .clear, lineWidth: CGFloat = 2.4, smoothness: CGFloat = 0.0) {
        let path = createCurve(from: points, withSmoothness: smoothness)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = fillColor.withAlphaComponent(0.0).cgColor
        shapeLayer.strokeColor = strokeColor.withAlphaComponent(0.7).cgColor
        shapeLayer.lineWidth = lineWidth
        
        layer.addSublayer(shapeLayer)
    }
    
    /// Create UIBezierPath
    ///
    /// - Parameters:
    ///   - points: the points
    ///   - smoothness: the smoothness: 0 - no smooth at all, 1 - maximum smoothness
    private func createCurve(from points: [CGPoint], withSmoothness smoothness: CGFloat, addZeros: Bool = false) -> UIBezierPath {

        let path = UIBezierPath()
        guard points.count > 0 else { return path }
        var prevPoint: CGPoint = points.first!
        let interval = getXLineInterval()
        if addZeros {
            path.move(to: CGPoint(x: interval.origin.x, y: interval.origin.y))
            path.addLine(to: points[0])
        }
        else {
            path.move(to: points[0])
        }
        for i in 1..<points.count {
            let cp = controlPoints(p1: prevPoint, p2: points[i], smoothness: smoothness)
            path.addCurve(to: points[i], controlPoint1: cp.0, controlPoint2: cp.1)
            prevPoint = points[i]
        }
        if addZeros {
            path.addLine(to: CGPoint(x: prevPoint.x, y: interval.origin.y))
        }
        return path
    }

    /// Create control points with given smoothness
    ///
    /// - Parameters:
    ///   - p1: the first point
    ///   - p2: the second point
    ///   - smoothness: the smoothness: 0 - no smooth at all, 1 - maximum smoothness
    /// - Returns: two control points
    private func controlPoints(p1: CGPoint, p2: CGPoint, smoothness: CGFloat) -> (CGPoint, CGPoint) {
        let cp1: CGPoint!
        let cp2: CGPoint!
        let percent = min(1, max(0, smoothness))
        do {
            var cp = p2
            // Apply smoothness
            let x0 = max(p1.x, p2.x)
            let x1 = min(p1.x, p2.x)
            let x = x0 + (x1 - x0) * percent
            cp.x = x
            cp2 = cp
        }
        do {
            var cp = p1
            // Apply smoothness
            let x0 = min(p1.x, p2.x)
            let x1 = max(p1.x, p2.x)
            let x = x0 + (x1 - x0) * percent
            cp.x = x
            cp1 = cp
        }
        return (cp1, cp2)
    }

    /// Defines interval width, height (not used in this example) and coordinate of the first interval.
    /// - Returns: (x0, y0, step, height)
    internal func getXLineInterval() -> CGRect {
        return CGRect.zero
    }
}
