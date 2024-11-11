//
//  CalendarViewController.swift
//  SnapPop
//
//  Created by 김형준 on 8/9/24.
//

import UIKit
import Foundation

class CalendarViewController: UIViewController {
 
    var selectedDateComponents: DateComponents?
    lazy var selectedDate = selectedDateComponents?.date ?? Date()
    var multiDateSelection: UICalendarSelectionMultiDate!
    var categoryId = ""
    var hasSnapDates: Set<DateComponents> = []
    var managements: [Management] = []
    private var detailCosts: [DetailCost] = []
    private var detailCostsCache: [String: [DetailCost]] = [:]
    private var matchingManagements: [Management] = []
    private var snapService = SnapService()
    private var managementService = ManagementService()
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private var fakeUnderBarTopConstraint: NSLayoutConstraint?
    private var isDoneChart: IsDonePercentageChart!
    private var costChart =  CostChartViewController()
    private let dateFormatter = DateFormatter()
    private var isDataLoaded = false
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.customBackgroundColor
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private let contentView: UIStackView = {
        let view = UIStackView()
        view.backgroundColor = UIColor.customBackgroundColor
        view.axis = .vertical
        view.spacing = 20
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let firstStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.backgroundColor = .dynamicBackgroundInsideColor
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
        view.tintColor = UIColor.customMainColor
        view.backgroundColor = .dynamicBackgroundInsideColor
        view.transform = CGAffineTransform(scaleX: 1.0, y: 0.93)
        return view
    }()
    
    private let tableView: UITableView = {
        var view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.backgroundColor = .dynamicBackgroundInsideColor
        view.sectionIndexColor = UIColor.black
        view.register(TodoTableViewCell.self, forCellReuseIdentifier: "TodoCell")
        view.layer.borderWidth = 0.16
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    private let calendarBar: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.customButtonColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let fakeUnderBar: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.dynamicBackgroundInsideColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let secondStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderWidth = 0.7
        stackView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.layer.cornerRadius = 10
        stackView.clipsToBounds = true
        stackView.backgroundColor = .dynamicBackgroundInsideColor
        return stackView
    }()
    
