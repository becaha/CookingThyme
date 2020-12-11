//
//  TimerHandler.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/8/20.
//

import Foundation
import Combine

class TimerHandler: ObservableObject {
    @Published var simpleTimer: SimpleTimer
    var step: Double
    var stepCount: Double
    var stepPerSec: Double
    var stepsLeft: Double?
    
    var timerCancellable: AnyCancellable?
    
    init() {
        step = 0.02
        stepCount = 0
        stepPerSec = 1 / step
        simpleTimer = SimpleTimer(step: self.step)
        
        timerCancellable = Timer.publish(every: step, on: .main, in: .common).autoconnect()
            .sink { receiveValue in
                if !self.simpleTimer.isPaused {
                    self.stepCount += 1
                    if self.stepCount == self.stepPerSec {
                        self.simpleTimer.countSec()
                        self.stepCount = 0
                    }
                }
            }
    }
    
    // MARK: - Access
    
    // time remaining formatted to a string for ui
    var timeRemainingString: String {
        simpleTimer.timeRemainingString
    }
    
    var timeRemaining: Double {
        Double(simpleTimer.timeRemaining)
    }
    
    // ratio of time remaining to amount
    var timeRemainingRatio: Double {
        simpleTimer.timeRemainingRatio
    }
    
    var isPaused: Bool {
        simpleTimer.isPaused
    }
    
    // is setting timer
    var isSetting: Bool {
        simpleTimer.isSetting
    }
    
    // alert the user that the timer has gone off
    var timerAlert: Bool {
        get { simpleTimer.timerAlert }
        set { simpleTimer.timerAlert = newValue }
    }
    
    
    // MARK: - Intents
    
    func pause() {
        simpleTimer.updateTimeRemaining(withStepCount: self.stepCount)
        self.stepCount = 0
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
  
    // updates timer by counting one second
    func countSec() {
        simpleTimer.countSec()
    }
    
    // updates time remaining in timer by steps counted
    func updateTimeRemaining(withStepCount stepCount: Double) {
        simpleTimer.updateTimeRemaining(withStepCount: stepCount)
    }
}
