//
//  TimerView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/8/20.
//

import SwiftUI

struct TimerView: View {
    @State private var isActive = true
    @State private var timeRemaining: Int = 0
    @State private var timeRemainingString: String = ""
    @State private var countdownTime: Int?
    @State private var startTime: Date?
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    @State private var isSetting = false
    @State private var isPaused = false

    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    if isSetting {
                        SetTimer(width: geometry.size.width/9)
                    }
                    else {
                        Countdown()
                    }
                }
                .position(x: geometry.size.width/2, y: geometry.size.height/2)
                
            }
            .onReceive(timer) { time in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                    timeRemainingString = timeRemaining.timeFormat()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                self.isActive = false
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                self.isActive = true
                if let startTime = self.startTime {
                    let timeElapsed = Date().timeIntervalSince(startTime)
                    timeRemaining -= Int(timeElapsed)
                    timeRemainingString = timeRemaining.timeFormat()
                }
            }
        }
    }
    
    @ViewBuilder
    func Countdown() -> some View {
        VStack {
            Text("\(timeRemainingString)")
            
            TimerButton(isPaused ? "Resume" : "Pause", action : {
                isPaused.toggle()
            })
            
            TimerButton("Cancel", action : {
                isSetting = true
            })

        }
    }
    
    func getSeconds(h hours: Int, m minutes: Int, s seconds: Int) -> Int {
        let secInHour =  3600
        let secInMin = 60
        return (hours * secInHour) + (minutes * secInMin) + seconds
    }
    
    @ViewBuilder
    func SetTimer(width: CGFloat) -> some View {
        VStack {
            ZStack {
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Picker("\(hours) hours", selection: $hours)
                        {
                            ForEach(0..<24, id: \.self) { num in
                                Text("\(num)").tag(num)
                            }
                        }
                        .frame(width: width)
                        
                        Text("hours")
                    }
                    .clipped()

                    HStack(spacing: 0) {
                        Picker(selection: $minutes, label: Text("\(minutes) min"))
                        {
                            ForEach(0..<60, id: \.self) { num in
                                Text("\(num)").tag(num)
                            }
                        }
                        .frame(width: width)
                        
                        Text("min")
                    }
                    .clipped()
                    

                    HStack(spacing: 0) {
                        Picker(selection: $seconds, label: Text("\(seconds) sec"))
                        {
                            ForEach(0..<60, id: \.self) { num in
                                Text("\(num)").tag(num)
                            }
                        }
                        .frame(width: width)
                        
                        Text("sec")
                    }
                    .clipped()
                }
                .padding()
            }
            .padding()
            
            TimerButton("Start", action: {
                startTime = Date()
                isSetting = false
                timeRemaining = getSeconds(h: hours, m: minutes, s: seconds)
            })
            .disabled(hours == 0 && minutes == 0 && seconds == 0)
        }
    }
    
    @ViewBuilder
    func TimerButton(_ text: String, action: @escaping () -> Void) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(formBackgroundColor())
            
            Text("\(text)")
                .padding()
        }
        .frame(width: 100, height: 20)
    }
    
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
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
