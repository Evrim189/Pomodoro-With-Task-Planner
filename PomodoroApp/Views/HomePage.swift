//
//  HomePage.swift
//  PomodoroApp
//
//  Created by Evrim Tuncel on 2.05.2023.
//

import SwiftUI
import SafariServices
import Firebase

struct HomePage: View {
    var showSpotlight:Bool
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext)  var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MyTasks.timestamp, ascending: false)],
//        predicate: NSPredicate(format: "status == 0"),
        animation: .default)
    private var items: FetchedResults<MyTasks>
    
    
    public enum Status: Int
    {
        case created, start,done
    }
    @State var selectedTask: MyTasks?
    @State var showAlertForDelete = false
    @State var willBeDeletedItem: MyTasks?
    @State var taskName:String = ""
    @State var taskStatus:Int32 = 0

    
    @State var taskDetail:String = ""
    @State var openSafari = false
    @State var openDashboard = false
//    @State var showSpotlight:Bool = true
//    @State var currentSpot:Int = 0
    
    @State var pomoURL = "https://en.wikipedia.org/wiki/Pomodoro_Technique"

    var taskBgcolor =  Color(red: 242/255, green: 242/255, blue: 247/255,opacity: 10 / 100)
    var buttonBgcolor =  Color(red: 255/255, green: 114/255, blue: 94/255)
    var doneTaskBgcolor =  Color(red: 152/255, green: 216/255, blue: 170/255)
    
    
    enum FullScreenCoverType: Hashable, Identifiable {
      case openPomodoroPage,taskDetail
      
      var id: FullScreenCoverType { self }
    }
    @State var fullScreenCoverState: FullScreenCoverType?
    
    var body: some View {
        
        
        VStack{
            VStack{
                NavigationLink(isActive: $openDashboard, destination: {DashboardView( allTaskCount: items.count == 0 ? 1 : items.count ).environment(\.managedObjectContext, viewContext)}, label: {Text("")})
                
                
                Text("A simple and effective way to help you stay focused").font(Font.footnote)
                Spacer()
                if items.count == 0 {
                    Spacer()
                    Image("HomePageImage").resizable().aspectRatio( contentMode: .fit).padding(.all,30)
                    //                    Text("You didn't create any task.").foregroundColor(buttonBgcolor)
                    Spacer()
                }else{
                    
                    List(items){ task in
                        
                        if task.status == 0{
                            
                            //                            Text("\(task.status)")
                            RoundedRectangle(cornerRadius: 10).foregroundColor(task.status == 0 ?  taskBgcolor : doneTaskBgcolor).padding([.leading, .trailing],10)
                                .overlay{
                                    
                                    
                                    Menu{
                                        Button(action: {
                                            selectedTask = task
                                            alertToGetCollectionName(taskName: task.taskName)
                                        }) {
                                            Label("Rename", systemImage: "pencil.circle.fill")
                                        }
                                        Button(action: {
                                            selectedTask = task
                                            taskName = task.taskName ?? ""
                                            taskDetail = task.taskDetail ?? ""
                                            fullScreenCoverState = .taskDetail
                                        }) {
                                            Label("Add Detail", systemImage: "rectangle.and.pencil.and.ellipsis")
                                        }
                                        
                                        Button(action: {
                                            willBeDeletedItem = task
                                            showAlertForDelete = true
                                        }) {
                                            Label("Delete", systemImage: "trash.fill")
                                        }
                                        
                                        
                                        Button(action: {
                                           selectedTask = task
                                            taskName = task.taskName ?? ""
                                            taskStatus = Int32(task.status )
                                           
                                            fullScreenCoverState = .openPomodoroPage
                                        }) {
                                            Label("Start Pomodoro", systemImage: "timer")
                                        }
                                        
                                        Button(action: {
                                            task.status = Int32(Status.done.rawValue)
                                            try? viewContext.save()
                                            
                                            
                                        }) {
                                            Label("Done", systemImage: "checkmark.seal.fill")
                                        }
                                        
                                        
                                    } label: {
                                        HStack{
                                            Text(" \(task.taskName ?? "TaskName") ").foregroundColor(colorScheme == .light ? Color.black : Color.white).padding(.leading,15)
                                            Spacer()
                                            Image(systemName: "ellipsis.circle").resizable().aspectRatio( contentMode: .fit).frame(width: 30).foregroundColor(buttonBgcolor)
                                            
                                            //
                                        }
                                        
                                        
                                    }
                                    .padding(.trailing,15)
                                    
                                }
                                .frame(width:350,height: 50)
                            
                                .alert(isPresented: $showAlertForDelete) {
                                    Alert(
                                        title: Text("Are you sure you want to delete?"),
                                        primaryButton: .destructive(Text("Delete")) {
                                            
                                            if let willBeDeletedItem = willBeDeletedItem
                                            {
                                                viewContext.delete(willBeDeletedItem)
                                                try? viewContext.save()
                                            }
                                            
                                        },
                                        secondaryButton: .cancel()
                                    )
                                    
                                }
                        }
                        
                        
                        
                        
                    }
                    
                    
                }
                
                
                Button {
                    selectedTask = nil
                    alertToGetCollectionName(taskName: "")
                    AnalyticsHelper.shared.logEvent(name: "CreateNewTask_ButtonClick")
                } label: {
                    RoundedRectangle(cornerRadius: 10).foregroundColor(buttonBgcolor)
                    //                    .aspectRatio( contentMode: .fit)
                        .frame(width:300,height: 60)
                        .overlay(HStack(alignment:.center){
                            Image(systemName: "plus.app").foregroundColor(Color.white).fontWeight(.bold)
                            Text("Create New Task")
                                .font(Font.system( .headline, design: .rounded)
                                .lowercaseSmallCaps()
                            )
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                            //                                .padding(.top)
                        })
                    
                }.if(showSpotlight, transform: { view in
                    view.addSpotlight(0, shape: .rectangle, roundedRadius: 10, text: "Add tasks")
                        .padding()
                })
                
                
            }.navigationBarTitle("Pomodoro")
                .toolbar{
                    
                    ToolbarItem(placement:.navigationBarLeading){
                        Button(action: {openDashboard = true
                            AnalyticsHelper.shared.logEvent(name: "Dasboard_ButtonClick")
                        }, label: {
                            HStack{
                                Image(systemName: "face.dashed.fill").resizable().frame(width:30,height: 30).foregroundColor(colorScheme == .light ? buttonBgcolor : Color.white).fontWeight(.bold)
                                    .addSpotlight(1, shape: .circle, text: "Track Your Progress")
                                //                                Text("Dashboard").font(Font.system(.headline, design: .rounded)
                                //                                    .lowercaseSmallCaps()
                                //                                ).fontWeight(.bold).foregroundColor(buttonBgcolor)
                            }
                            
                        })
                        
                    }
                    
                    ToolbarItem(placement:.navigationBarTrailing){
                        Button(action: {openSafari = true
                            AnalyticsHelper.shared.logEvent(name: "AboutWikipedi_ButtonClick")
                        }, label: {
                            Image(systemName: "questionmark.circle.fill").resizable().frame(width:30,height: 30).foregroundColor(colorScheme == .light ? buttonBgcolor : Color.white).fontWeight(.bold)
                                .addSpotlight(2, shape: .rectangle, roundedRadius: 10, text: "About Pomodoro Technique")
                            
                            
                            
                            //                            Text("About").foregroundColor(buttonBgcolor)
                            
                        })
                        
                    }
                    
                    
                    
                }
            
                .sheet(isPresented: $openSafari, content: {
                    SafariView(url: URL(string: self.pomoURL)!)
                    
                })
                .fullScreenCover(item: $fullScreenCoverState, onDismiss: {
                    print("pomodoro_dismiss")
                    
                }, content: {item in
                    if item == .openPomodoroPage{
//                        PomodoroTimerView(taskName: selectedTask?.taskName ?? "")
                        PomodoroPage(selectedTask: $selectedTask, taskStatus: $taskStatus )
                        
                    }else if item == .taskDetail{
                        
                        TaskDetailView(selectedTask: $selectedTask, taskName: $taskName, taskDetail: $taskDetail)
                    }
                    
                    
                })
            
        }
//        .addSpotlightOverlay(show: $showSpotlight, currentSpot: $currentSpot)
    }
    
    
     func addItem() {
        withAnimation {
            let newItem = MyTasks(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func showAlert(alert: UIAlertController) {
        if let controller =   UIApplication.shared.mainKeyWindow?.rootViewController
 {
            controller.present(alert, animated: true)
        }
    }
    
    func alertToGetCollectionName(taskName:String?) {
       let alert = UIAlertController(title: "Task Title", message: "", preferredStyle: .alert)
       alert.addTextField() { textField in
           textField.placeholder = taskName == nil ? "Enter task name" : "\(taskName)"
       }
       alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in })
       alert.addAction(UIAlertAction(title: "OK", style: .default ) { test in
           if let name = alert.textFields?.first?.text
           {
               if selectedTask == nil{
                   PersistenceController.shared.addItem(name: name)
               }else{
                   selectedTask?.taskName = name
                   
                   try? viewContext.save()
                   
                   AnalyticsHelper.shared.logEvent(name: "saved_task:\(name)")
               }
                  
              
               
               
               
               
           }
           
           
       })
       
       showAlert(alert: alert)
   }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage( showSpotlight: false, taskDetail: "")
    }
}

struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }

}

