//
//  CustomDatePickerViewController.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/22/24.
//

import UIKit
import SwiftUI

class CustomDatePickerViewController: UIViewController {
    
    private let datePickerContainer = UIView()
    private let datePicker = UIDatePicker()
    private let calendarImageView = UIImageView()
    private let dateButton = UIButton()
    private var datePickerHeightConstraint: NSLayoutConstraint!
    var selectedDate = Date() {
        didSet {
            viewModel.selectedDate = selectedDate // 날짜가 변경될 때마다 뷰모델 업데이트
        }
    }
    
    var viewModel: HomeViewModel! // HomeViewModel 주입가즈아
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupDatePickerView()
    }
    
    private func setupDatePickerView() {
        setupDatePickerContainer()
        setupCalendarImageView()
        setupDatePicker()
        setupDateButton()
        setupDatePickerConstraints()
    }
    
    private func setupDatePickerContainer() {
        datePickerContainer.translatesAutoresizingMaskIntoConstraints = false
        datePickerContainer.backgroundColor = UIColor.customButtonColor
        datePickerContainer.layer.cornerRadius = 10
        datePickerContainer.layer.masksToBounds = true
        view.addSubview(datePickerContainer)
    }
    
    private func setupCalendarImageView() {
        calendarImageView.image = UIImage(named: "CalenderIcon")
        calendarImageView.translatesAutoresizingMaskIntoConstraints = false
        calendarImageView.tintColor = .gray
        datePickerContainer.addSubview(calendarImageView)
    }
    
    private func setupDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.backgroundColor = .white
        datePicker.preferredDatePickerStyle = .inline
        
        datePicker.layer.cornerRadius = 10
        datePicker.layer.masksToBounds = true
        
        datePicker.layer.borderColor = UIColor.black.cgColor
        datePicker.layer.borderWidth = 1
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        view.addSubview(datePicker)
        datePickerHeightConstraint = datePicker.heightAnchor.constraint(equalToConstant: 0)
        datePickerHeightConstraint.isActive = true
    }
    
    private func setupDateButton() {
        updateDateButton(for: selectedDate) // Initialize button with selected date
        
        dateButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        dateButton.setTitleColor(.black, for: .normal)
        dateButton.backgroundColor = UIColor.customButtonColor
        dateButton.layer.cornerRadius = 10
        dateButton.layer.masksToBounds = true
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        dateButton.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        
        datePickerContainer.addSubview(dateButton)
    }
    private func setupDatePickerConstraints() {
        NSLayoutConstraint.activate([
            datePickerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.1), // 너비 조정
            datePickerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.height * 0.02),
            datePickerContainer.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05),
            datePickerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.5), // 너비 조정
            
            calendarImageView.leadingAnchor.constraint(equalTo: datePickerContainer.leadingAnchor, constant: view.bounds.width * 0.02),
            calendarImageView.centerYAnchor.constraint(equalTo: datePickerContainer.centerYAnchor),
            calendarImageView.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.06),
            calendarImageView.heightAnchor.constraint(equalToConstant: view.bounds.width * 0.06),
            
            dateButton.leadingAnchor.constraint(equalTo: calendarImageView.trailingAnchor, constant: 5),
            dateButton.centerYAnchor.constraint(equalTo: datePickerContainer.centerYAnchor),
            
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            datePicker.trailingAnchor.constraint(equalTo: datePickerContainer.trailingAnchor, constant: view.bounds.width * 0.4),
            datePicker.topAnchor.constraint(equalTo: dateButton.bottomAnchor, constant: 10)
        ])
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date // Update selected date
        updateDateButton(for: selectedDate) // Update the button title with the selected date
        dateButtonTapped()
    }
    
    @objc private func dateButtonTapped() {
        let isDatePickerHidden = datePickerHeightConstraint.constant == 0
        let datePickerExpandedHeight: CGFloat = view.bounds.height * 0.4
        let datePickerCollapsedHeight: CGFloat = 0
        
        datePickerHeightConstraint.constant = isDatePickerHidden ? datePickerExpandedHeight : datePickerCollapsedHeight

        // MARK: 애니메이션을 시도했는데 선택된 날짜가 울렁울렁 해보임.
//        UIView.animate(withDuration: 0.3) {
//            self.view.layoutIfNeeded()
//        }
    }
    
    private func updateDateButton(for date: Date) {
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDay = Calendar.current.startOfDay(for: date)
        
        let dayDifference = Calendar.current.dateComponents([.day], from: today, to: selectedDay).day ?? 0
        
        // MARK: yyyy-MM-dd 형식과 한글로 날짜 표시 할 경우 칸 차이가 많이나서 공백으로 최소화 할려고 했음. (좋은 의견 있으면 추천 바람..)
        switch dayDifference {
        case 0:
            dateButton.setTitle("      오늘", for: .normal)
        case 1:
            dateButton.setTitle("      내일", for: .normal)
        case -1:
            dateButton.setTitle("      어제", for: .normal)
        case 2:
            dateButton.setTitle("      모레", for: .normal)
        default:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateButton.setTitle(dateFormatter.string(from: date), for: .normal)
        }
    }
}
