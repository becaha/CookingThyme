//
//  TimerHandler.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/8/20.
//

import Foundation

class TimerHandler: ObservableObject {
    @Published var timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    @Published var simpleTimer = SimpleTimer()
    
    init() {}
    
    // MARK: - Access
    
    var timeRemainingString: String {
        simpleTimer.timeRemainingString
    }
    
    var timeRemaining: Double {
        Double(simpleTimer.timeRemaining)
    }
    
    var timeRemainingRatio: Double {
        simpleTimer.timeRemainingRatio
    }
    
    var isPaused: Bool {
        simpleTimer.isPaused
    }
    
    var isSetting: Bool {
        simpleTimer.isSetting
    }
    
    var timerAlert: Bool {
        get { simpleTimer.timerAlert }
        set { simpleTimer.timerAlert = newValue }
    }
    
    
    // MARK: - Intents
    
    func pause() {
        simpleTimer.pause()
    }
    
    func stop() {
        simpleTimer.stop()
    }
    
    func cancel() {
        simpleTimer.cancel()
    }
    
    func repeatTimer() {
        simpleTimer.repeatTimer()
    }
    
    func setTimer(h hours: Int, m minutes: Int, s seconds: Int) {
        simpleTimer.setTimer(h: hours, m: minutes, s: seconds)
    }
  
    func count() {
        simpleTimer.count()
    }
}
