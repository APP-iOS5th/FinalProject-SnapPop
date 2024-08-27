//
//  DonutChartViewController.swift
//  SnapPop
//
//  Created by 김형준 on 8/14/24.
//

import UIKit

class IsDonePercentageChart: UIViewController {
    // MARK: - Properties
    private var circularView: IsDoneDoughnut!
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupViews()
        setupConstraints()
        updateChart(withPercentage: 50)
    }
    
    // MARK: - Setup
    private func setupViews() {
        circularView = IsDoneDoughnut(percentages: [50, 50])
        circularView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(monthLabel)
        view.addSubview(circularView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            monthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            
            circularView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: -20),
            circularView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circularView.widthAnchor.constraint(equalToConstant: 250),
            circularView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    // MARK: - Public Methods
    func updateMonthLabel(month: Int, year: Int) {
        monthLabel.text = "\(month)월"
    }
    
    func updateChart(withPercentage percentage: Double) {
        circularView.updatePercentages(isDone: percentage)
    }
}



open class IsDoneDoughnut: UIView {
    
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
    
    lazy var percentageColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private let percentageLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
    
    // MARK: - Private Variables
    private var _percentages: [Double]
    private var _colors: [UIColor] = [.red, .lightGray]
    private var _lineWidth = CGFloat(5.0)
    lazy var donePercentage = "\(Float(_percentages[0]))%" {
        didSet {
            setNeedsDisplay()
        }
    }
    // MARK: - Initialization
    public init(percentages: [Double], lineWidth: CGFloat = 5.0) {
            self._percentages = percentages
            super.init(frame: CGRect.zero)
            self.backgroundColor = .clear
            self.clipsToBounds = false
            setupLabel()
        }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateColor() {

        guard let firstPercentage = _percentages.first else {
            percentageColor = dynamicColor(light: .black, dark: .white)
            return
        }
        
        switch firstPercentage {
        case 0.00...30.00:
            percentageColor = .red
        case 30.01...50.00:
            percentageColor = .orange
        case 50.01...70.00:
            percentageColor = dynamicColor(light: .black, dark: .white)
        case 70.01...85.00:
            percentageColor = .green
        case 85.01...100.00:
            percentageColor = .blue
        default:
            percentageColor = dynamicColor(light: .black, dark: .white)
        }
        updateLabel() // 색상이 변경될 때 레이블도 업데이트

    }
    
    private func setupLabel() {
            addSubview(percentageLabel)
            NSLayoutConstraint.activate([
                percentageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                percentageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
    
    // MARK: - Drawing
    override public func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2 - _lineWidth / 2
        let innerRadius = outerRadius * 0.70 // Adjust the multiplier as needed for the size of the hole
        
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
            
//            let attributes: [NSAttributedString.Key: Any] = [
//                .font: UIFont.boldSystemFont(ofSize: 20),
//                .foregroundColor: percentageColor
//            ]
//            let textSize = donePercentage.size(withAttributes: attributes)
//            let textRect = CGRect(
//                x: rect.midX - textSize.width / 2,
//                y: rect.midY - textSize.height / 2,
//                width: textSize.width,
//                height: textSize.height
//            )
//            donePercentage.draw(in: textRect, withAttributes: attributes)
                
        }
    }
    public func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        }
    public func updatePercentages(isDone: Double) {
            self._percentages = [isDone, 100 - isDone]
            self.donePercentage = String(format: "%.1f%%", isDone)
            updateColor()
            updateLabel()
            setNeedsDisplay()
        }
    
    private func updateLabel() {
            percentageLabel.text = donePercentage
            percentageLabel.textColor = percentageColor
        }

}

//달성률 함수 예시
//func calculateCompletionRate(schedule: Schedule, year: Int, month: Int) -> Double {
//    let calendar = Calendar.current
//    guard let startOfMonth = calendar.date(from: DateComponents(year: year, month: month)),
//          let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
//        return 0
//    }
//    
//    var totalDays = 0
//    var completedDays = 0
//    
//    calendar.enumerateDates(startingAfter: startOfMonth, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) { date, _, stop in
//        guard let date = date, date <= endOfMonth else {
//            stop = true
//            return
//        }
//        
//        if isScheduleOccurringOn(date: date, schedule: schedule) {
//            totalDays += 1
//            if let completion = getCompletion(scheduleId: schedule.id, date: date), completion.isCompleted {
//                completedDays += 1
//            }
//        }
//    }
//    
//    return totalDays > 0 ? Double(completedDays) / Double(totalDays) : 0
//}
