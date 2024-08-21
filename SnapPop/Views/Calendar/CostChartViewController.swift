//
//  CostChart.swift
//  SnapPop
//
//  Created by 김형준 on 8/20/24.
//

import UIKit

class CostChart: UIViewController {
    
    // MARK: - Properties
    
    var circularView: CostDoughnut!
    
    var formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "M"
        return df
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupCircularView()
        setupMonthLabel()
    }
    
    // MARK: - Setup Circular View
    
    private func setupCircularView() {
        let percentages: [Double] = [25, 25, 25, 15, 10] // Example data percentages
        let colors: [UIColor] = [.red, .green, .blue, .orange, .systemYellow] // Example colors
        
        // Initialize Doughnut Chart view
        circularView = CostDoughnut(percentages: percentages, colors: colors, totalCost: "20000000원")
        circularView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add Doughnut Chart view to the main view
        view.addSubview(circularView)
        view.addSubview(monthLabel)
        
        // Setup constraints for Doughnut Chart view
        NSLayoutConstraint.activate([
            
            monthLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            monthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            
            circularView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: -20),
            circularView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circularView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circularView.widthAnchor.constraint(equalToConstant: 250),
            circularView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    func setupMonthLabel() {
        let current = Date()
        monthLabel.text = "\(formatter.string(from: current))월"
    }
    func updateMonthLabel(month: Int, year: Int) {
        monthLabel.text = "\(month)월"
    }
}

open class CostDoughnut: UIView {
    
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
    
    public var costColor: UIColor = .lightGray {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: - Private Variables
    private var _percentages: [Double]
    private var _colors: [UIColor]
    private var _lineWidth = CGFloat(5.0)
    private var centerText: String = "Total"
    private var totalCost: String
    
    // MARK: - Initialization
    public init(percentages: [Double], colors: [UIColor], totalCost: String) {
        self._percentages = percentages
        self._colors = colors
        self.totalCost = totalCost
        super.init(frame: CGRect.zero)
        self.backgroundColor = .clear
        self.clipsToBounds = false
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateProperties(percentages: [Double], colors: [UIColor], totalCost: String) {
        self._percentages = percentages
        self._colors = colors
        self.totalCost = totalCost
        setNeedsDisplay()
        }
    
    // MARK: - Drawing
    override public func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2 - _lineWidth / 2
        let innerRadius = outerRadius * 0.70
        
        drawPieChart(center: center, outerRadius: outerRadius, innerRadius: innerRadius)
        drawCenterText(in: rect, innerRadius: innerRadius)
    }

    private func drawPieChart(center: CGPoint, outerRadius: CGFloat, innerRadius: CGFloat) {
        var startAngle: CGFloat = -CGFloat.pi / 2
        
        for i in 0..<_percentages.count {
            let endAngle = startAngle + CGFloat(_percentages[i] / 100.0) * 2 * CGFloat.pi
            
            let path = createPiePath(center: center, outerRadius: outerRadius, innerRadius: innerRadius, startAngle: startAngle, endAngle: endAngle)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = _colors[i].cgColor
            shapeLayer.path = path.cgPath
            layer.addSublayer(shapeLayer)
            
            startAngle = endAngle
        }
    }

    private func createPiePath(center: CGPoint, outerRadius: CGFloat, innerRadius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: center.x + outerRadius * cos(startAngle), y: center.y + outerRadius * sin(startAngle)))
        path.addArc(withCenter: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.addLine(to: CGPoint(x: center.x + innerRadius * cos(endAngle), y: center.y + innerRadius * sin(endAngle)))
        path.addArc(withCenter: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
        path.close()
        return path
    }

    private func drawCenterText(in rect: CGRect, innerRadius: CGFloat) {
        let maxWidth = innerRadius * 2 * 0.9  // 내부 원 지름의 90%를 최대 너비로 사용
        let maxHeight = innerRadius * 0.8  // 내부 원 반지름의 80%를 최대 높이로 사용

        let totalCostAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: costColor
        ]
        let centerTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        
        // centerText 위치 계산
        let centerTextSize = centerText.size(withAttributes: centerTextAttributes)
        let centerTextRect = CGRect(
            x: rect.midX - min(centerTextSize.width, maxWidth) / 2,
            y: rect.midY - maxHeight / 2 - 8,  // 약간 위로 조정
            width: min(centerTextSize.width, maxWidth),
            height: min(centerTextSize.height, maxHeight / 2)
        )
        
        // totalCost 위치 계산
        let totalCostSize = totalCost.size(withAttributes: totalCostAttributes)
        let totalCostRect = CGRect(
            x: rect.midX - min(totalCostSize.width, maxWidth) / 2,
            y: rect.midY + 4,  // 약간 아래로 조정
            width: min(totalCostSize.width, maxWidth),
            height: min(totalCostSize.height, maxHeight / 2)
        )
        
        // 텍스트 그리기
        centerText.draw(in: centerTextRect, withAttributes: centerTextAttributes)
        totalCost.draw(in: totalCostRect, withAttributes: totalCostAttributes)
    }
    
    class EachCostCell: UICollectionViewCell {
        private let colorIndicator = UIView()
        private let nameLabel = UILabel()
        private let costLabel = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            // 기존의 setupViews 코드를 여기에 구현
            // contentView에 subview들을 추가합니다.
        }
        
        func configure(color: UIColor, name: String, cost: String) {
            colorIndicator.backgroundColor = color
            colorIndicator.layer.cornerRadius = 6
            nameLabel.text = name
            costLabel.text = cost
        }
    }
        
}
