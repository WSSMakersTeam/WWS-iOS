//
//  SearchHeaderView.swift
//  WSSiOS
//
//  Created by 최서연 on 1/6/24.
//

import UIKit

import SnapKit
import Then

final class SearchHeaderView: UIView {
    
    //MARK: set Properties
    
    let searchBar = UISearchBar()
    
    //MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierachy()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: set UI
    
    private func setUI() {
        self.do {
            $0.backgroundColor = .white
        }
        
        searchBar.do {
            $0.setImage(ImageLiterals.icon.search, for: .search, state: .normal)
            $0.layer.borderColor = UIColor.Gray200.cgColor
            $0.layer.borderWidth = 1
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 12
        }
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = .White
            textfield.font = .Body2
            textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "등록할 작품 검색하기", attributes: [NSAttributedString.Key.foregroundColor : UIColor.Gray200])
            // 텍스트 입력시 색상
            textfield.textColor = UIColor.Black
        }
    }
    
    //MARK: set Hierachy
    
    private func setHierachy() {
        self.addSubview(searchBar)
    }
    
    //MARK: set Layout
    
    private func setLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
    }
}
