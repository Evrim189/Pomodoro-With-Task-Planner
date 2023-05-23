//
//  PomodoroTimerView.swift
//  PomodoroApp
//
//  Created by Evrim Tuncel on 5.05.2023.
//


import SwiftUI
import AVFoundation

struct PomodoroTimerView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.colorScheme) private var colorScheme

    var taskName:String
//    1500 olacak
    @State var secondsRemaining = 10
    @State private var countdownTimer = RepeatingTimer(timeInterval: 1.0)
    @State var isWorking = false
    @State var buttonStart = true
    @State var showSureAlert = false
    @State var workSessions = 0
    @State var breakSessions = 0
    var buttonBgcolor =  Color(red: 255/255, green: 114/255, blue: 94/255)
    let impact = UIImpactFeedbackGenerator()
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                VStack {
                    
                    Text(self.isWorking ? (self.breakTime().title) : "25 Minute Pomodoro ")
                        .font(Font.system(size: 30, weight: .bold, design: .rounded))
                        .kerning(-0.11)
                        .foregroundColor(buttonBgcolor)
                        .multilineTextAlignment(.center)
                        .padding(.top)

                    Spacer()

                    Text("\(secondsToMinutesSeconds(seconds: self.secondsRemaining))")
                        .font(Font.system(size: 50, weight: .bold, design: .rounded))
                        .kerning(-0.17)
                        .multilineTextAlignment(.center)
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Button(action: {
                            self.impact.impactOccurred(intensity: 1.0)
//                            default buttonStart true = sayac baslat
                            if self.buttonStart {
                                self.buttonStart.toggle()
//                                calism,a pushu 10 sn den basladi
                                schedulePush(value: secondsRemaining, taskName: taskName, isBreak: false)
                                self.countdownTimer.eventHandler = {

                                  
                                    self.secondsRemaining -= 1
                                    
                                    if self.secondsRemaining == 0 {
//                                       AudioServicesPlayAlertSound(SystemSoundID(1005))
                                        
                                        self.isWorking.toggle()
                                        if self.isWorking == false {
                                            self.breakSessions += 1
                                            self.secondsRemaining = 10
////                                            2. tur calisma basladi
//                                            schedulePush(value: secondsRemaining, taskName: taskName, isBreak: false)

                                        } else {

                                            self.workSessions += 1
                                            self.secondsRemaining = Int(self.breakTime().seconds)
//                                            ilk ara
                                            schedulePush(value: secondsRemaining, taskName: taskName, isBreak: true)

                                        }
                                    }
                                }
                                self.countdownTimer.resume()
                            } else {
//                                buttonStart  false sayac durdur
                                
                              
//                                if self.buttonText() == "End Break" {
////                                    timer calisiyor ve buttona tiklandiginda sureyi manuel tammalamis olacak.
//                                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//                                    self.secondsRemaining = 1
//                                    self.isWorking = false
//                                    self.buttonStart = true
//                                    self.secondsRemaining = 10
//                                }
//                                    else {
//                                        buttonText() == "End Session" timer duracak
                                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

                                        self.isWorking = false
                                        self.buttonStart = true
                                        self.secondsRemaining = secondsRemaining
                                        workSessions += 1
                                    self.countdownTimer.suspend()
//                                }
                            }
                        }) {
                            RoundedRectangle(cornerRadius: 10).foregroundColor(buttonBgcolor)
                            //                    .aspectRatio( contentMode: .fit)
                                .frame(width:300,height: 60)
                                .overlay(HStack(alignment:.center){
                                  Text(self.buttonText())
                                        .font(Font.system(.headline, design: .rounded)
                                        .lowercaseSmallCaps()
                                    )
                                        .fontWeight(.bold)
                                    .foregroundColor(Color.white)
        //                                .padding(.top)
                                })
                            
                        }
                        .frame(height: 50)
                        .shadow(color: colorScheme == .light ? Color.black.opacity(0.1) : Color.white.opacity(0.1), radius: 5, x: 0, y: 10)
                        
                        Button(action: {
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            presentationMode.wrappedValue.dismiss()
                            AnalyticsHelper.shared.logEvent(name: "Cancel_ButtonClick")
                        }, label: {
                            RoundedRectangle(cornerRadius: 10).foregroundColor(buttonBgcolor)
                            //                    .aspectRatio( contentMode: .fit)
                                .frame(width:300,height: 60)
                                .overlay(HStack(alignment:.center){
                                    Text("Cancel")
                                        .font(Font.system(.headline, design: .rounded)
                                        .lowercaseSmallCaps()
                                    )
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
        //                                .padding(.top)
                                })
                        })
                    }
                    .padding(.horizontal, geometry.size.width / 10)
                    Spacer()
                }
                
                Spacer()
            }

        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            NotificationManager.shared.checkPushNotification()
        }

        
    }
    

    func buttonText() -> String {
       
//        if !isWorking {
            return (self.buttonStart ? "Start Session" : "Stop Session")
//        }
//        else {
////            isWorking = true
//            return (self.buttonStart ? "End Session" : "End Break")
//        }
    }
    
    func breakTime() -> (title: String, seconds: Double) {
        // Differentiate between the 5 minute break or the 30 minute break
        if workSessions % 4 == 0 {
//            return (title: "30 Minute Break", seconds: 1800)
            return (title: "30 Minute Break", seconds: 8)

            
        } else {
//            return (title: "5 Minute Break", seconds: 300)
            return (title: "5 Minute Break", seconds: 5)
        }
    }
    func schedulePush(value: Int,taskName:String,isBreak:Bool){
        
        let content = UNMutableNotificationContent()
        content.title = isBreak == false ? "Focus with Pomodoro Completed!" : "Break Finish!"
        content.body = isBreak == false ? "\(taskName)" : ""
       
        let calendar = Calendar.current
        let nextTriggerDate = calendar.date(byAdding: .second, value: value, to:Date() )
        let dateComponents = Calendar.current.dateComponents([ .hour, .minute,.second], from: nextTriggerDate!)
print("date components",dateComponents)
     
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
           }
        }
        
    }

}

struct PomodoroTimerView_Previews: PreviewProvider {
    static var previews: some View {
      
            PomodoroTimerView(
//                showView: .constant(false)
                taskName: "task name")
//            .environment(\.locale, Locale(identifier: "es"))

    }
}

// Seconds Formatting Function
func secondsToMinutesSeconds(seconds : Int) -> String {
    return "\(String(format: "%02d", ((seconds % 3600) / 60))):\(String(format: "%02d", ((seconds % 3600) % 60)))"
}

//class RepeatingTimer {
//
//    let timeInterval: TimeInterval
//    
//    init(timeInterval: TimeInterval) {
//        self.timeInterval = timeInterval
//    }
//    
//    private lazy var timer: DispatchSourceTimer = {
//        let t = DispatchSource.makeTimerSource()
//        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
//        t.setEventHandler(handler: { [weak self] in
//            self?.eventHandler?()
//        })
//        return t
//    }()
//
//    var eventHandler: (() -> Void)?
//
//    private enum State {
//        case suspended
//        case resumed
//    }
//
//    private var state: State = .suspended
//
//    deinit {
//        timer.setEventHandler {}
//        timer.cancel()
//        /*
//         If the timer is suspended, calling cancel without resuming
//         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
//         */
//        resume()
//        eventHandler = nil
//    }
//
//    func resume() {
//        if state == .resumed {
//            return
//        }
//        state = .resumed
//        timer.resume()
//    }
//
//    func suspend() {
//        if state == .suspended {
//            return
//        }
//        state = .suspended
//        timer.suspend()
//    }
//}
