//
//  Spotlight.swift
//  PomodoroApp
//
//  Created by Evrim Tuncel on 12.05.2023.
//

import SwiftUI


extension View{
//    New modifierfor adding elements for spotlight preview
    @ViewBuilder
    func addSpotlight(_ id: Int,shape: SpotlightShape = .rectangle, roundedRadius: CGFloat = 5,text:String = "" ) -> some View{
        self
            .anchorPreference(key: BoundsKey.self, value: .bounds) { [id: BoundsKeyProperties(shape: shape, anchor: $0,text:text,radius: roundedRadius)]
            }
    }
    
    @ViewBuilder
    func addSpotlightOverlay(show: Binding<Bool>,currentSpot: Binding<Int>) -> some View{
        self.overlayPreferenceValue(BoundsKey.self){ values in
            GeometryReader{ proxy in
                if let preference = values.first(where: {
                    item in item.key == currentSpot.wrappedValue
                }){
                    let screenSize = proxy.size
                    let anchor = proxy[preference.value.anchor]
                  
                
                        spotLightHelperView(screenSize: screenSize, rect: anchor,show: show,currentSpot: currentSpot,properties: preference.value){
                            
                            if currentSpot.wrappedValue <= (values.count){
                                currentSpot.wrappedValue += 1
                            }else{
                                show.wrappedValue = false
                            }
                        }
                    
                
                }
                
            }.ignoresSafeArea(.all)
                .animation(.easeInOut,value: show.wrappedValue)
                .animation(.easeInOut,value: currentSpot.wrappedValue)
            
        }
        
    }
    
    @ViewBuilder
    func spotLightHelperView(screenSize: CGSize, rect:CGRect,show:Binding<Bool>,currentSpot:Binding<Int>,properties:BoundsKeyProperties,onTap: @escaping ()->())-> some View{
        
            Rectangle()
            //            .fill(.red.opacity(0.5))
                .fill(.ultraThinMaterial)
                .opacity(show.wrappedValue ? 1:0)
                .overlay(alignment: .topLeading){
                    Text(properties.text)
//                        .font(Font.caption)
                    //                    .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                        .opacity(0)
                        .overlay{
                            GeometryReader{proxy in
                                let textSize = proxy.size
                                Text(properties.text)
                              
                                    .foregroundColor(Color.white)
                                //                            Text Alingment
                                //                            Horizontalchecking
                                    .offset(x: (rect.minX + textSize.width ) > (screenSize.width - 15 ) ? -((rect.minX + textSize.width ) - (screenSize.width - 15 )): 0)
                                //                            Vertical checking
                                    .offset(y: (rect.maxY + textSize.height) > (screenSize.height - 50) ? -(textSize.height - (rect.maxY - rect.minY) + 30) : 30)
                                
                            }.offset(x: rect.minX,y: rect.maxY)
                        }
                    //
                }
                .mask{
                    Rectangle().overlay(alignment: .topLeading){
                        let radius = properties.shape == .circle ? (rect.width/2):properties.shape == .rectangle ? properties.radius: 0
                        RoundedRectangle(cornerRadius: radius,style: .continuous).frame(width: rect.width,height: rect.height)
                            .offset(x: rect.minX,y: rect.minY)
                            .blendMode(.destinationOut)
                    }
                }
                .onTapGesture {
                    //                update spotline spot
                    onTap()
                }
        }
    
    

}
//    Spotlight shape
    enum SpotlightShape{
        case circle
        case rectangle
        case rounded
    }
//    Bounds Preferance Key
    
    struct BoundsKey: PreferenceKey{
        static var defaultValue: [Int: BoundsKeyProperties] = [:]
        
        static func reduce(value: inout [Int : BoundsKeyProperties], nextValue: () -> [Int : BoundsKeyProperties]) {
            value.merge(nextValue()){$1}
        }
        
    }

//    Bounds Preferance Key Properties
struct BoundsKeyProperties{
    
    var shape: SpotlightShape
    var anchor: Anchor<CGRect>
    var text = ""
    var radius: CGFloat = 0
}

struct Spotlight_Previews: PreviewProvider {
    static var previews: some View {
        HomePage(showSpotlight: false)
    }
}
