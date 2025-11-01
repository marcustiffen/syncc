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
            Form {
                // Date Range Section
                Section {
                    ForEach(DateRangeFilter.allCases, id: \.displayName) { range in
                        Button {
                            selectedDateRange = range
                        } label: {
                            HStack {
                                Text(range.displayName)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedDateRange == range {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    Button {
                        showCustomDatePicker.toggle()
                    } label: {
                        HStack {
                            Text("Custom Range")
                                .foregroundColor(.primary)
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
                        
                        Button("Apply Custom Range") {
                            selectedDateRange = .custom(start: customStartDate, end: customEndDate)
                            showCustomDatePicker = false
                        }
                        .foregroundColor(.blue)
                    }
                } header: {
                    Text("Time Range")
                } footer: {
                    if let range = selectedDateRange.dateRange {
                        Text("Showing activities from \(range.start.formatted(date: .abbreviated, time: .omitted)) to \(range.end.formatted(date: .abbreviated, time: .omitted))")
                    }
                }
                
                // Radius Section
                Section {
                    Toggle("Enable Radius Filter", isOn: Binding(
                        get: { selectedRadius != nil },
                        set: { newValue in
                            if newValue {
                                selectedRadius = 10.0 // Default to 10km when enabled
                            } else {
                                selectedRadius = nil
                            }
                        }
                    ))
                    
                    if selectedRadius != nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(Int(selectedRadius ?? 10)) km")
                                .font(.headline)
                            
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
                } header: {
                    Text("Distance")
                } footer: {
                    if selectedRadius != nil {
                        Text("Only show activities within \(Int(selectedRadius!)) km of your location")
                    } else {
                        Text("Show activities at any distance")
                    }
                }
                
                // Clear Filters
                Section {
                    Button("Clear All Filters") {
                        selectedDateRange = .all
                        selectedRadius = nil
                        Task {
                            await viewModel.clearFilters(currentUserId: profileModel.user?.uid ?? "")
                        }
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyFilters()
                        dismiss()
                    }
                }
            }
        
    }
    
    private func applyFilters() {
        Task {
            viewModel.updateRadiusFilter(radiusKm: selectedRadius)
            await viewModel.updateDateRangeFilter(dateRange: selectedDateRange, currentUserId: profileModel.user?.uid ?? "")
        }
    }
}