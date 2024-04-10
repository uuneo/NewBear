//
//  LoginView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI


struct LoginView: View {
    @Environment(\.dismiss) var closeView
    @State var appear = false
    @State var appearBackground = false
    @State var viewState = CGSize.zero
    @State var dismissModalData: Bool = false
    
    @State var phoneNumber:String = ""
    @State var codeNumber:String = ""
    @State var toastText:String = ""
    @State var isCountingDown:Bool = false
   
    
    var registerUrl:String
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                viewState = value.translation
            }
            .onEnded { value in
                if value.translation.height > 300 {
                    dismissModal()
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        viewState = .zero
                    }
                }
            }
    }
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .onTapGesture { dismissModal() }
                .opacity(appear ? 1 : 0)
                .ignoresSafeArea()
            
            VStack{
                Spacer()
                Text(registerUrl)
                    .lineLimit(1)
                    .padding(.horizontal, 50)
                    .padding()
                    .foregroundStyle(.gray)
                    
            }
            
            GeometryReader { proxy in
                SignInView(phoneNumber: $phoneNumber,codeNumber: $codeNumber, isCountingDown: $isCountingDown,registerUrl: self.registerUrl,registerNotification: registerNotification)
                .rotationEffect(.degrees(viewState.width / 40))
                .rotation3DEffect(.degrees(viewState.height / 20), axis: (x: 1, y: 0, z: 0), perspective: 1)
                .shadow(color: Color("Shadow").opacity(0.2), radius: 30, x: 0, y: 30)
                .padding(20)
                .offset(x: viewState.width, y: viewState.height)
                .gesture(drag)
                .frame(maxHeight: .infinity, alignment: .center)
                .offset(y: appear ? 0 : proxy.size.height)
                .background(
                    Image("Blob 1").offset(x: 170, y: -60)
                        .opacity(appearBackground ? 1 : 0)
                        .offset(y: appearBackground ? -10 : 0)
                        .blur(radius: appearBackground ? 0 : 40)
                        .hueRotation(.degrees(viewState.width / 5))
                        .allowsHitTesting(false)
                        .accessibility(hidden: true)
                )
               
            }
            
            Button {
                dismissModal()
            } label: {
                CloseButton()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding()
            .offset(x: appear ? 0 : 100)
            
           
            
            
        }
        .toast(info: $toastText)
        .onAppear {
            withAnimation(.spring()) {
                appear = true
            }
            withAnimation(.easeOut(duration: 2)) {
                appearBackground = true
            }
        }
        .onDisappear {
            withAnimation(.spring()) {
                appear = false
            }
            withAnimation(.easeOut(duration: 1)) {
                appearBackground = true
            }
        }
        .onChange(of: dismissModalData) {value in
            dismissModal()
        }
        .accessibilityAddTraits(.isModal)
        
    }
    
    
    func dismissModal() {
        withAnimation {
            appear = false
            appearBackground = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            closeView()
        }
  
    }
}

extension LoginView{
    
    struct registerResponse:Decodable {
        var success:Bool
        var msg:String
    }
    
    
    func registerNotification(mode:Int){
        Task{
            if let data = await sendRequest(url: self.registerUrl, phone: self.phoneNumber, code: self.codeNumber){
                if mode == 0{
                    withAnimation {
                        if data.success{
                            DispatchQueue.main.async {
                                self.isCountingDown.toggle()
                            }
                        }
                    }
                }else if mode == 1{
                    if data.success{
                        self.dismissModal()
                    }
                }
                
                DispatchQueue.main.async{
                    self.toastText = data.msg
                }
            }else{
                
                toolsManager.async_set_localString( "requestFail", "请求失败") { text in
                    self.toastText = text
                }
              
            }
            
            
            
            
           
            
            
            
        }
        
    }
    
    func sendRequest(url:String, phone:String, code:String = "") async -> registerResponse?{
       
        do{
            let key = pawManager.shared.servers[0].key
            let url2 = "\(url)?phone=\(phone)&code=\(code)&key=\(key)"
            guard let url3 = URL(string: url2) else { return nil }
            
            var request = URLRequest(url: url3)
            
            request.addValue("NewBear", forHTTPHeaderField: "User-Agent")
            request.addValue(url, forHTTPHeaderField: "Referer")
            
            let data = try await URLSession(configuration: .default).data(for: request)
            return try? JSONDecoder().decode(registerResponse.self, from: data)

        }catch{
#if DEBUG
            print(error)
#endif
           
            return nil
        }
       
    }
}


#Preview {
    LoginView(registerUrl: "https://twown.com")
}
