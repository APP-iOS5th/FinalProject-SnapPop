//
//  UICalendarView+Extensions.swift
//  SnapPop
//
//  Created by 김형준 on 8/31/24.
//

import UIKit

extension UICalendarView.Decoration {
    static var bottomDash: UICalendarView.Decoration {
        .customView {
            let view = UIView()
            view.backgroundColor = .clear
            
            let dashLayer = CAShapeLayer()
            dashLayer.strokeColor = UIColor.gray.cgColor
            dashLayer.lineWidth = 1
            dashLayer.lineDashPattern = [2, 2] // 점선 패턴
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: view.bounds.maxY))
            path.addLine(to: CGPoint(x: view.bounds.maxX, y: view.bounds.maxY))
            
            dashLayer.path = path.cgPath
            
            view.layer.addSublayer(dashLayer)
            
            return view
        }
    }
}
