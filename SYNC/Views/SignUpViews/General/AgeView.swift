import SwiftUI


struct AgeView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var showAlert = false
    
    var body: some View {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton()
                    Spacer()
                }
                .padding(.bottom, 40)
                                

                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "birthday.cake")
                        Text("When's your birthday?")
                    }
                    .titleModifiers()
                    
                    Text("NOTE: ")
                        .bold()
                        .h2Style()
                    
                    Text("Your age: \(ageCalulator(dateOfBirth: signUpModel.dateOfBirth) ?? 18) cannot be changed later on!")
                        .bodyTextStyle()
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.syncGrey)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                
                
                HingeDatePicker(selectedDate: $signUpModel.dateOfBirth)
                    .padding(.horizontal, 10)
                
                Spacer()
                HStack {
                    Spacer()
                    OnBoardingNavigationLink(text: "Next") {
                            PersonalInfoConnectorView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    }
                }
            }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
    
    func ageCalulator(dateOfBirth: Date) -> Int? {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
        return ageComponents.year
    }
}



struct HingeDatePicker: View {
    @Binding var selectedDate: Date
    @State private var hasCheckedInitialDate = false
    
    // Calculate valid date range (17-100 years old)
    private var maxDate: Date {
        Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    }
    
    private var minDate: Date {
        Calendar.current.date(byAdding: .year, value: -100, to: Date()) ?? Date()
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 15) {
                    // Day Picker
                    Picker("Day", selection: Binding(
                        get: { Calendar.current.component(.day, from: selectedDate) },
                        set: { newDay in
                            var components = Calendar.current.dateComponents([.month, .year], from: selectedDate)
                            components.day = newDay
                            if let newDate = Calendar.current.date(from: components) {
                                selectedDate = min(newDate, maxDate)
                            }
                        }
                    )) {
                        ForEach(currentDays, id: \.self) { day in
                            Text("\(day)")
                                .tag(day)
                                .foregroundStyle(Calendar.current.component(.day, from: selectedDate) == day ? .syncGreen : .syncBlack)
//                                .font(.system(size: 20, weight: .medium))
                                .fontWeight(Calendar.current.component(.day, from: selectedDate) == day ? .semibold : .regular)
                                .font(.h2)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .pickerStyle(WheelPickerStyle())
                    
                    // Month Picker
                    Picker("Month", selection: Binding(
                        get: { Calendar.current.component(.month, from: selectedDate) },
                        set: { newMonth in
                            var components = Calendar.current.dateComponents([.day, .year], from: selectedDate)
                            components.month = newMonth
                            if let newDate = Calendar.current.date(from: components) {
                                selectedDate = min(newDate, maxDate)
                            }
                        }
                    )) {
                        ForEach(1...12, id: \.self) { month in
                            Text(monthName(month))
                                .tag(month)
                                .foregroundStyle(Calendar.current.component(.month, from: selectedDate) == month ? .syncGreen : .syncBlack)
//                                .font(.system(size: 20, weight: .medium))
                                .fontWeight(Calendar.current.component(.month, from: selectedDate) == month ? .semibold : .regular)
                                .font(.h2)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .pickerStyle(WheelPickerStyle())
                    
                    // Year Picker
                    Picker("Year", selection: Binding(
                        get: { Calendar.current.component(.year, from: selectedDate) },
                        set: { newYear in
                            var components = Calendar.current.dateComponents([.month, .day], from: selectedDate)
                            components.year = newYear
                            if let newDate = Calendar.current.date(from: components) {
                                selectedDate = min(newDate, maxDate)
                            }
                        }
                    )) {
                        ForEach(yearRange(), id: \.self) { year in
                            Text(String(format: "%.0f", Double(year)))
                                .tag(year)
                                .foregroundStyle(Calendar.current.component(.year, from: selectedDate) == year ? .syncGreen : .syncBlack)
//                                .font(.system(size: 20, weight: .medium))
                                .fontWeight(Calendar.current.component(.year, from: selectedDate) == year ? .semibold : .regular)
                                .font(.h2)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .pickerStyle(WheelPickerStyle())
                }
            }
            
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.syncBlack)
                    .frame(height: 1)
                Spacer().frame(height: 35)
                Rectangle()
                    .fill(Color.syncBlack)
                    .frame(height: 1)
                Spacer()
            }
        }
        .frame(height: 300)
        .onAppear {
            if !hasCheckedInitialDate {
                // If the selected date is more recent than maxDate, set it to maxDate
                if selectedDate > maxDate {
                    selectedDate = maxDate
                }
                hasCheckedInitialDate = true
            }
        }
    }
    
    private func monthName(_ month: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        guard let date = Calendar.current.date(from: DateComponents(month: month)) else {
            return ""
        }
        return dateFormatter.string(from: date)
    }
    
    private func yearRange() -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        // Changed from 18 to 17 years
        return Array((currentYear-100...currentYear-17).reversed())
    }
    
    private func daysInMonth(month: Int, year: Int) -> Int {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        
        guard let date = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return 31
        }
        return range.count
    }
    
    private var currentDays: Range<Int> {
        let month = Calendar.current.component(.month, from: selectedDate)
        let year = Calendar.current.component(.year, from: selectedDate)
        let days = daysInMonth(month: month, year: year)
        return 1..<(days + 1)
    }
}
