//
//  ContentView.swift
//  Shared
//
//  Created by Robert Booth on 2/17/22.
//

import SwiftUI

struct ContentView: View {
    @State var buttonPressed = false
    @State var showCountdown = false

    @ObservedObject var countdownTimer = CountdownTimer(limitTimeInterval: 5.0)
    @ObservedObject var bombList = BombList()

    func makeView(_ geometry: GeometryProxy) -> some View {
        bombList.maxX = geometry.size.width
        bombList.maxY = geometry.size.height
        return Color.clear
    }

    private func bombColor(ratioRemaining: Double) -> Color {
        let red = 1.0 - ratioRemaining
        let green = 0.0
        let blue = ratioRemaining
        return Color.init(red: red, green: green, blue: blue)
    }

    var body: some View {
        if bombList.anyBombsExploded || countdownTimer.portionFull <= 0.0 {
            bombList.running = false
            countdownTimer.reset()
        }
        return NavigationView {
            VStack {
                /*
                ProgressView("Detonating in… \(countdownTimer.formattedDuration)", value: 5.0 - countdownTimer.counter, total: 5.0)
                    .frame(height: 20)
                    .opacity(showCountdown ? 1 : 0)
                    .animation(Animation.linear, value: countdownTimer.counter)
                 */
                VStack {
                    Text(String(format: "Survived %.01f seconds", bombList.elapsedTime))
                    Text("Disarmed \(bombList.numberBombsDisarmed) bomb" + ((bombList.numberBombsDisarmed == 1) ? "" : "s"))
                }
 
                Spacer()
                
                ZStack {
                    ForEach($bombList.bombs, id: \.id) { $bomb in
                        Button {
                            // check to make sure not holding down deadswitch and tapping bomb simulatneously
                            if !buttonPressed {
                                bombList.remove(bomb)
                            }
                        } label: {
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(Color.init(red: 1.0 - bomb.ratioRemaining, green: 0.0, blue: bomb.ratioRemaining))
                                Image(systemName: "xmark.circle")
                                    .foregroundColor((bomb.ratioRemaining > 0.0) ? Color.clear : .black)
                            }
                            .scaleEffect(bomb.ratioRemaining > 0.0 ? 1.0 : 3.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: bomb.ratioRemaining)
                        }
                        .position(x: bomb.x, y: bomb.y)
                    }
                    GeometryReader { geometryProxy in
                        self.makeView(geometryProxy)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()

                ZStack {
                    Image(systemName: "burst.fill")
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)
                        .background(countdownTimer.portionFull > 0.0 ? (buttonPressed ? .green : .red) : .black)
                        .mask(Circle())
                        .scaleEffect(buttonPressed ? 1.3 : 1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: buttonPressed)
                        .modifier(TouchDownUpEventModifier(changeState: { (buttonState) in
                            if buttonState == .pressed {
                                buttonPressed = true
                                countdownTimer.recover()
                                bombList.running = true
                            } else {
                                buttonPressed = false
                                countdownTimer.run()
                            }
                        }))
                    GaugeView(middleAngle: 0.0, maxAngle: 180.0, fullRatio: $countdownTimer.portionFull)
                }
            }
            //.background(bombList.anyBombsExploded || countdownTimer.portionFull <= 0.0 ? Color.gray : Color.clear)
            .navigationTitle("DeadMan Switch!")
        }
    }
}

// MARK: - PreviewProvider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
