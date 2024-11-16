//
//  MyPageLibraryView.swift
//  WSSiOS
//
//  Created by 신지원 on 11/16/24.
//

import UIKit

import SnapKit
import Then

final class MyPageLibraryView: UIView {
    
    //MARK: - Properties
    
    var isExist: Bool = true {
        didSet {
            updateView(isExist: isExist)
        }
    }
    
    //MARK: - Components
    
    let inventoryView = MyPageInventoryView()
    let preferencesEmptyView = MyPagePreferencesEmptyView()
    let novelPrefrerencesView = MyPageNovelPreferencesView()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
        updateView(isExist: isExist)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI
    
    private func setUI() {
        self.backgroundColor = .wssGray50
    }
    
    private func setHierarchy() {
        if !isExist {
            self.addSubviews(inventoryView,
                             preferencesEmptyView)
        } else {
            self.addSubviews(inventoryView,
                             novelPrefrerencesView)
        }
    }
    
    private func setLayout() {
        inventoryView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }
        
        if !isExist {
            preferencesEmptyView.snp.makeConstraints {
                $0.top.equalTo(inventoryView.snp.bottom).offset(3)
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(363)
            }
        } else {
            novelPrefrerencesView.snp.makeConstraints {
                $0.top.equalTo(inventoryView.snp.bottom).offset(3)
                $0.leading.trailing.bottom.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
        }
    }
    
    func updateView(isExist: Bool) {
        setHierarchy()
        setLayout()
    }
}



