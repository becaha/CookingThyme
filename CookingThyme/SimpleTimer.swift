//
//  SimpleTimer.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/8/20.
//

import Foundation

struct SimpleTimer {
    var timeRemainingString: String = ""
    var isPaused: Bool = true
    var isSetting: Bool = true
    var timerAlert: Bool = false
    
    var timeRemaining: Int = 0 {
        didSet {
            if timeRemaining == -1 {
                timeRemaining = 0
                isPaused = true
                timerAlert = true
            }
            timeRemainingString = timeRemaining.timeFormat() //bloatVar: bloatVar)
        }
    }
    
    var timeRemainingRatio: Double {
        return timeRemaining > 0 ? Double(timeRemaining) / Double(timeAmount) : 0
    }
    
//    private let bloatVar = 100
    private var startTime: Date?
    private var timeAmount: Int = 0
    
    func getSeconds(h hours: Int, m minutes: Int, s seconds: Int) -> Int {
        let secInHour =  3600
        let secInMin = 60
        return (hours * secInHour) + (minutes * secInMin) + seconds
    }
    
    func getBloatedSeconds(h hours: Int, m minutes: Int, s seconds: Int) -> Int {
        let seconds = getSeconds(h: hours, m: minutes, s: seconds)
        return seconds // * bloatVar
    }
    
    mutating func pause() {
        isPaused.toggle()
        timerAlert = false
    }
    
    mutating func stop() {
        isSetting = true
        timerAlert = false
    }
    
    mutating func cancel() {
        isSetting = true
    }
    
    mutating func repeatTimer() {
        timeRemaining = timeAmount
        start()
    }
    
    mutating func start() {
        startTime = Date()
        isSetting = false
        isPaused = false
    }
    
    mutating func setTimer(h hours: Int, m minutes: Int, s seconds: Int) {
        timeAmount = getSeconds(h: hours, m: minutes, s: seconds)
        timeRemaining = timeAmount
        start()
    }
    
    mutating func count() {
        if self.timeRemaining > -1 && !isPaused {
            self.timeRemaining -= 1
        }
    }
    
}

extension Int {
    // ints in seconds to hours:min:sec format
//    func timeFormat(bloatVar: Int) -> String {
    func timeFormat() -> String {

        let secInHour =  3600.0
        let secInMin = 60.0
        
//        var remainder = Double(self / bloatVar)
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
