//
//  PopodoroPage.swift
//  PomodoroApp
//
//  Created by Evrim Tuncel on 2.05.2023.
//

import SwiftUI

struct PomodoroPage: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext)  var viewContext
    @Environment(\.colorScheme) private var colorScheme
    
    public enum Status: Int
    {
        case created, start,done
    }
    
    @Binding var selectedTask: MyTasks?
    @Binding var taskStatus:Int32
    @State private var countdownTimer = RepeatingTimer(timeInterval: 1.0)

    var buttonBgcolor =  Color(red: 255/255, green: 114/255, blue: 94/255)
    
//    Alert varibles
@State var showSureAlert = false
    @State var showMoveDoneTaskAlert = false
    
//    Timer varibles
    @State var isWorking = false
    @State var secondsRemaining = 1500
  
    var body: some View {
        
        ZStack{
            
            VStack{
                
                

                
                Text("\(selectedTask?.taskName ?? "Focus")").font(Font.system(size: 30, weight: .bold, design: .rounded))
                    .kerning(-0.11)
                    .foregroundColor(buttonBgcolor)
                    .multilineTextAlignment(.center)
                    .padding(.top,30)
                
//                CountDownView()
                Spacer()
                Text("\(secondsToMinutesSeconds(seconds: self.secondsRemaining))")
                    .font(Font.system(size: 50, weight: .bold, design: .rounded))
                    .kerning(-0.17)
                    .multilineTextAlignment(.center)
               
                
                HStack{
                    
                Button(action: {
                    
                    AnalyticsHelper.shared.logEvent(name: "pomodoro_canceled")
                        showSureAlert = true
                    
                   
                }, label: {RoundedRectangle(cornerRadius: 10).foregroundColor(buttonBgcolor)
                    //                    .aspectRatio( contentMode: .fit)
                        .frame(width:150,height: 50)
                        .overlay(
                         
                            Text("Cancel").font(Font.system(.headline, design: .rounded)
                                .lowercaseSmallCaps()
                            )
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                        )
                }).padding()
                        .alert(isPresented: $showSureAlert) {
                            Alert(
                                title: Text("Are you sure you want to cancel pomodoro timer?"),
                                primaryButton: .destructive(Text("Yes")) {
//                                    Schedule edilmis tum local push lari sildik.
                                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                    presentationMode.wrappedValue.dismiss()
                                },
                                secondaryButton: .cancel()
                            )
                            
                        }
                    
                    Button(action: {
                        if isWorking{
//                            Stop
                            AnalyticsHelper.shared.logEvent(name: "timer_stoped")
//                            cancel all push
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            isWorking.toggle()
                            self.secondsRemaining = secondsRemaining
                            self.countdownTimer.suspend()
                            
                        }else{
//                            start
                            AnalyticsHelper.shared.logEvent(name: "timer_started")
//                            send push
                            schedulePush(value: secondsRemaining, taskName: selectedTask?.taskName ?? "", isBreak: false)
                            
                            isWorking.toggle()
                            self.countdownTimer.eventHandler = {
                                
                                
                                self.secondsRemaining -= 1
                                
                                if self.secondsRemaining == 0 {
                                    
                                    isWorking.toggle()
                             

                                    
                                    self.secondsRemaining = 1500
//                                    timer stop
                                    self.countdownTimer.suspend()
                                    showMoveDoneTaskAlert = true
                                }
                            }
                            
                            self.countdownTimer.resume()
                        }
    
                        
                    }, label: {RoundedRectangle(cornerRadius: 10).foregroundColor(buttonBgcolor)
                        //                    .aspectRatio( contentMode: .fit)
                            .frame(width:150,height: 50)
                            .overlay(
                              
                                Text(isWorking == true ? "Stop" : "Start").font(Font.system(.headline, design: .rounded)
                                    .lowercaseSmallCaps()
                                )
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                            )
                    }).padding()
                        .alert(isPresented: $showMoveDoneTaskAlert) {
                           Alert(
                               title: Text("Do you want to update this task's status with DONE? "),
                               primaryButton: .destructive(Text("Yes")) {
                           //                                    Schedule edilmis tum local push lari sildik.
                                   
                                   UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                   selectedTask?.status = Int32(Status.done.rawValue)
                                   do {
                                       try viewContext.save()
                                   } catch {
                                       AlertManager.shared.showAlert(message: "Sorry! Please try again.")
                                   }
                                   
                                  
                                   
                                   DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                                       presentationMode.wrappedValue.dismiss()

                                   })

                                   
                               },
                               secondaryButton: .cancel()
                           )

                           }

                    
                }
          
                
                Spacer()
            }
//            if showMoveDoneTaskAlert{


//                                }
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
                NotificationManager.shared.checkPushNotification()
 
            }
        }
        
    }
    func secondsToMinutesSeconds(seconds : Int) -> String {
        return "\(String(format: "%02d", ((seconds % 3600) / 60))):\(String(format: "%02d", ((seconds % 3600) % 60)))"
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

//struct PomodoroPage_Previews: PreviewProvider {
//    static var previews: some View {
//        PomodoroPage(taskName: "SELECTED TASK NAME")
//    }
//}
class RepeatingTimer {

    let timeInterval: TimeInterval
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()

    var eventHandler: (() -> Void)?

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }

    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }

    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}

