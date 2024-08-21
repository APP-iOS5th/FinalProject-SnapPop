//
//  CalendarViewController.swift
//  SnapPop
//
//  Created by 김형준 on 8/9/24.
//

import UIKit
import Foundation

class CalendarViewController: UIViewController {
    
    var dailymodels = DailyModel(todoList: ["밥먹기", "커피마시기"])
    var selectedDate: DateComponents?
    var multiDateSelection: UICalendarSelectionMultiDate!
    var categoryId = "0qihnS4CfWy45ooH7BSe"
    var hasSnapDates: Set<DateComponents> = []
    var managements: [Management] = []
    var sampledata = Management1.generateSampleManagementItems()
    private var snapService = SnapService()
    private var managementService = ManagementService()
    private var segmentedControlTopConstraint: NSLayoutConstraint?
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private var dashBarTopConstraint: NSLayoutConstraint?
    private var isDoneChart: IsDonePercentageChart!
    private var costChart: CostChart!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private let contentView: UIStackView = {
        let view = UIStackView()
        view.backgroundColor = .systemBackground
        view.axis = .vertical
        view.spacing = 20
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let firstStackViewView: UIStackView = {
        var stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.backgroundColor = .systemBackground
        stackView.layer.borderWidth = 0.7
        stackView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.layer.cornerRadius = 10
        stackView.clipsToBounds = true
        return stackView
    }()
    
    private let calendarView: UICalendarView = {
        var view = UICalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsDateDecorations = true
        view.tintColor = UIColor(red: 120/255, green: 200/255, blue: 200/255, alpha: 0.8)
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let tableView: UITableView = {
        var view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.backgroundColor = .systemBackground
        view.sectionIndexColor = UIColor.black
        view.register(TodoTableViewCell.self, forCellReuseIdentifier: "TodoCell")
        return view
    }()
    
    private let dashButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 94/255, green: 230/255, blue: 245/255, alpha: 0.2)
        button.translatesAutoresizingMaskIntoConstraints = false
        let dashText = "—"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .heavy),  // 폰트 크기와 두께 조절
            .foregroundColor: UIColor.lightGray  // 색상 설정
        ]
        let attributedString = NSAttributedString(string: dashText, attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()
    
    private let secondStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderWidth = 0.7
        stackView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.layer.cornerRadius = 10
        stackView.clipsToBounds = true
        return stackView
    }()
    
    private let segmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["달성률", "비용"])
        let font = UIFont.boldSystemFont(ofSize: 16)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor(red: 92/255, green: 223/255, blue: 231/255, alpha: 0.6)
        segmentedControl.layer.borderColor = UIColor.lightGray.cgColor
        segmentedControl.layer.borderWidth = 0.5
        return segmentedControl
    }()
    
    private let graphView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        calendarView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        calendarView.selectionBehavior = UICalendarSelectionMultiDate(delegate: self)
        scrollView.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        firstStackViewView.isUserInteractionEnabled = true
        secondStackView.isUserInteractionEnabled = true
        dashButton.isUserInteractionEnabled = true
        segmentedControl.isUserInteractionEnabled = true
        secondStackView.distribution = .equalCentering
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        segmentChange()
        updateSnapsForMonth()
        updateManegementData()
        
    }
    
    private func setupViews() {
        
        isDoneChart = IsDonePercentageChart()
        costChart = CostChart()
        addChild(isDoneChart)
        addChild(costChart)
        isDoneChart.view.frame = graphView.bounds
        costChart.view.frame = graphView.bounds
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addArrangedSubview(firstStackViewView)
        contentView.addArrangedSubview(secondStackView)
        firstStackViewView.addArrangedSubview(calendarView)
        firstStackViewView.addArrangedSubview(tableView)
        firstStackViewView.addArrangedSubview(dashButton)
        secondStackView.addArrangedSubview(segmentedControl)
        secondStackView.addArrangedSubview(graphView)
        graphView.addSubview(isDoneChart.view)
        graphView.addSubview(costChart.view)
    }
    
    private func setupConstraints() {
        setupScrollViewConstraints()
        setupFirstStackViewConstraints()
        setupCalendarViewConstraints()
        setupTableViewConstraints()
        setupdashButtonConstraints()
        setupSegmentedControlConstraints()
        setupsecondStackViewConstraints()
        setupgraphViewConstraints()
        setupContentViewConstraints()
        setupIsDoneChartViewConstraints()
        
    }
    
    private func setupScrollViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    private func setupContentViewConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.centerXAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func setupFirstStackViewConstraints() {
        NSLayoutConstraint.activate([
            firstStackViewView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 10),
            firstStackViewView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            firstStackViewView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    private func setupCalendarViewConstraints() {
        calendarView.locale = Locale(identifier: "ko_KR")
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: firstStackViewView.topAnchor, constant: -10),
            calendarView.leadingAnchor.constraint(equalTo: firstStackViewView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: firstStackViewView.trailingAnchor)          
        ])
    }
    
    private func setupTableViewConstraints() {
        tableViewHeightConstraint?.isActive = false
        
        let cellHeight: CGFloat = 44
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        let newHeight = CGFloat(numberOfRows) * cellHeight
        
        if tableView.isHidden {
            tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        } else {
            tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: newHeight)
        }
        
        tableViewHeightConstraint?.isActive = true
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -20),
            tableView.leadingAnchor.constraint(equalTo: firstStackViewView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: firstStackViewView.trailingAnchor),
            tableViewHeightConstraint!
        ])
    }
    private func setupdashButtonConstraints() {
        dashBarTopConstraint?.isActive = false
        if tableView.isHidden {
            dashBarTopConstraint = dashButton.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -30)
        } else {
            dashBarTopConstraint = dashButton.topAnchor.constraint(equalTo: tableView.bottomAnchor)
        }
        dashBarTopConstraint?.isActive = true
        NSLayoutConstraint.activate([
            dashBarTopConstraint!,
            dashButton.leadingAnchor.constraint(equalTo: firstStackViewView.leadingAnchor),
            dashButton.trailingAnchor.constraint(equalTo: firstStackViewView.trailingAnchor),
            dashButton.heightAnchor.constraint(equalToConstant: 17)
        ])
    }
    
    private func setupsecondStackViewConstraints() {
        NSLayoutConstraint.activate([
            secondStackView.topAnchor.constraint(equalTo: firstStackViewView.bottomAnchor, constant: 30),
            secondStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            secondStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            secondStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            secondStackView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    private func setupSegmentedControlConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: secondStackView.topAnchor),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalTo: secondStackView.widthAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupgraphViewConstraints() {
        NSLayoutConstraint.activate([
            graphView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 30),
            graphView.leadingAnchor.constraint(equalTo: secondStackView.leadingAnchor, constant: 5),
            graphView.trailingAnchor.constraint(equalTo: secondStackView.trailingAnchor, constant: -5)
        ])
    }
    
    private func setupIsDoneChartViewConstraints() {
        NSLayoutConstraint.activate([
            isDoneChart.view.topAnchor.constraint(equalTo: graphView.topAnchor),
            isDoneChart.view.leadingAnchor.constraint(equalTo: graphView.leadingAnchor, constant: 30),
            isDoneChart.view.trailingAnchor.constraint(equalTo: graphView.trailingAnchor, constant: -30)
        ])
    }
    
    private func setupCostChartViewConstraints() {
        NSLayoutConstraint.activate([
            costChart.view.topAnchor.constraint(equalTo: graphView.topAnchor),
            costChart.view.leadingAnchor.constraint(equalTo: graphView.leadingAnchor, constant: 30),
            costChart.view.trailingAnchor.constraint(equalTo: graphView.trailingAnchor, constant: -30)
        ])
    }
    
    @objc func segmentedControlValueChanged() {
        segmentChange()
    }
    
    private func segmentChange() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: // 달성률
            isDoneChart.view.isHidden = false
            costChart.view.isHidden = true
        case 1: // 비용
            isDoneChart.view.isHidden = true
            costChart.view.isHidden = false
        default:
            break
        }
    }
    
}

