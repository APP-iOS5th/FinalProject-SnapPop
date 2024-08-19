//
//  DonutChart.swift
//  SnapPop
//
//  Created by 김형준 on 8/19/24.
//

import UIKit

class DonutChartCircular: UIView {
    
    // MARK: - Public Properties
    public var lineWidth: CGFloat {
        get {
            return _lineWidth
        }
        set(newValue) {
            _lineWidth = newValue
            setNeedsDisplay()
        }
    }
    
    // MARK: - Private Variables
    private var _percentages: [Double]
    private var _colors: [UIColor]
    private var _lineWidth = CGFloat(10.0)
    
    // MARK: - Initialization
    public init(percentages: [Double], colors: [UIColor], lineWidth: CGFloat = 10.0) {
        self._percentages = percentages
        self._colors = colors
        self._lineWidth = lineWidth
        super.init(frame: CGRect.zero)
        self.backgroundColor = .clear
        self.clipsToBounds = false
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Drawing
    override public func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2 - _lineWidth / 2
        let innerRadius = outerRadius * 0.5 // Adjust the multiplier as needed for the size of the hole
        
        var startAngle: CGFloat = -CGFloat.pi / 2
        
        for i in 0..<_percentages.count {
            let endAngle = startAngle + CGFloat(_percentages[i] / 100.0) * 2 * CGFloat.pi
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: center.x + outerRadius * cos(startAngle), y: center.y + outerRadius * sin(startAngle)))
            path.addArc(withCenter: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.addLine(to: CGPoint(x: center.x + innerRadius * cos(endAngle), y: center.y + innerRadius * sin(endAngle)))
            path.addArc(withCenter: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
            path.close()
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = _colors[i].cgColor
            shapeLayer.path = path.cgPath
            layer.addSublayer(shapeLayer)
            
            startAngle = endAngle
        }
    }
}
