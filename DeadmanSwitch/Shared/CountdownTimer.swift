//
//  CountdownTimer.swift
//  DeadmanSwitch
//
//  Created by Robert Booth on 2/17/22.
//

import Foundation
import Combine

public class CountdownTimer: ObservableObject {
    public enum Status {
        case stop
        case countdown
    }

    private(set) var formattedDuration: String = "00:00"
    private(set) public var maxTimeLimit: TimeInterval

    private var timer: Timer?
    private(set) public var status = Status.stop
    
    private var incrementValue = 0.1

    var portionFull = 1.0
    var counter = 0.0 {
        willSet {
            objectWillChange.send()
        }

        didSet {
            let reverse = maxTimeLimit - counter // TimeInterval(integerLiteral: Int64(counter))
            formattedDuration = reverse.stringFromTimeInterval()
            portionFull = (maxTimeLimit - counter) / maxTimeLimit
        }
    }

    public init(limitTimeInterval: TimeInterval) {
        self.maxTimeLimit = limitTimeInterval
    }
    
    public func run() {
        incrementValue = 0.1
        start()
    }
    
    public func recover() {
        guard counter < maxTimeLimit else { return }
        incrementValue = -0.05
    }
    
}

public extension CountdownTimer {
    func start() {
        guard status != .countdown else { return }
        startTimer()
    }

    func reset() {
        status = .stop
        timer?.invalidate()
    }
}

private extension CountdownTimer {
    func startTimer() {
        status = .countdown

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.counter += self.incrementValue
            if self.counter < 0.0 {
                self.counter = 0.0
            } else if self.counter >= self.maxTimeLimit {
                self.counter = self.maxTimeLimit
            }
        }
    }
}

extension TimeInterval {
    func stringFromTimeInterval() -> String {

        let time = NSInteger(self)

        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
//        let minutes = (time / 60) % 60
//        let hours = (time / 3600)

//        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d", hours, minutes, seconds, ms)
        return String(format: "%0.2d.%0.3d", seconds, ms)

    }
}