    private let segmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["달성률", "비용"])
        let font = UIFont.boldSystemFont(ofSize: 16	)
        let color = UIColor.white

        UISegmentedControl.appearance().setTitleTextAttributes([
            .font: font,
            .foregroundColor: color
        ], for: .selected)

        UISegmentedControl.appearance().setTitleTextAttributes([
            .font: font,
            .foregroundColor: color
        ], for: .normal)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = UIColor(named: "segmentSelected")
        segmentedControl.backgroundColor = UIColor.customMain
        segmentedControl.layer.borderColor = UIColor.lightGray.cgColor
        segmentedControl.layer.borderWidth = 0.5
        return segmentedControl
    }()
    
    struct ChartDataItem {
        let name: String
        let value: Int
        let color: String
        let managementId: String
    }
    
    private let graphView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let categoryId = UserDefaults.standard.string(forKey: "currentCategoryId") {
            self.categoryId = categoryId
            refreshAllData()
            tableView.isHidden = true
            setupFakeUnderBarConstraints()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(categoryDidChange(_:)), name: .categoryDidChange, object: nil)
        calendarView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        calendarView.selectionBehavior = UICalendarSelectionMultiDate(delegate: self)
        scrollView.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        firstStackView.isUserInteractionEnabled = true
        secondStackView.isUserInteractionEnabled = true
        segmentedControl.isUserInteractionEnabled = true
        secondStackView.distribution = .equalCentering
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        guard let visibleMonth = calendarView.visibleDateComponents.month,
              let visibleYear = calendarView.visibleDateComponents.year else {
            return
        }
        isDoneChart.view.isHidden = false
        costChart.view.isHidden = true
        updateIsDoneChart(month: visibleMonth, year: visibleYear)
        setupLoadingIndicator()
        loadAllData()
    }
    
    private func setupViews() {
        
        isDoneChart = IsDonePercentageChart()
        addChild(isDoneChart)
        addChild(costChart)
        isDoneChart.view.frame = graphView.bounds
        costChart.view.frame = graphView.bounds
        view.backgroundColor = UIColor.customBackgroundColor
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addArrangedSubview(firstStackView)
        contentView.addArrangedSubview(secondStackView)
        firstStackView.addArrangedSubview(calendarBar)
        firstStackView.addArrangedSubview(calendarView)
        firstStackView.addArrangedSubview(tableView)
        firstStackView.addArrangedSubview(fakeUnderBar)
        firstStackView.bringSubviewToFront(calendarBar)
        secondStackView.addArrangedSubview(segmentedControl)
        secondStackView.addArrangedSubview(graphView)
        graphView.addSubview(isDoneChart.view)
        graphView.addSubview(costChart.view)
    }
    
    private func setupConstraints() {
        setupScrollViewConstraints()
        setupFirstStackViewConstraints()
        setupdashButtonConstraints()
        setupCalendarViewConstraints()
        setupTableViewConstraints()
        setupFakeUnderBarConstraints()
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
            firstStackView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 10),
            firstStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            firstStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    private func setupCalendarViewConstraints() {
        calendarView.locale = Locale(identifier: "ko_KR")
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: calendarBar.bottomAnchor, constant: -27),
            calendarView.leadingAnchor.constraint(equalTo: firstStackView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: firstStackView.trailingAnchor),
        ])
    }
    private func setupTableViewConstraints() {
        tableViewHeightConstraint?.isActive = false
        
        let cellHeight: CGFloat = 51
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
            tableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -25),
            tableView.leadingAnchor.constraint(equalTo: firstStackView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: firstStackView.trailingAnchor),
            tableViewHeightConstraint!
        ])
    }
    private func setupdashButtonConstraints() {

        NSLayoutConstraint.activate([
            calendarBar.topAnchor.constraint(equalTo: firstStackView.topAnchor),
            calendarBar.leadingAnchor.constraint(equalTo: firstStackView.leadingAnchor),
            calendarBar.trailingAnchor.constraint(equalTo: firstStackView.trailingAnchor),
            calendarBar.heightAnchor.constraint(equalToConstant: 17)
        ])
    }
    private func setupFakeUnderBarConstraints() {
        fakeUnderBarTopConstraint?.isActive = false
        if tableView.isHidden {
            fakeUnderBarTopConstraint = fakeUnderBar.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -26)
        } else {
            fakeUnderBarTopConstraint = fakeUnderBar.topAnchor.constraint(equalTo: tableView.bottomAnchor)
        }
        fakeUnderBarTopConstraint?.isActive = true
        NSLayoutConstraint.activate([
            fakeUnderBarTopConstraint!,
            fakeUnderBar.leadingAnchor.constraint(equalTo: firstStackView.leadingAnchor),
            fakeUnderBar.trailingAnchor.constraint(equalTo: firstStackView.trailingAnchor),
            fakeUnderBar.heightAnchor.constraint(equalToConstant: 1)
        ])
        
    }
    private func setupsecondStackViewConstraints() {
        NSLayoutConstraint.activate([
            secondStackView.topAnchor.constraint(equalTo: firstStackView.bottomAnchor, constant: 30),
            secondStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            secondStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            secondStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            secondStackView.heightAnchor.constraint(equalToConstant: 430)
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
            graphView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            graphView.leadingAnchor.constraint(equalTo: secondStackView.leadingAnchor, constant: 5),
            graphView.trailingAnchor.constraint(equalTo: secondStackView.trailingAnchor, constant: -5),
            graphView.bottomAnchor.constraint(equalTo: secondStackView.bottomAnchor)
        ])
    }
    private func setupCostChartViewConstraints() {
        NSLayoutConstraint.activate([
            costChart.view.topAnchor.constraint(equalTo: graphView.topAnchor),
            costChart.view.leadingAnchor.constraint(equalTo: graphView.leadingAnchor, constant: 30),
            costChart.view.trailingAnchor.constraint(equalTo: graphView.trailingAnchor, constant: -30)
        ])
    }
    private func setupIsDoneChartViewConstraints() {
        NSLayoutConstraint.activate([
            isDoneChart.view.topAnchor.constraint(equalTo: graphView.topAnchor),
            isDoneChart.view.leadingAnchor.constraint(equalTo: graphView.leadingAnchor, constant: 30),
            isDoneChart.view.trailingAnchor.constraint(equalTo: graphView.trailingAnchor, constant: -30)
        ])
    }

    @objc func segmentedControlValueChanged() {
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
    private func setupLoadingIndicator() {
        costChart.view.addSubview(loadingIndicator)
        loadingIndicator.center = costChart.view.center
           loadingIndicator.hidesWhenStopped = true
       }
    
    @objc private func categoryDidChange(_ notification: Notification) {
        if let userInfo = notification.userInfo, let categoryId = userInfo["categoryId"] as? String {
            print("[스냅 비교뷰] 카테고리가 변경되었습니다: \(categoryId)")
            self.categoryDidChange(to: categoryId)
        } else {
            print("카테고리가 없습니다.")
            self.categoryDidChange(to: nil)
        }
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self, name: .categoryDidChange, object: nil)
        }
    
    private func loadAllData() {
            loadingIndicator.startAnimating()
            isDataLoaded = false

            let group = DispatchGroup()

            group.enter()
            loadInitialChartData(categoryId: categoryId) {
                group.leave()
            }

            group.notify(queue: .main) { [weak self] in
                guard let self = self else { return }
                self.isDataLoaded = true
                self.loadingIndicator.stopAnimating()
                self.updateCharts()
            }
        }
    private func refreshAllData() {
        updateSnapsForMonth()
        loadManagements { [weak self] in
            guard let self = self else { return }
            self.loadInitialChartData(categoryId: self.categoryId) {
                if let visibleMonth = self.calendarView.visibleDateComponents.month,
                   let visibleYear = self.calendarView.visibleDateComponents.year {
                    self.updateIsDoneChart(month: visibleMonth, year: visibleYear)
                    self.updateCostChart(month: visibleMonth, year: visibleYear)
                }
            }
        }
    }
    private func updateCharts() {
            guard isDataLoaded else { return }

            if let month = calendarView.visibleDateComponents.month,
               let year = calendarView.visibleDateComponents.year {
                updateCostChart(month: month, year: year)
            }
        }
}
extension CalendarViewController: UICalendarViewDelegate, UICalendarSelectionMultiDateDelegate {
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
        selection.setSelectedDates([dateComponents], animated: true)
        selectedDateComponents = dateComponents
        tableView.isHidden = false
        tableView.reloadData()
        setupConstraints()
    }
    
    func setupMultiSelection() {
    }
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
        selection.setSelectedDates([], animated: true)
        selectedDateComponents = nil
        tableView.isHidden = true
        tableView.reloadData()
        setupConstraints()
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        var isAllDone = false
        dateFormatter.dateFormat = "yyyy-MM-dd"
        isAllDone = !managements.contains { management in
            management.completions.contains { (key, value) in
                if let dateKey = dateFormatter.date(from: key),
                   Calendar.current.isDate(dateKey, inSameDayAs: Calendar.current.date(from: dateComponents)!) {
                    return value == 0 // 완료되지 않은 항목이 있으면 true 반환
                }
                return false // 날짜가 일치하지 않으면 이 항목은 무시
            }
        }
        
        if hasSnapDates.contains(where: { $0.year == dateComponents.year && $0.month == dateComponents.month && $0.day == dateComponents.day }), isAllDone {
            return .customView {
                let imageView = UIImageView()
                let originalImage = UIImage(named: "filledpop")
                let resizedImage = originalImage?.resized(to: CGSize(width: 18, height: 18))
                imageView.image = resizedImage
                return imageView
            }
        }
