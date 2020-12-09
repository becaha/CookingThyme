//
//  TimerView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/8/20.
//

import SwiftUI

//TODO let flick happen with hour/min/sec picker
struct TimerView: View {
    @State private var isActive = true
    
    @EnvironmentObject var timer: TimerHandler
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    if timer.isSetting {
                        SetTimer(width: geometry.size.width/9)
                    }
                    else {
                        Countdown()
                    }
                }
                .position(x: geometry.size.width/2, y: geometry.size.height/2)
                
            }
            .onReceive(timer.timer) { time in
                timer.count()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                self.isActive = false
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                self.isActive = true
                timer.updateTimeRemaining()
            }
        }
    }
    
    @ViewBuilder
    func Countdown() -> some View {
        VStack {
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 5)
                    .frame(width: 350, height: 350)
                    .padding()
                
                Text("\(timer.timeRemainingString)")
                    .font(.system(size: 80))
            }
            
            Spacer()
                .frame(height: 70)
            
            HStack {
                Spacer()

                TimerButton("Cancel", action : {
                    timer.cancel()
                })
                
                Spacer()
                
                TimerButton(timer.isPaused ? "Resume" : "Pause", action : {
                    timer.pause()
                })
                
                Spacer()
            }

        }
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
                timer.setTimer(h: hours, m: minutes, s: seconds)
                timer.start()
            })
            .disabled(hours == 0 && minutes == 0 && seconds == 0)
        }
    }
    
    @ViewBuilder
    func TimerButton(_ text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(formBackgroundColor())
                    .frame(width: 100, height: 55)
                
                Text("\(text)")
            }
        }
    }
    
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
