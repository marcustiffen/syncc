import SwiftUI


struct EditWeightView: View {
    @Binding var weight: Double
    @Binding var isPresented: Bool
    
    @State private var wholeNumber: Int
    @State private var decimalPart: Int
    
    init(weight: Binding<Double>, isPresented: Binding<Bool>) {
        self._weight = weight
        self._isPresented = isPresented
        // Extract the whole number and decimal part from the initial weight
        let whole = Int(weight.wrappedValue)
        let decimal = Int((weight.wrappedValue * 10).truncatingRemainder(dividingBy: 10))
        self._wholeNumber = State(initialValue: whole)
        self._decimalPart = State(initialValue: decimal)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "scalemass")
                Text("Edit weight")
            }
            .titleModifiers()
            
            HStack(spacing: 4) {
                Picker("Whole Number", selection: $wholeNumber) {
                    ForEach(0...150, id: \.self) { number in
                        Text("\(number)")
                            .bodyTextStyle()
                    }
                }
                .frame(maxWidth: .infinity)
                .pickerStyle(.wheel)
                
                Text(".")
                    .bodyTextStyle()
                    .bold()
                
                Picker("Decimal Part", selection: $decimalPart) {
                    ForEach(0...9, id: \.self) { decimal in
                        Text("\(decimal)")
                            .bodyTextStyle()
                    }
                }
                .frame(maxWidth: .infinity)
                .pickerStyle(.wheel)
            }
            .padding()
            
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.syncWhite
                .ignoresSafeArea()
        )
        .onDisappear {
            weight = Double(wholeNumber) + Double(decimalPart) / 10.0
            isPresented = false
        }
    }
}