//        else if hasSnapDates.contains(where: { $0.year == dateComponents.year && $0.month == dateComponents.month && $0.day == dateComponents.day }), !isAllDone {
//            return .customView {
//                let imageView = UIImageView()
//                let originalImage = UIImage(named: "emptypop")
//                let resizedImage = originalImage?.resized(to: CGSize(width: 18, height: 18))
//                imageView.image = resizedImage
//                return imageView
//            }
//        }
        else {
            return .customView {
                let imageView = UIImageView()
                let originalImage = UIImage(named: "emptypop")
                let resizedImage = originalImage?.resized(to: CGSize(width: 18, height: 18))
                imageView.image = resizedImage
                return imageView
            }
        }
    }
    
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        guard let visibleMonth = calendarView.visibleDateComponents.month,
              let visibleYear = calendarView.visibleDateComponents.year else {
            return
        }
        updatMonthlyInfo(month: visibleMonth, year: visibleYear)
        updateSnapsForMonth()
        if let multiSelection = calendarView.selectionBehavior as? UICalendarSelectionMultiDate {
            multiSelection.setSelectedDates([], animated: true)
        }
        selectedDateComponents = nil
        tableView.isHidden = true
        tableView.reloadData()
        updateIsDoneChart(month: visibleMonth, year: visibleYear)
        updateCharts()
    }
    
    func updatMonthlyInfo(month: Int, year: Int) {
        isDoneChart.updateMonthLabel(month: month, year: year)
        costChart.updateMonthLabel(month: month, year: year)
    }
    
    private func updateIsDoneChart(month: Int, year: Int) {
        guard !managements.isEmpty else {
            isDoneChart.updateChart(withPercentage: 0)
            return
        }
        
        var totalCompletions = 0
        var totalTasks = 0
        
        for management in managements {
            for (key, value) in management.completions {
                if compareYearMonth(year, month, with: key) {
                    totalCompletions += value
                    totalTasks += 1
                }
            }
        }
        
        let percentage: Double
        if totalTasks > 0 {
            percentage = (Double(totalCompletions) / Double(totalTasks)) * 100.0
        } else {
            percentage = 0
        }
        
        isDoneChart.updateChart(withPercentage: percentage)
        updatMonthlyInfo(month: month, year: year)
    }
    
    func updateChartData(month: Int, year: Int) -> [ChartDataItem] {
        var chartItems: [ChartDataItem] = []
        
        for (managementId, detailCosts) in detailCostsCache {
            let managementColor = getDetailColor(managementId: managementId) ?? "defaultColor"
            
            for detailCost in detailCosts {
                if let cost = detailCost.oneTimeCost, cost > 0 {
                    let completionCount = countingCompletionOfManagement(managementId: managementId, month: month, year: year)
                    let value = cost * completionCount
                    chartItems.append(ChartDataItem(name: detailCost.title, value: value, color: managementColor, managementId: managementId))
                }
            }
        }
        
        return chartItems
    }
    
    private func updateCostChart(month: Int, year: Int) {
        guard !managements.isEmpty else {
            costChart.updateChartData([])
            return
        }
        
        let chartItems = updateChartData(month: month, year: year)
        
        if chartItems.isEmpty {
        } else {
            let chartData = chartItems.map { item in
                ChartItem(name: item.name, value: item.value, color: UIColor(hex: item.color) ?? .systemGray)
            }
            costChart.updateChartData(chartData)
        }
    }
    
    func compareYearMonth(_ year: Int, _ month: Int, with dateString: String) -> Bool {
        let compareString = String(format: "%04d-%02d", year, month)
        let yearMonthString = String(dateString.prefix(7))
        return compareString == yearMonthString
    }
    
    func updateSnapsForMonth() {
        guard let currentDate = calendarView.visibleDateComponents.date else { return }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        
        guard let year = components.year, let month = components.month else { return }
        
        snapService.loadSnapsForMonth(categoryId: categoryId, year: year, month: month) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let snaps):
                self.hasSnapDates = Set(snaps.compactMap { snap in
                    guard let date = snap.createdAt else { return nil }
                    return Calendar.current.dateComponents([.year, .month, .day], from: date)
                })
                
                DispatchQueue.main.async {
                    // 모든 날짜에 대해 데코레이션을 다시 로드합니다.
                    let allDates = self.getAllDatesForMonth(year: year, month: month)
                    self.calendarView.reloadDecorations(forDateComponents: allDates, animated: true)
                }
                
            case .failure(let error):
                print("Failed to load snaps: \(error)")
            }
        }
    }
    
    func loadManagements(completion: @escaping () -> Void) {
        managementService.loadManagements(categoryId: categoryId) { [weak self] result in
            switch result {
            case .success(let managements):
                self?.managements = managements
                DispatchQueue.main.async {
                    completion()
                }
            case .failure(let error):
                print("Failed to load managements: \(error)")
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func loadDetailCosts(categoryId: String, managementId: String, completion: @escaping (Result<[DetailCost], Error>) -> Void) {
        managementService.loadDetailCosts(categoryId: categoryId, managementId: managementId) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func loadInitialChartData(categoryId: String, completion: @escaping () -> Void) {
        self.detailCostsCache.removeAll()
        
        let group = DispatchGroup()
        
        for management in managements {
            group.enter()
            loadDetailCosts(categoryId: categoryId, managementId: management.id!) { [weak self] result in
                defer { group.leave() }
                
                guard let self = self else { return }
                
                switch result {
                case .success(let detailCosts):
                    self.detailCostsCache[management.id!] = detailCosts
                case .failure(let error):
                    print("Error loading detail costs for management \(management.id!): \(error)")
                }
            }
        }
        group.notify(queue: .main) {
            completion()
        }
    }
    
    private func filteringMatchingManagements() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        selectedDate = selectedDateComponents?.date ?? Date()
        matchingManagements = managements.filter { management in
            management.completions.keys.contains { key in
                if let keyDate = dateFormatter.date(from: key) {
                    return Calendar.current.isDate(keyDate, inSameDayAs: selectedDate)
                }
                return false
            }
        }
    }
    
    private func getDetailColor(managementId: String) -> String? {
        return managements.first { $0.id == managementId }?.color
    }
    
    private func countingCompletionOfManagement(managementId: String, month: Int, year: Int) -> Int {
        var totalCompletions = 0
        let completions = managements.first { $0.id == managementId }?.completions
        for (key, value) in completions! {
            if compareYearMonth(year, month, with: key) {
                totalCompletions += value
            }
        }
        return totalCompletions
    }
    
    private func getAllDatesForMonth(year: Int, month: Int) -> [DateComponents] {
        let calendar = Calendar.current
        guard let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let range = calendar.range(of: .day, in: .month, for: startDate) else {
            return []
        }
        
        return (1...range.count).map { day in
            DateComponents(year: year, month: month, day: day)
        }
    }
    
    func categoryDidChange(to newCategoryId: String?) {
            guard let newCategoryId = newCategoryId else {
                refreshAllData()
                selectedDateComponents = nil
                tableView.isHidden = true
                return
            }
            self.categoryId = newCategoryId
            
            if let multiSelection = calendarView.selectionBehavior as? UICalendarSelectionMultiDate {
                multiSelection.setSelectedDates([], animated: true)
            }
            // 데이터를 순차적으로 로드하고 차트를 업데이트합니다.
            refreshAllData()
            selectedDateComponents = nil
            tableView.isHidden = true
        }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        filteringMatchingManagements()
        
        return matchingManagements.isEmpty ? 1 : matchingManagements.count
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as? TodoTableViewCell else {
            fatalError("Unable to dequeue CustomTableViewCell")
        }
        
        filteringMatchingManagements()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        cell.backgroundColor = .dynamicBackgroundInsideColor
        if matchingManagements.isEmpty {
            cell.setLabelText("등록된 자기관리가 없습니다", isManagementEmpty: true)
        } else {
            let management = matchingManagements[indexPath.row]
            cell.setLabelText(management.title, isManagementEmpty: false)
            cell.checkboxButton.tag = indexPath.row
            
            let isCompleted = management.completions.contains { (key, value) in
                if let keyDate = dateFormatter.date(from: key),
                   Calendar.current.isDate(keyDate, inSameDayAs: selectedDate) {
                    return value == 1
                }
                return false
            }
            cell.updateCheckboxState(isChecked: isCompleted)
            cell.updateCheckboxColor(color: management.color)
            cell.checkboxButton.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
        }
        
        return cell
    }
    @objc func checkboxTapped(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        filteringMatchingManagements()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let index = sender.tag
        let management = matchingManagements[index]
        var dateKey: String = ""
        let completionState = management.completions.compactMap { (key, value) -> Bool? in
            if let keyDate = dateFormatter.date(from: key), Calendar.current.isDate(keyDate, inSameDayAs: selectedDate) {
                dateKey = key
                return value == 1
            }
            return nil
        }
        guard let managementId = management.id else  { return }
        
        if let managementIndex = managements.firstIndex(where: { $0.id == managementId }) {
            managements[managementIndex].completions[dateKey] = completionState[0] ? 0 : 1
        }
        managementService.updateCompletion(categoryId: categoryId, managementId: managementId, date: selectedDate, isCompleted: !completionState[0]) { result in
            switch result {
            case .success(()):
                print("Completion updated successfully")
            case .failure(let error):
                print("Fail \(error)")
            }
        }
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TodoTableViewCell {
            cell.updateCheckboxState(isChecked: !completionState[0])
        }
        
        if let month = calendarView.visibleDateComponents.month, let year = calendarView.visibleDateComponents.year {
            updateIsDoneChart(month: month, year: year)
            updateCostChart(month: month, year: year)
        }
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        self.calendarView.reloadDecorations(forDateComponents: [dateComponents], animated: true)
        }
    }
