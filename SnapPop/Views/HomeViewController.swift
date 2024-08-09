//
//  HomeViewController.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/8/24.
//
import UIKit
import SwiftUI

extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let vc: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return vc
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
    
    func toPreview() -> some View {
        Preview(vc: self)
    }
}

class HomeViewController: NavigationViewController{
    
    // UI 요소
    let datePickerContainer = UIView()
    let datePicker = UIDatePicker()
    let calendarImageView = UIImageView()
    let snapTitle = UILabel()
    let editButton = UIButton(type: .system)
    var collectionView: UICollectionView?
    
    var tempimagedata = [UIImage(named: "1")!, UIImage(named: "2")!, UIImage(named: "3")!, UIImage(named: "4")!] // UIImage가 nil이 아닌지 확인
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 250/255, green: 251/255, blue: 253/255, alpha: 1.0)
        setupView()
        setupConstraints()
    }
    
    // MARK: - UI 설정
    private func setupView() {
        setupDatePickerContainer()
        setupCalendarImageView()
        setupDatePicker()
        setupSnapTitle()
        setupEditButton()
    }
    
    // MARK: 날짜 선택 UI 컨트롤
    private func setupDatePickerContainer() {
        datePickerContainer.translatesAutoresizingMaskIntoConstraints = false
        datePickerContainer.backgroundColor = UIColor(red: 199/255, green: 239/255, blue: 247/255, alpha: 1.0)
        datePickerContainer.layer.cornerRadius = 10
        datePickerContainer.layer.masksToBounds = true
        self.view.addSubview(datePickerContainer)
    }
    
    private func setupCalendarImageView() {
        calendarImageView.image = UIImage(named: "CalenderIcon")
        calendarImageView.translatesAutoresizingMaskIntoConstraints = false
        calendarImageView.tintColor = .black
        datePickerContainer.addSubview(calendarImageView)
    }
    
    private func setupDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.backgroundColor = UIColor.clear
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        datePickerContainer.addSubview(datePicker)
    }
    
    // MARK: 스냅 타이틀 UI 컨트롤
    private func setupSnapTitle() {
        snapTitle.translatesAutoresizingMaskIntoConstraints = false
        snapTitle.text = "Snap Pop"
        snapTitle.font = UIFont.boldSystemFont(ofSize: 24)
        snapTitle.textColor = .black
        self.view.addSubview(snapTitle)
    }
    
    // MARK: 스냅 타이틀 UI 컨트롤
    private func setupEditButton() {
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle("편집", for: .normal)
        editButton.setTitleColor(.blue, for: .normal)
        self.view.addSubview(editButton)
    }
    
    // MARK: - 제약조건 설정
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // DatePicker 컨테이너 제약 조건
            datePickerContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            datePickerContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            datePickerContainer.heightAnchor.constraint(equalToConstant: 40),
            
            // 캘린더 이미지 제약 조건
            calendarImageView.leadingAnchor.constraint(equalTo: datePickerContainer.leadingAnchor, constant: 8),
            calendarImageView.centerYAnchor.constraint(equalTo: datePickerContainer.centerYAnchor),
            calendarImageView.widthAnchor.constraint(equalToConstant: 24),
            calendarImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // DatePicker 제약 조건
            datePicker.leadingAnchor.constraint(equalTo: calendarImageView.trailingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: datePickerContainer.trailingAnchor, constant: -8),
            datePicker.centerYAnchor.constraint(equalTo: datePickerContainer.centerYAnchor),
            
            // Snap Pop 제목 제약 조건
            snapTitle.leadingAnchor.constraint(equalTo: datePickerContainer.leadingAnchor),
            snapTitle.topAnchor.constraint(equalTo: datePickerContainer.bottomAnchor, constant: 20),
            
            // 편집 버튼 제약 조건
            editButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            editButton.centerYAnchor.constraint(equalTo: snapTitle.centerYAnchor)
        ])
    }
    
    // MARK: - 날짜 변경 시 호출
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = sender.date
        print("선택한 날짜: \(dateFormatter.string(from: selectedDate))")
    }
}

#if DEBUG
struct HomeViewControllerPreview: PreviewProvider {
    static var previews: some View {
        // HomeViewController의 인스턴스를 직접 생성
        UINavigationController(rootViewController: HomeViewController())
                 .toPreview()
    }
}
#endif
