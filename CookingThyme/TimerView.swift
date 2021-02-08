//
//  TimerView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/8/20.
//

import SwiftUI

// TODO flashes when stopped on other screen and you go to timer
struct TimerView: View {
    // portrait or landscape
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    var isLandscape: Bool {
        return horizontalSizeClass == .regular && verticalSizeClass == .compact
    }
    
    @EnvironmentObject var timer: TimerHandler
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    @State private var animatedTimeRemaining = 0.0
    
    @State var buttonFlashOpacity: Double = 0.6
    @State var buttonScale: CGFloat = 0.9

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                
                VStack {
                    Spacer()
                    
                    if timer.isSetting {
                        SetTimer(width: geometry.size.width, height: geometry.size.height)
                    }
                    else {
                        if isLandscape {
                            CountdownLandscape(width: geometry.size.width, height: geometry.size.height)
                        }
                        else {
                            Countdown(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
            }
            .background(formBackgroundColor().edgesIgnoringSafeArea(.all))
        }
    }
    
    @ViewBuilder
    func CountdownLandscape(width: CGFloat, height: CGFloat) -> some View {
        HStack {
            Spacer()
                .frame(width: width / 5)
            
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
                .padding()
                
                Text("\(timer.timeRemainingString)")
                    .font(.system(size: height / 8))
            }
            
            Spacer()
                .frame(width: width / 10)
            
            VStack {
                Spacer()

                TimerButton("Cancel", width: width, height: height, action : {
                    withAnimation {
                        timer.cancel()
                    }
                })
                
//                Spacer()
                
                TimerButton(timer.isPaused && !timer.timerAlert ? "Resume" : "Pause", width: width, height: height, action : {
                    timer.pause()
                })
                .transition(.scale(scale: 1))
                
                Spacer()
            }

            Spacer()
                .frame(width: width / 8)
        }
    }
    
    
    // countdown view of the timer when timer is set and started
    @ViewBuilder
    func Countdown(width: CGFloat, height: CGFloat) -> some View {
        VStack {
            Spacer()
                .frame(height: height / 5)
            
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
                .frame(width: width * 0.8)
                .padding()
                
                Text("\(timer.timeRemainingString)")
                    .font(.system(size: width / 6))
            }
            
            HStack {
                Spacer()

                TimerButton("Cancel", width: width, height: height, action : {
                    withAnimation {
                        timer.cancel()
                    }
                })
                
                Spacer()
                
                TimerButton(timer.isPaused && !timer.timerAlert ? "Resume" : "Pause", width: width, height: height, action : {
                    timer.pause()
                })
                .transition(.scale(scale: 1))
                
                Spacer()
            }

            Spacer()
                .frame(height: height / 5)
        }
    }
    
    // angle for circle time countdown animation
    private func angle(for degrees: Double) -> Angle {
        Angle.degrees(degrees * 360 - 90)
    }
    
    // starts time countdown animation
    func startTimeAnimation() {
        animatedTimeRemaining = timer.timeRemainingRatio
        withAnimation(.linear(duration: timer.timeRemaining)) {
            animatedTimeRemaining = 0
        }
    }
    
    // timer set view, set hours, min, sec
    @ViewBuilder
    func SetTimer(width: CGFloat, height: CGFloat) -> some View {
        VStack {
            Spacer()
            
            ZStack {
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Picker("\(hours) hours", selection: $hours)
                        {
                            ForEach(0..<24, id: \.self) { num in
                                Text("\(num)").tag(num)
                            }
                        }
                        .frame(width: width / 9)
                        
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
                        .frame(width: width / 9)
                        
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
                        .frame(width: width / 9)
                        
                        Text("sec")
                    }
                    .clipped()
                }
                .padding()
            }
            .padding()
            TimerButton("Start", width: width, height: height, action: {
                withAnimation {
                    timer.setTimer(h: hours, m: minutes, s: seconds)
                }
            })
            .disabled(hours == 0 && minutes == 0 && seconds == 0)
            
            Spacer()
        }
    }
    
    // style for timer buttons
    @ViewBuilder
    func TimerButton(_ text: String, width: CGFloat, height: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(formBorderColor())
                    .shadow(color: formBorderColor(), radius: 1)
                
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(UIColor.tertiarySystemFill))


                Text("\(text)")
            }
        }
        .frame(width: width / 4, height: isLandscape ? height / 7 : height / 13)
    }
    
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
