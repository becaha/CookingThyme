//
//  Border.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/4/20.
//

import SwiftUI

// TODO: make perfect
// for a nice dashed or not dashed border
struct Border: ViewModifier {
    var color: Color
    var lineWidth: CGFloat
    var isDashed: Bool
    
    init(_ color: Color, width: CGFloat, isDashed: Bool) {
        self.color = color
        self.isDashed = isDashed
        self.lineWidth = width
    }
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(color, style: getStrokeStyle(geometry.size))
                    .padding(lineWidth)
                
                content
            }
        }
    }
    
    func getStrokeStyle(_ size: CGSize) -> StrokeStyle {
        if isDashed {
            let dash = getDash(size: size)
            return StrokeStyle(lineWidth: lineWidth,
                                           lineCap: .round,
                                           lineJoin: .miter,
                                           miterLimit: 0,
                                           dash: dash, dashPhase: 0)
        }
        else {
            return StrokeStyle(lineWidth: lineWidth)
        }
    }
    
    // has to have (_ _ ) pattern
    func getDash(size: CGSize) -> [CGFloat] {
        let perimeter: CGFloat = CGFloat(size.width * 2) + CGFloat(size.height * 2)
        var dashLength: CGFloat = 5.0
        var amount: CGFloat = CGFloat(Int(perimeter / dashLength))
        if amount.truncatingRemainder(dividingBy: 2) != 0 {
            amount -= 1
        }
        dashLength = perimeter / amount
        return [dashLength]
    }
}

struct Border_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hi").border(Color.blue, width: 3.0, isDashed: true)
            .frame(width: 100, height: 100, alignment: .center)
            .padding()
    }
}

extension View {
    func border(_ color: Color, width: CGFloat, isDashed: Bool) -> some View {
        modifier(Border(color, width: width, isDashed: isDashed))
    }
}
