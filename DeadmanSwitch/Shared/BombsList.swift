//
//  BombsList.swift
//  DeadmanSwitch
//
//  Created by Michael Huovila on 2/21/22.
//

import SwiftUI

class BombList: ObservableObject {
    class Bomb: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let startTime: Double
        var timeRemaining: Double
        var ratioRemaining: Double {
            let ratio = timeRemaining / startTime
            return ratio > 0.0 ? ratio : 0.0
        }
        func decreaseTimeRemaining(_ time: Double) {
            timeRemaining -= time
        }
        init(x: CGFloat, y: CGFloat, time: Double) {
            self.x = x
            self.y = y
            self.startTime = time
            self.timeRemaining = time
        }
    }
    
    @Published var bombs = [Bomb]()
    var running = false
    var maxX = 0.0
    var maxY = 0.0
    var borderProtect = 10.0
    @Published var elapsedTime = 0.0
    var nextBombAtTime = 2.0
    var numberBombsTotal = 0
    @Published var numberBombsDisarmed = 0
    let timeInterval = 0.1
    let easeFactor = 100.0
    var minTimeUntilNextBomb = 5.0
    var maxTimeUntilNextBomb = 6.0
    
    var chanceToAddNewBomb: Double {
        return elapsedTime / (elapsedTime + easeFactor)
    }
    
    func add(x: CGFloat, y: CGFloat) {
        numberBombsTotal += 1
        let newBomb = Bomb(x: x, y: y, time: 5.0)
        bombs.append(newBomb)
    }
    
    func remove(_ bomb: Bomb) {
        guard !anyBombsExploded else { return }
        numberBombsDisarmed += bombs.filter { $0.x == bomb.x && $0.y == bomb.y }.count
        bombs = bombs.filter { $0.x != bomb.x && $0.y != bomb.y }
    }
    
    var anyBombsExploded: Bool {
        for bomb in bombs {
            if bomb.timeRemaining <= 0.0 {
                return true
            }
        }
        return false
    }
    
    init() {
        let _ = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] _ in
            guard let self = self, self.running, !self.anyBombsExploded else { return }
            for bomb in self.bombs {
                bomb.timeRemaining -= self.timeInterval
            }
            self.elapsedTime += self.timeInterval
            if self.elapsedTime >= self.nextBombAtTime {
                let x = CGFloat.random(in: self.borderProtect ..< (self.maxX - self.borderProtect))
                let y = CGFloat.random(in: self.borderProtect ..< (self.maxY - self.borderProtect))
                self.add(x: x, y: y)
                self.minTimeUntilNextBomb *= 0.9
                self.maxTimeUntilNextBomb *= 0.95
                if self.minTimeUntilNextBomb < 1.0 {
                    self.minTimeUntilNextBomb = 1.0
                }
                if self.maxTimeUntilNextBomb < 2.0 {
                    self.maxTimeUntilNextBomb = 2.0
                }
                self.nextBombAtTime = self.elapsedTime + Double.random(in: self.minTimeUntilNextBomb..<self.maxTimeUntilNextBomb)
            }
        }
    }
}
