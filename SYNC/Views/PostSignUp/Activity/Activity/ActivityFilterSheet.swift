import SwiftUI
import CoreLocation


struct ActivityFilterSheet: View {
    @EnvironmentObject var profileModel: ProfileModel
    
    @ObservedObject var viewModel: ActivityViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDateRange: DateRangeFilter
    @State private var selectedRadius: Double?
    @State private var customStartDate = Date()
    @State private var customEndDate = Date().addingTimeInterval(86400 * 7)
    @State private var showCustomDatePicker = false
    
    init(viewModel: ActivityViewModel) {
        self.viewModel = viewModel
        _selectedDateRange = State(initialValue: viewModel.filter.dateRange)
        _selectedRadius = State(initialValue: viewModel.filter.radiusKm)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            titleView()
                .padding(.top, 25)
            
            Spacer()
            if !showCustomDatePicker {
                // Date Range Section
                ForEach(DateRangeFilter.allCases, id: \.displayName) { range in
                    Button {
                        selectedDateRange = range
                    } label: {
                        HStack {
                            Text(range.displayName)
                                .font(.h2)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedDateRange == range ? Color.syncGreen.opacity(0.1) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedDateRange == range ? Color.syncGreen : Color.gray.opacity(0.2), lineWidth: 2)
                            )
                    )
                }
            }
            
            
            Button {
                withAnimation {
                    showCustomDatePicker.toggle()
                }
            } label: {
                HStack {
                    Text(!showCustomDatePicker ? "Choose a custom Range" : "Cancel")
                        .padding(.horizontal, 10)
                        .foregroundStyle(.syncBlack)
                        .h2Style()
                        .padding(.vertical, 10)
                        .background(
                            Rectangle()
                                .clipShape(.rect(cornerRadius: 10))
                                .foregroundStyle(.syncGreen)
                        )
                    Spacer()
                    if case .custom = selectedDateRange {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if showCustomDatePicker {
                DatePicker("Start", selection: $customStartDate, displayedComponents: [.date])
                DatePicker("End", selection: $customEndDate, displayedComponents: [.date])
                
                
                Button {
                    selectedDateRange = .custom(start: customStartDate, end: customEndDate)
                    showCustomDatePicker = false
                } label: {
                    Text("Apply Custom Range")
                        .padding(.horizontal, 10)
                        .foregroundStyle(.syncBlack)
                        .h2Style()
                        .padding(.vertical, 10)
                        .background(
                            Rectangle()
                                .clipShape(.rect(cornerRadius: 10))
                                .foregroundStyle(.syncGreen)
                        )
                }
                
            }
            
            // Radius Section
            Toggle(isOn: Binding(
                get: { selectedRadius != nil },
                set: { newValue in
                    if newValue {
                        selectedRadius = 10.0 // Default to 10km when enabled
                    } else {
                        selectedRadius = nil
                    }
                }
            )) {
                Text("Enable Radius Filter")
                    .font(.h2)
                    .foregroundStyle(.syncBlack)
                    .h2Style()
            }
            .toggleStyle(.automatic)
            .padding(.vertical, 8)


            
            
            if selectedRadius != nil {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(Int(selectedRadius ?? 10)) km")
                        .font(.h2)
                        .bold()
                    
                    Slider(
                        value: Binding(
                            get: { selectedRadius ?? 10 },
                            set: { selectedRadius = $0 }
                        ),
                        in: 1...100,
                        step: 1
                    )
                }
            }
            
            
            Spacer()
            
            
            Button {
                selectedDateRange = .all
                selectedRadius = nil
                Task {
                    await viewModel.clearFilters(currentUserId: profileModel.user?.uid ?? "")
                }
                dismiss()
            } label: {
                Text("Clear all filters")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .h2Style()
                    .padding(.vertical, 10)
                    .background(
                        Rectangle()
                            .clipShape(.rect(cornerRadius: 10))
                            .foregroundStyle(.red.opacity(0.7))
                    )
            }
            
            
            
            Spacer()
        }
        .padding(.horizontal, 10)
    }
    
    private func applyFilters() {
        Task {
            viewModel.updateRadiusFilter(radiusKm: selectedRadius)
            await viewModel.updateDateRangeFilter(dateRange: selectedDateRange, currentUserId: profileModel.user?.uid ?? "")
        }
    }
    
    
    private func titleView() -> some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.h2)
            }
            
            Spacer()
            Text("Filters")
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Apply")
                    .font(.h2)
                    .bold()
            }
        }
        .h1Style()
        .foregroundStyle(.syncBlack)
    }
}
