//
//  SignInView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI

struct SignInView: View {
    @Binding var phoneNumber:String
    @Binding var codeNumber:String
    @Binding var isCountingDown:Bool
    
    var registerUrl:String
    var registerNotification: (_ mode:Int)->Void
    
    @State var appear = [false, false, false]
    @State var circleInitialY:CGFloat = CGFloat.zero
    @State var circleY:CGFloat = CGFloat.zero
    
    @State var countdown:Int = 60
    @FocusState private var isPhoneFocused: Bool
    @FocusState private var isCodeFocused: Bool
    
       
    
    var filedColor:Color{
        phoneNumber.count > 10 ? .blue : .red
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text(NSLocalizedString("signTitle", comment: "通知"))
                    .font(.largeTitle).bold()
                    .blendMode(.overlay)
                    .slideFadeIn(show: appear[0], offset: 30)
                Spacer()
               

            }
            
            Text(NSLocalizedString("signSubTitle", comment: "访问您的账户，注册获取您的通知"))
                .padding(.horizontal)
                .font(.headline)
                .foregroundStyle(.secondary)
                .slideFadeIn(show: appear[1], offset: 20)
                
            form.slideFadeIn(show: appear[2], offset: 10)
            
            Divider()
            
            HStack{
                Text(NSLocalizedString("signHelp", comment: "不知道如何开始? **获取帮助**"))
                    .font(.footnote)
                    .foregroundColor(.primary.opacity(0.7))
                    .accentColor(.primary.opacity(0.7))
                    .onTapGesture {
                        pageState.shared.webUrl = otherUrl.helpRegisterWebUrl
                        pageState.shared.fullPage = .web
                    }
                Spacer()
                
                Button(action: {
                    self.countdown = 0
                    self.codeNumber = ""
                    self.isCodeFocused = false
                    self.isCountingDown = false
        
                }) {
                    Text(NSLocalizedString("signRetry", comment: "**重试**"))
                }
     
            }
            
            
           
        }
        .coordinateSpace(name: "stack")
        .padding(20)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
        .backgroundColor(opacity: 0.4)
        .cornerRadius(30)
        .background(
            VStack {
                Circle().fill(.blue).frame(width: 68, height: 68)
                    .offset(x: 0, y: circleY)
                    .scaleEffect(appear[0] ? 1 : 0.1)
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        )
        .modifier(OutlineModifier(cornerRadius: 30))
        .onAppear { animate() }
        .onChange(of: isCountingDown) { value in
            if value{
                self.startCountdown()
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.3){
                    DispatchQueue.main.async {
                        self.isPhoneFocused.toggle()
                        self.isCodeFocused.toggle()
                    }
                }
            }
        }
        

    }
    
    var form: some View {
        Group{
            
            TextField(NSLocalizedString("signPhoneInput", comment: "请输入手机号码"), text: $phoneNumber)
                .textContentType(.flightNumber)
                .keyboardType(.phonePad)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .foregroundStyle(.textBlack)
                .customField(
                    icon: "phone.bubble"
                )
                .foregroundStyle(filedColor)
                .overlay(
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .named("stack")).minY + 32
                        Color.clear.preference(key: CirclePreferenceKey.self, value: offset)
                        
                    }
                        .onPreferenceChange(CirclePreferenceKey.self) { value in
                            circleInitialY = value
                            circleY = value
                        }
                )
                .focused($isPhoneFocused)
                .onChange(of: isPhoneFocused) {value in
                    if value {
                        withAnimation {
                            circleY = circleInitialY
                        }
                    }
                }
                .onTapGesture {
                    self.isPhoneFocused = true
                }
                .disabled(isCountingDown)
            
            if isCountingDown{
                TextField(NSLocalizedString("signCodeInput", comment: "请输入验证码"), text: $codeNumber)
                    .keyboardType(.numberPad)
                    .customField(icon: "key.fill")
                    .focused($isCodeFocused)
                    .onChange(of: isCodeFocused) {value  in
                        if value {
                            withAnimation {
                                circleY = circleInitialY + 70
                            }
                        }
                    }
                    .onTapGesture {
                        self.isCodeFocused = true
                    }
                    .overlay {
                        Text("\(countdown)")
                            .frame(maxWidth: .infinity,alignment: .trailing)
                            .opacity(isCountingDown ? 1 : 0)
                            .font(.headline)
                            .foregroundStyle(Color.red)
                            .animation(.bouncy, value:countdown)
                            .padding(.trailing, 10)
                    }
                    
            }
            
           
            
            
            if !isCountingDown{
                angularButton(title: NSLocalizedString("signGetCode", comment: "获取验证码"),disable: phoneNumber.count == 0){
                    registerNotification(0)
                }
            }else{
                angularButton(title: NSLocalizedString("register", comment: "注册"),disable: codeNumber.count == 0){
                    registerNotification(1)
                }
            }
            
            
            
        }
        
        
    }
    
    func startCountdown() {
            isCountingDown = true
            countdown = 60
            // 使用 Timer 定期更新 countdown
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if countdown > 0 {
                    countdown -= 1
                } else {
                    timer.invalidate()
                    isCountingDown = false
                    self.countdown = 60
                }
            }
        }
    
    func animate() {
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8).delay(0.2)) {
            appear[0] = true
        }
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8).delay(0.4)) {
            appear[1] = true
        }
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8).delay(0.6)) {
            appear[2] = true
        }
    }
    
}

private func generateNewGreeting(mode:Int) ->Void {}

#Preview {
   
    SignInView(phoneNumber: .constant(""), codeNumber: .constant(""), isCountingDown: .constant(false), registerUrl: "", registerNotification: generateNewGreeting)
}

