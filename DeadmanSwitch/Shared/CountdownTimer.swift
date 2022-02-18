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
    private(set) public var limitTimeInterval: TimeInterval
    private(set) public var nextFractionCompleted: Double = 0.0

    var formattedLimitDuration: String {
        get {
//            return timeFormatter.string(from: limitTimeInterval)!
            return limitTimeInterval.stringFromTimeInterval()
        }
    }

    var duration: Double {
        get {
            return counter
        }
    }

    private var timer: Timer?
    private(set) public var status = Status.stop

    // TODO: Figure out how to make this work with milliseconds or fix TimeInterval extension below
//    private lazy var timeFormatter: DateComponentsFormatter = {
//        let formatter = DateComponentsFormatter()
//        formatter.unitsStyle = .positional
//        formatter.allowedUnits = [.second, .nanosecond]
//        formatter.zeroFormattingBehavior = [.pad]
//        return formatter
//    }()

    private var counter = 0.0 {
        willSet {
            objectWillChange.send()
        }

        didSet {
            let reverse = limitTimeInterval - counter // TimeInterval(integerLiteral: Int64(counter))
//            formattedDuration = timeFormatter.string(from: reverse)!
            formattedDuration = reverse.stringFromTimeInterval()

            switch status {
            case .stop:
                nextFractionCompleted = 0.0
            case .countdown:
                nextFractionCompleted = Double(1 + counter) / limitTimeInterval
            }
        }
    }

    public init(limitTimeInterval: TimeInterval) {
        self.limitTimeInterval = limitTimeInterval
    }
}

public extension CountdownTimer {
    func start() {
        guard status != .countdown else { return }
        startTimer()
    }

    func reset() {
        status = .stop
        counter = 0.0
        timer?.invalidate()
    }
}

private extension CountdownTimer {
    func startTimer() {
        status = .countdown
        counter = 0.0

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.counter += 0.1
            if self.limitTimeInterval <= TimeInterval(self.counter) {
                self.reset()
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
