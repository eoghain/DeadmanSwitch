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

    var body: some View {
        NavigationView {
            VStack {

                Spacer()

                ProgressView("Detonating in… \(countdownTimer.formattedDuration)", value: 5.0 - countdownTimer.duration, total: 5.0)
                    .frame(height: 20)
                    .opacity(showCountdown ? 1 : 0)

                Spacer()

                Image(systemName: "burst.fill")
                    .foregroundColor(.white)
                    .frame(width: 100, height: 100)
                    .background(buttonPressed ? .green : .red)
                    .mask(Circle())
                    .scaleEffect(buttonPressed ? 2 : 1)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: buttonPressed)
                    .modifier(TouchDownUpEventModifier(changeState: { (buttonState) in
                        if buttonState == .pressed {
                            buttonPressed = true
                            countdownTimer.reset()
                            showCountdown = false
                        } else {
                            buttonPressed = false
                            countdownTimer.start()
                            showCountdown.toggle()
                        }
                    }))

                Spacer()
            }
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
