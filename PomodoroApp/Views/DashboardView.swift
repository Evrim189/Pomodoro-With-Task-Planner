//
//  DashboardView.swift
//  PomodoroApp
//
//  Created by Evrim Tuncel on 10.05.2023.
//

import SwiftUI

struct DashboardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext)  var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MyTasks.timestamp, ascending: false)],
        predicate: NSPredicate(format: "status == 2"),
        animation: .default)
    private var items: FetchedResults<MyTasks>
    var allTaskCount:Int
    var taskBgcolor =  Color(red: 242/255, green: 242/255, blue: 247/255,opacity: 10 / 100)
    var buttonBgcolor =  Color(red: 255/255, green: 114/255, blue: 94/255)
    var doneTaskBgcolor =  Color(red: 152/255, green: 216/255, blue: 170/255)
    var body: some View {
        VStack{
            
            CircleProgressView(progress: Double(100*items.count/allTaskCount))
            
            
            Text("Your Completed Tasks").font(Font.system(size: 20, weight: .bold, design: .rounded))
                .kerning(-0.11)
                .foregroundColor(buttonBgcolor)
                .multilineTextAlignment(.center)
                .padding(.top)
            List(items){ task in
               
//                task.status == 2 yani done
                
                    
                    RoundedRectangle(cornerRadius: 10).foregroundColor(taskBgcolor).padding([.leading, .trailing],10)
                        .overlay(
                            HStack{
                                Text(" \(task.taskName ?? "TaskName") ").foregroundColor(colorScheme == .light ? Color.black : Color.white).padding(.leading,15)
                                Spacer()
                                Image(systemName: "checkmark.seal.fill").resizable().aspectRatio( contentMode: .fit).frame(width: 35).foregroundColor(doneTaskBgcolor).padding(.trailing,15)
                            }
                        )
                        .frame(width:350,height: 50)
                
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView( allTaskCount: 1)
    }
}