extension CalendarViewController: UICalendarViewDelegate, UICalendarSelectionMultiDateDelegate {
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
        selection.setSelectedDates([dateComponents], animated: true)
        selectedDate = dateComponents
        tableView.isHidden = false
        tableView.reloadData()
        setupConstraints()
    }
    
    func setupMultiSelection() {
        
    }
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
        selection.setSelectedDates([], animated: true)
        selectedDate = nil
        tableView.isHidden = true
        tableView.reloadData()
        setupConstraints()
        
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        var date = dateComponents.date
        if hasSnapDates.contains(dateComponents) {
            return .customView {
                let imageView = UIImageView()
                let originalImage = UIImage(named: "filledpop")
                let resizedImage = originalImage?.resized(to: CGSize(width: 16, height: 16))
                imageView.image = resizedImage
                return imageView
            }
        }
        
        else {return nil}
    }
    
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        guard let visibleMonth = calendarView.visibleDateComponents.month,
              let visibleYear = calendarView.visibleDateComponents.year else {
            return
        }
        updatMonthlyInfo(month: visibleMonth, year: visibleYear)
        updateSnapsForMonth()
    }
    
    func updatMonthlyInfo(month: Int, year: Int) {
        isDoneChart.updateMonthLabel(month: month, year: year)
        costChart.updateMonthLabel(month: month, year: year)
    }
    func updateSnapsForMonth() {
        
        guard let currentDate = calendarView.visibleDateComponents.date else { return }
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: currentDate)
            
            guard let year = components.year, let month = components.month else { return }
        
        snapService.loadSnapsForMonth(categoryId: categoryId, year: year, month: month) { [weak self] result in
            switch result {
            case .success(let snaps):
                self?.hasSnapDates = Set(snaps.compactMap { snap in
                    guard let date = snap.createdAt else { return nil }
                    return Calendar.current.dateComponents([.year, .month, .day], from: date)
                })
                DispatchQueue.main.async {
                    self?.calendarView.reloadDecorations(forDateComponents: Array(self?.hasSnapDates ?? []), animated: true)
                }
            case .failure(let error):
                print("Failed to load snaps: \(error)")
            }
            
        }
    }
    func updateManegementData() {
        managementService.loadManagements(categoryId: categoryId) { [weak self] result in
            switch result {
            case .success(let managements):
                self?.managements = managements
            case .failure(let error):
                print("Failed to load managements: \(error)")
            }
        }
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, sampledata.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as? TodoTableViewCell else {
            fatalError("Unable to dequeue CustomTableViewCell")
        }
        if sampledata.isEmpty {
            cell.label.text = "등록된 자기관리가 없습니다."
        } else {
            cell.label.text = sampledata[indexPath.row].title
        }
        cell.updateCheckbocState(isChecked: sampledata[indexPath.row].isDone)
        cell.checkboxButton.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
        cell.checkboxButton.tag = indexPath.row
        cell.checkboxButton.isSelected = sampledata[indexPath.row].isDone
        
        return cell
    }
    
    @objc func checkboxTapped(_ sender: UIButton) {
        let index = sender.tag
        sender.isSelected.toggle()
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TodoTableViewCell {
            cell.updateCheckbocState(isChecked: sampledata[index].isDone)
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
