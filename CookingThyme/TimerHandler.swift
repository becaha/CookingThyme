//
//  TimerHandler.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/8/20.
//

import Foundation

class TimerHandler: ObservableObject {
    @Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Published var timeRemainingString: String = ""
    @Published var isPaused: Bool = false
    @Published var isSetting: Bool = true
    @Published var timerAlert: Bool = false

    
    var timeRemaining: Int = 0 {
        willSet {
            timeRemainingString = newValue.timeFormat()
            if newValue == 0 {
                isPaused = false
                timerAlert = true
            }
        }
    }
    
    private var startTime: Date?
    private var timeAmount: Int = 0
    
    init() {
        
    }
    
    // MARK: - Access
    
    
    // MARK: - Intents
    
    func updateTimeRemaining() {
        if let startTime = self.startTime {
            let timeElapsed = Date().timeIntervalSince(startTime)
            timeRemaining -= Int(timeElapsed)
        }
    }
    
    func getSeconds(h hours: Int, m minutes: Int, s seconds: Int) -> Int {
        let secInHour =  3600
        let secInMin = 60
        return (hours * secInHour) + (minutes * secInMin) + seconds
    }
    
    func pause() {
        isPaused.toggle()
        timerAlert = false
    }
    
    func stop() {
        isSetting = true
        timerAlert = false
    }
    
    func cancel() {
        isSetting = true
    }
    
    func repeatTimer() {
        timeRemaining = timeAmount
        start()
    }
    
    func start() {
        startTime = Date()
        isSetting = false
    }
    
    func setTimer(h hours: Int, m minutes: Int, s seconds: Int) {
        timeAmount = getSeconds(h: hours, m: minutes, s: seconds)
        timeRemaining = timeAmount
    }
    
    func count() {
        if self.timeRemaining > 0 && !isPaused {
            self.timeRemaining -= 1
        }
    }
}

extension Int {
    // ints in seconds to hours:min:sec format
    func timeFormat() -> String {
        let secInHour =  3600.0
        let secInMin = 60.0
        
        var remainder = Double(self)
        let hours: Double = floor(remainder / secInHour)
        remainder -= (hours * secInHour)
        let minutes: Double = floor(remainder / secInMin)
        remainder -= (minutes * secInMin)
        let seconds = remainder
        let timeString = String(format: "%02d:%02d:%02d", Int(hours), Int(minutes), Int(seconds))
        return timeString
    }
}
