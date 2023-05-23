//
//  TaskDetailView.swift
//  PomodoroApp
//
//  Created by Evrim Tuncel on 3.05.2023.
//

import SwiftUI

struct TaskDetailView: View {
    @Binding var selectedTask:MyTasks?
   @Binding var taskName:String
   @Binding var taskDetail:String
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext)  var viewContext
    var textBgcolor =  Color(red: 242/255, green: 242/255, blue: 247/255,opacity: 28 / 100)
    var buttonBgcolor =  Color(red: 255/255, green: 114/255, blue: 94/255)
   
    @State var showAlertMessage = false

    var body: some View {
        ZStack{
            VStack{

                HStack(alignment: .center){
                    Text("\(taskName)") .font(Font.system(size: 30, weight: .bold, design: .rounded))
                        .kerning(-0.11)
                        .foregroundColor(buttonBgcolor)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                   
                }
                if taskDetail == ""{
                    HStack{
                        Text("Write your task detail").foregroundColor(Color.gray).font(Font.caption).padding()
                        Spacer()
                    }
                }
                CustomTextEditor().frame(height: 200)
                Spacer()
                Button(action: {
                    AnalyticsHelper.shared.logEvent(name: "Task_Detail_updated")
                    selectedTask?.taskDetail = taskDetail
                    try? viewContext.save()
showAlertMessage = true
                    presentationMode.wrappedValue.dismiss()

                    
                },
                       label: {RoundedRectangle(cornerRadius: 10).foregroundColor(buttonBgcolor)
                    //                    .aspectRatio( contentMode: .fit)
                        .frame(width:300,height: 60)
                        .overlay(HStack{
//                            Image(systemName: "plus.app")
                            Text("Save").font(Font.system(.headline, design: .rounded)
                                .lowercaseSmallCaps()
                            ).fontWeight(.bold)
                            .foregroundColor(Color.white)
                        })
                }).alert(isPresented: $showAlertMessage) {
                Alert(title: Text("Changes saved successfully!"))
                    
                }
            }.padding()
        }
        
        
    }
    
    
    func CustomTextEditor() -> some View {
        
        
        return MultilineTextField(text: $taskDetail)
            .foregroundColor(Color(red: 235 / 255, green: 235 / 255, blue: 231 / 255))
            .padding(.all, 10)
            .padding([.leading,.trailing],5)
            .background(RoundedRectangle(cornerRadius:16).fill(textBgcolor))
        //    .disableAutocorrection(true)
            .overlay( Button(action: {
                self.taskDetail = ""
                hideKeyboard()
            }) {
                Image(systemName: "xmark.circle").foregroundColor(Color.white)
                    .opacity(
                        self.taskDetail == "" ? 0 : 1)
                    .padding([.top,.trailing],10)
            }
                      ,alignment: .topTrailing
                      
            )
            .onChange(of: taskDetail) { string in
                //workaround to lcose keyboar when tapped to done button
                if string.last == "\n"
                {
                    print("Found new line character")
                    taskDetail.removeLast()
                    print(taskDetail)
                    hideKeyboard()
                }
            }
            .introspectTextView { textView in
                textView.backgroundColor = UIColor.clear
                textView.returnKeyType = .done
            }
        
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailView(selectedTask: .constant(nil), taskName: .constant(""), taskDetail: .constant(""))
    }
}


struct MultilineTextField: UIViewRepresentable {
    @Binding var text: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UITextView {
        context.coordinator.textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // update in case the text value has changed, we assume the UIView checks if the value is different before doing any actual work.
        // fortunately UITextView doesn't call its delegate when setting this property (in case of MKMapView, we would need to set our did change closures to nil to prevent infinite loop).
        uiView.text = text

        // since the binding passed in may have changed we need to give a new closure to the coordinator.
        context.coordinator.textDidChange = { newText in
            text = newText
        }
    }
    class Coordinator: NSObject, UITextViewDelegate {
        lazy var textView: UITextView = {
            let textView = UITextView()
            textView.font = .preferredFont(forTextStyle: .body)
            textView.delegate = self
            textView.translatesAutoresizingMaskIntoConstraints = false
//            textView.returnKeyType = .done
            textView.backgroundColor = UIColor(red: 46/255, green: 50/255, blue: 90/255, alpha: 0.80)
            textView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))

            return textView
        }()
        
        var textDidChange: ((String) -> Void)?
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            textDidChange?(textView.text)
        }
        @objc func tapDone(sender: Any) {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
          }
    }
}
