//
//  VideoPlayerPublisher.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/18.
//

import Foundation
import Combine
import AVKit

class VideoPlayerPublisher {
    var subject = PassthroughSubject<CMTime, Never>()
    var cancellable = Set<AnyCancellable>()
    
    init() {
        subject.sink { cmTime in
            
        }
        .store(in: &cancellable)
    }
}
