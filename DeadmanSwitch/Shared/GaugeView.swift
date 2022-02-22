//
//  GaugeView.swift
//  CircularGauge
//
//  Created by Michael Huovila on 2/21/22.
//

import SwiftUI

struct GaugeView: View {
    let middleAngle: Double // angle (12:00 = 0°, 3:00 = 90°) of middle of gauge in degrees
    let maxAngle: Double // angle of full sized gauge in degrees
    let steperSplit = 0.2
    @Binding var fullRatio: Double

    private var gaugeColor: Color {
        if fullRatio <= 0.5 {
            let red = 1.0
            let green = fullRatio * 2.0
            let blue = 0.0
            return Color.init(red: red, green: green, blue: blue)
        } else {
            let red = 1.0 - (fullRatio - 0.5) * 2.0
            let green = 1.0
            let blue = 0.0
            return Color.init(red: red, green: green, blue: blue)
        }
    }

    private func tick(at tick: Int, totalTicks: Int) -> some View {
        let startAngle = middleAngle - (maxAngle * fullRatio) / 2
        let stepper = steperSplit
        let rotation = Angle.degrees(startAngle + (stepper * Double(tick)) * fullRatio)
        return VStack {
                   Rectangle()
                    .fill(gaugeColor)
                    .frame(width: 0.5, height: 20)
                   Spacer()
           }.rotationEffect(rotation)
    }

    private var tickCount: Int {
        return Int(maxAngle / 2.0 / steperSplit)
    }

    var body: some View {
        ZStack {
            if fullRatio > 0.0 {
                ForEach(0 ..< tickCount * 2 + 1) { tick in
                    self.tick(at: tick,
                              totalTicks: self.tickCount * 2)
                }
            } else {
                Color.clear
            }
        }.frame(width: 200, height: 200, alignment: .center)
    }

}

struct GaugeView_Previews: PreviewProvider {
    @State static private var value = 1.00
    static var previews: some View {
        GaugeView(middleAngle: 0, maxAngle: 180, fullRatio: $value)
    }
}
