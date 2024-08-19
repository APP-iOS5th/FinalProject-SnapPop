//
//  CalendarViewController.swift
//  SnapPop
//
//  Created by 김형준 on 8/9/24.
//

import UIKit

class CalendarViewController: UIViewController {
    
    var dailymodels = DailyModel(todoList: ["밥먹기", "커피마시기"])
    
    var selectedDate: DateComponents?
    
    private var segmentedControlTopConstraint: NSLayoutConstraint?
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private var donutChart: DoughnutChartViewController!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private let contentView: UIStackView = {
        let view = UIStackView()
        view.backgroundColor = .clear
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
        stackView.backgroundColor = .clear
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.layer.cornerRadius = 20
        stackView.clipsToBounds = true
        return stackView
    }()
    
    private let calendarView: UICalendarView = {
        var view = UICalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsDateDecorations = true
        view.tintColor = UIColor(red: 120/255, green: 200/255, blue: 200/255, alpha: 0.8)
        view.backgroundColor = .clear
        return view
    }()
    
    private let tableView: UITableView = {
        var view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.backgroundColor = .white
        view.sectionIndexColor = UIColor.black
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
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let segmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["달성률", "비용"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor(red: 92/255, green: 223/255, blue: 231/255, alpha: 0.6)
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
        calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        scrollView.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        firstStackViewView.isUserInteractionEnabled = true
        secondStackView.isUserInteractionEnabled = true
        dashButton.isUserInteractionEnabled = true
        segmentedControl.isUserInteractionEnabled = true
        secondStackView.distribution = .equalCentering

    }
    
    private func setupViews() {
        
        donutChart = DoughnutChartViewController()
        addChild(donutChart)
        donutChart.view.frame = graphView.bounds
        
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
        graphView.addSubview(donutChart.view)
        
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
        setupDonutChartViewConstraints()
        
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
            firstStackViewView.topAnchor.constraint(equalTo: contentView.topAnchor),
            firstStackViewView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            firstStackViewView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    
    private func setupCalendarViewConstraints() {
        calendarView.locale = Locale(identifier: "ko_KR")
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: firstStackViewView.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: firstStackViewView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: firstStackViewView.trailingAnchor)            ])
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
            tableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: firstStackViewView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: firstStackViewView.trailingAnchor),
            tableViewHeightConstraint!
        ])
    }
    private func setupdashButtonConstraints() {
        NSLayoutConstraint.activate([
            dashButton.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            dashButton.leadingAnchor.constraint(equalTo: firstStackViewView.leadingAnchor),
            dashButton.trailingAnchor.constraint(equalTo: firstStackViewView.trailingAnchor),
            dashButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupsecondStackViewConstraints() {
        NSLayoutConstraint.activate([
            secondStackView.topAnchor.constraint(equalTo: firstStackViewView.bottomAnchor, constant: 30),
            secondStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            secondStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            secondStackView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupSegmentedControlConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: secondStackView.topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: secondStackView.leadingAnchor, constant: 5),
            segmentedControl.trailingAnchor.constraint(equalTo: secondStackView.trailingAnchor, constant: -5),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupgraphViewConstraints() {
        NSLayoutConstraint.activate([
            graphView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 30),
            graphView.leadingAnchor.constraint(equalTo: secondStackView.leadingAnchor, constant: 5),
            graphView.trailingAnchor.constraint(equalTo: secondStackView.trailingAnchor, constant: -5)
        ])
    }
    
    private func setupDonutChartViewConstraints() {
        NSLayoutConstraint.activate([
            donutChart.view.topAnchor.constraint(equalTo: graphView.topAnchor),
            donutChart.view.leadingAnchor.constraint(equalTo: graphView.leadingAnchor, constant: 30),
            donutChart.view.trailingAnchor.constraint(equalTo: graphView.trailingAnchor, constant: -30)
        ])
    }
    
    
    
}

extension CalendarViewController: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        selection.setSelected(dateComponents, animated: true)
        selectedDate = dateComponents
        tableView.isHidden = false
        tableView.reloadData()
        setupConstraints()
        setupTableViewConstraints()
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        if dailymodels.snap {
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
    
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, dailymodels.todoList.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell") ??
        UITableViewCell(style: .default, reuseIdentifier: "TodoCell")
        if dailymodels.todoList.isEmpty {
            cell.textLabel?.text = "등록된 자기관리가 없습니다."
        } else {
            cell.textLabel?.text = dailymodels.todoList[indexPath.row]
        }
        return cell
    }
}

extension UIViewController {
    
    func setupNavigationsItems() {
        let titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        let settingButton = UIButton(type: .system)
        settingButton.setImage(UIImage(systemName: "gear"), for: .normal)
        settingButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        
        let notificationButton = UIButton(type: .system)
        notificationButton.setImage(UIImage(systemName: "bell"), for: .normal)
        notificationButton.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
        
        view.addSubview(settingButton)
        view.addSubview(titleLabel)
    }
    
    @objc func settingButtonTapped() {
        print("설정뷰로 이동")
    }
    
    @objc func notificationButtonTapped() {
        print("알림뷰로 이동")
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
