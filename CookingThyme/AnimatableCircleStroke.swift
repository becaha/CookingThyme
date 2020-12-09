//
//  AnimatableCircleStroke.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/8/20.
//

import SwiftUI

struct AnimatableCircle: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise = false
    
    var animatableData: AnimatablePair<Double, Double> {
        get {
            AnimatablePair(startAngle.radians, endAngle.radians)
        }
        set {
            startAngle = Angle.radians(newValue.first)
            endAngle = Angle.radians(newValue.second)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let start = CGPoint(
            x: center.x + radius * cos(CGFloat(startAngle.radians)),
            y: center.y + radius * sin(CGFloat(startAngle.radians))
        )
        var p = Path()
        
        p.move(to: start)
        p.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        
        
        return p
    }
}

struct AnimatableCircleStroke: View {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise = false
    
    var body: some View {
        AnimatableCircle(startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
            .stroke(lineWidth: 5)
    }
}

struct AnimatableCircleStroke_Previews: PreviewProvider {
    static var previews: some View {
        AnimatableCircleStroke(startAngle: Angle.degrees(0-90), endAngle: Angle.degrees(60-90), clockwise: true)
//            .foregroundColor(.orange)
//            .opacity(0.4)
    }
}
