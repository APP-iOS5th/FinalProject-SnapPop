////
////  CostChart.swift
////  SnapPop
////
////  Created by 김형준 on 8/20/24.
////
import UIKit
import DGCharts

// 차트 항목을 위한 구조체
struct ChartItem {
    let name: String
    let value: Int
    let color: UIColor
}

class CostChartViewController: UIViewController, ChartViewDelegate {
    
    // MARK: - Properties
    private var pieChartView: PieChartView!
    private var chartData: [ChartItem] = []
    private var totalCost: Int = 0
    
    private let noDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "M"
        return df
    }()
    
    private let totalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("총액", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateMonthLabel()
        
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        setupPieChartView()
        setupMonthLabel()
        setupTotalButton()
        view.addSubview(noDataLabel)
        
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noDataLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noDataLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            monthLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 60),
            
            totalButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            totalButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -60),
            
            pieChartView.topAnchor.constraint(equalTo: monthLabel.topAnchor, constant: 10),
            pieChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pieChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pieChartView.heightAnchor.constraint(equalTo: pieChartView.widthAnchor)
        ])
    }
    
    private func setupPieChartView() {
        pieChartView = PieChartView()
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pieChartView)
        
        pieChartView.delegate = self
        pieChartView.chartDescription.enabled = false
        pieChartView.drawHoleEnabled = true
        pieChartView.holeColor = .clear
        pieChartView.holeRadiusPercent = 0.5
        pieChartView.drawCenterTextEnabled = true
        pieChartView.rotationAngle = 0
        pieChartView.rotationEnabled = false
        pieChartView.highlightPerTapEnabled = true
        pieChartView.legend.enabled = false
        pieChartView.drawEntryLabelsEnabled = true
        pieChartView.entryLabelColor = .black
        pieChartView.entryLabelFont = .systemFont(ofSize: 12)
    }
    
    private func setupMonthLabel() {
        view.addSubview(monthLabel)
    }
    
    private func setupTotalButton() {
        view.addSubview(totalButton)
        totalButton.addTarget(self, action: #selector(totalButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Data Update
    func updateChartData(_ newData: [ChartItem]) {
        chartData = newData
        totalCost = newData.reduce(0) { $0 + $1.value }
        if newData.isEmpty {
            showNoDataMessage("해당 월의 비용 데이터가 없습니다.")
        } else {
            hideNoDataMessage()
            let entries = newData.enumerated().map { (index, item) in
                let entry = PieChartDataEntry(value: Double(item.value), label: item.name)
                entry.data = index
                return entry
            }
            
            let dataSet = PieChartDataSet(entries: entries, label: "")
            dataSet.colors = newData.map { $0.color }
            dataSet.sliceSpace = 2
            dataSet.selectionShift = 5
            dataSet.valueLinePart1OffsetPercentage = 0.8
            dataSet.valueLinePart1Length = 0.2
            dataSet.valueLinePart2Length = 0.4
            dataSet.valueTextColor = .clear // Hide value labels
            
            let data = PieChartData(dataSet: dataSet)
            pieChartView.data = data
            
            updateCenterText()
            pieChartView.notifyDataSetChanged()                }
        
    }
    
    private func updateCenterText() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let centerText = NSMutableAttributedString(string: "총액\n", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.dynamicTextColor
        ])
        centerText.append(NSAttributedString(string: formatCurrency(totalCost), attributes: [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.dynamicTextColor
        ]))
        
        pieChartView.centerAttributedText = centerText
    }
    
    // MARK: - Helper Methods
    private func formatCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return (formatter.string(from: NSNumber(value: value)) ?? "\(value)") + "원"
    }
    
    func updateMonthLabel() {
        let current = Date()
        monthLabel.text = "\(formatter.string(from: current))월"
    }
    
    func updateMonthLabel(month: Int, year: Int) {
        monthLabel.text = "\(month)월"
    }
    
    func showNoDataMessage(_ message: String) {
        pieChartView.isHidden = true
        noDataLabel.text = message
        noDataLabel.isHidden = false
        totalButton.isEnabled = false
    }
    
    func hideNoDataMessage() {
        pieChartView.isHidden = false
        noDataLabel.isHidden = true
        totalButton.isEnabled = true
    }
    
}

// MARK: - ChartViewDelegate
extension CostChartViewController {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let pieChartView = chartView as? PieChartView,
              let dataSet = pieChartView.data?.dataSets[highlight.dataSetIndex] as? PieChartDataSet,
              let index = entry.data as? Int,
              index < chartData.count else { return }
        
        let selectedItem = chartData[index]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let centerText = NSMutableAttributedString(string: "\(selectedItem.name)\n", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.dynamicTextColor
        ])
        centerText.append(NSAttributedString(string: formatCurrency(selectedItem.value), attributes: [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: selectedItem.color,
            .paragraphStyle: paragraphStyle,
        ]))
        
        pieChartView.centerAttributedText = centerText
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        updateCenterText()
    }
    @objc private func totalButtonTapped() {
        updateCenterText()
        pieChartView.highlightValue(nil, callDelegate: false)
    }
}
