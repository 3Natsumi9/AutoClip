//
//  Time.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/19.
//

import Foundation
import RealmSwift

class Time: Object {
    @Persisted var value: Int
    @Persisted var timescale: Int
}
