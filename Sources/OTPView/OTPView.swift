import SwiftUI

@available(iOS 17.0, *)
public struct OtpView:View {
    
    private var activeIndicatorColor: Color
    private var inactiveIndicatorColor: Color
    private let doSomething: (String) -> Void
    private let length: Int
    
    @State private var otpText = ""
    @FocusState private var isKeyboardShowing: Bool
    
    public init(activeIndicatorColor:Color,inactiveIndicatorColor:Color, length:Int, doSomething: @escaping (String) -> Void) {
        self.activeIndicatorColor = activeIndicatorColor
        self.inactiveIndicatorColor = inactiveIndicatorColor
        self.length = length
        self.doSomething = doSomething
    }
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(0...length-1, id: \.self) { index in
                OTPTextBox(index)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .background(content: {
            TextField("", text: $otpText.limit(length))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .blendMode(.screen)
                .focused($isKeyboardShowing)
                .onChange(of: otpText) { newValue in
                    if newValue.count == length {
                        doSomething(newValue)
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        isKeyboardShowing = true
                    }
                }
        })
        .contentShape(Rectangle())
        .onTapGesture {
            isKeyboardShowing = true
        }
    }
    
    @ViewBuilder
    func OTPTextBox(_ index: Int) -> some View {
        ZStack{
            if otpText.count > index {
                let startIndex = otpText.startIndex
                let charIndex = otpText.index(startIndex, offsetBy: index)
                let charToString = String(otpText[charIndex])
                Text(charToString)
            } else {
                Text(" ")
            }
        }
        .font(.system(.largeTitle, design: .monospaced, weight: .semibold))
        .frame(width: 50, height: 80)
        .background {
            let status = (isKeyboardShowing && otpText.count == index)
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(status ? activeIndicatorColor : inactiveIndicatorColor)
                .animation(.easeInOut(duration: 0.2), value: status)

        }
    }
}

@available(iOS 13.0, *)
extension Binding where Value == String {
    func limit(_ length: Int)->Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        return self
    }
}

@available(iOS 17.0, *)
struct OTPView_Previews: PreviewProvider {
    static var previews: some View {
        OtpView(activeIndicatorColor: Color.black, inactiveIndicatorColor: Color.gray,  length: 6, doSomething: { value in
            print(value)
        })
    }
}
