//
//  svenmodels.swift
//  SnapPop
//
//  Created by 김형준 on 8/13/24.
//

import Foundation

class DailyModel {
    var snap = true
    var todoList: [String] = []
    
    init(snap: Bool = true, todoList: [String]) {
        self.snap = snap
        self.todoList = todoList
    }
}
