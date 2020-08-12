//
//  UIApplicationExtensions.swift
//  Money Detection App
//
//  Created by Sevak Soghoyan on 8/7/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

//MARK:- Utility method to cancel all curently running tasks
extension URLSession {
    static func cancelAllTasks() {
        shared.getAllTasks { tasks in
            tasks.filter { $0.state == .running }.forEach({ (task) in
                task.cancel()
            })
        }
    }
}
