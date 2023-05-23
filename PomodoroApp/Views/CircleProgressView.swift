//
//  CircleProgressView.swift
//  PomodoroApp
//
//  Created by Evrim Tuncel on 10.05.2023.
//

import SwiftUI

struct CircleProgressView: View {
    var progress:Double
    @Environment(\.colorScheme) private var colorScheme
    var buttonBgcolor =  Color(red: 255/255, green: 114/255, blue: 94/255)
    var taskBgcolor =  Color(red: 242/255, green: 242/255, blue: 247/255,opacity: 10 / 100)

    
    var body: some View {
        ZStack {
            
            Text("% \(String(format: "%.2f", progress))")
            Circle()
                .stroke(lineWidth: 30.0)
                .foregroundColor(colorScheme == .light ? Color.white.opacity(1.0): taskBgcolor).frame(width: 100,height: 100)
            Circle()
                .trim(from: 0.0, to: Double(progress/100))
                .stroke(style: StrokeStyle(lineWidth: (self.progress==0) ? 0.0 : 30.0,lineCap: .round, lineJoin: .round))
                .animation(Animation.linear(duration: 0.2))
                .foregroundColor(colorScheme == .light ? buttonBgcolor : buttonBgcolor)
//                .rotationEffect(Angle(degrees: 270.0))
                .rotationEffect(.degrees(-90))
                
        }
        .frame(width: 100, height: 100)
        .onAppear{
            
        }
    }
}
