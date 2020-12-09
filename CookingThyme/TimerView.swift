//
//  TimerView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/8/20.
//

import SwiftUI

//TODO let flick happen with hour/min/sec picker
// TODO flashes when stoppedon other screen and you go to timer
struct TimerView: View {
    @EnvironmentObject var timer: TimerHandler
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    @State private var animatedTimeRemaining = 0.0
    
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
        }
    }
    
    @ViewBuilder
    func Countdown() -> some View {
        VStack {
            ZStack {
                Group {
                    if !timer.isPaused {
                        AnimatableCircleStroke(startAngle: angle(for: 0), endAngle: angle(for: -animatedTimeRemaining), clockwise: true)
                            .onAppear() {
                                startTimeAnimation()
                            }
                    }
                    else {
                        AnimatableCircleStroke(startAngle: angle(for: 0), endAngle: angle(for: -timer.timeRemainingRatio), clockwise: true)
                    }
                }
                .foregroundColor(mainColor())
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
                    withAnimation {
                        timer.cancel()
                    }
                })
                
                Spacer()
                
                TimerButton(timer.isPaused && !timer.timerAlert ? "Resume" : "Pause", action : {
                    timer.pause()
                })
                .transition(.scale(scale: 1))
                
                Spacer()
            }

        }
    }
    
    private func angle(for degrees: Double) -> Angle {
        Angle.degrees(degrees * 360 - 90)
    }
    
    func startTimeAnimation() {
        animatedTimeRemaining = timer.timeRemainingRatio
        withAnimation(.linear(duration: timer.timeRemaining)) {
            animatedTimeRemaining = 0
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
                withAnimation {
                    timer.setTimer(h: hours, m: minutes, s: seconds)
                }
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
