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
    
    var timeRemaining: Double = 0 {
        didSet {
            if timeRemaining <= 0 {
                // time has run out, pause and alert user
                timeRemaining = 0
                isPaused = true
                timerAlert = true
            }
            // every time the time remaining is set, set the string format
            timeRemainingString = Int(round(timeRemaining)).timeFormat()
        }
    }
    
    // ratio of time left versus time amount
    var timeRemainingRatio: Double {
        return timeRemaining > 0 ? timeRemaining / Double(timeAmount) : 0
    }
    
    // the step of publishing accuracy
    var step: Double
    
    init(step: Double) {
        self.step = step
    }
    
    private var startTime: Date?
    private var timeAmount: Int = 0
        
    // gets seconds from given hours, min, sec
    func getSeconds(h hours: Int, m minutes: Int, s seconds: Int) -> Int {
        let secInHour =  3600
        let secInMin = 60
        return (hours * secInHour) + (minutes * secInMin) + seconds
    }
    
    mutating func pause() {
        isPaused.toggle()
        timerAlert = false
    }
    
    mutating func stop() {
        isPaused = true
        isSetting = true
        timerAlert = false
    }
    
    mutating func cancel() {
        isSetting = true
        stop()
    }
    
    mutating func repeatTimer() {
        timeRemaining = Double(timeAmount)
        start()
    }
    
    mutating func start() {
        startTime = Date()
        isSetting = false
        isPaused = false
    }
    
    mutating func setTimer(h hours: Int, m minutes: Int, s seconds: Int) {
        timeAmount = getSeconds(h: hours, m: minutes, s: seconds)
        timeRemaining = Double(timeAmount)
        start()
    }
    
    // counts down the time remaining by one second
    mutating func countSec() {
        if self.timeRemaining > 0 {
            self.timeRemaining -= 1
        }
    }
    
    // updates time remaining by seconds elapsed 
    mutating func updateTimeRemaining(withStepCount stepCount: Double) {
        let secondsElapsed = stepCount * self.step
        self.timeRemaining -= secondsElapsed
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
