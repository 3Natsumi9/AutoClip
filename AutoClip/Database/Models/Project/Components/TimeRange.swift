//
//  TimeRange.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/19.
//

import Foundation
import RealmSwift

class TimeRange: Object {
    @Persisted var start: Time?
    @Persisted var end: Time?
}
