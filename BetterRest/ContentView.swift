//
//  ContentView.swift
//  BetterRest
//
//  Created by Connor Ashton on 10/9/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
	static var defaultWakeTime: Date {
		var components = DateComponents()
		components.hour = 7
		components.minute = 0
		return Calendar.current.date(from: components) ?? Date.now
	}
	
	@State private var wakeUp = defaultWakeTime
	@State private var sleepAmount = 8.0
	@State private var caffeineAmount = 95
	
	var bedtimeText: String {
		do {
			let config = MLModelConfiguration()
			let model = try SleepCalculator(configuration: config)
			  
			let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
			let hour = (components.hour ?? 0) * 60 * 60
			let minute = (components.minute ?? 0) * 60
			  
			let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(Double(caffeineAmount / 95)))
			  
			let sleepTime = wakeUp - prediction.actualSleep
			return "Your ideal bedtime is \(sleepTime.formatted(date: .omitted, time: .shortened))"
		} catch {
			return "Sorry, there was a problem calculating your bedtime."
		}
	}
	
	var body: some View {
		NavigationStack {
			Form {
				VStack(alignment: .leading, spacing: 10) {
					Text("When do you want to wake up?")
						.font(.headline)
					DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
						.labelsHidden()
				}
				VStack(alignment: .leading, spacing: 10) {
					Text("Desired amount of sleep")
						.font(.headline)
					Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4 ... 12, step: 0.25)
				}
				VStack(alignment: .leading, spacing: 10) {
					Text("Daily caffeine intake")
						.font(.headline)
					Picker("Milligrams", selection: $caffeineAmount) {
						ForEach(Array(stride(from: 0, to: 401, by: 5)), id: \.self) {
							Text("\($0)")
						}
					}
				}
				Section(header: Text("Bedtime Recommendation")) {
					Text(bedtimeText)
				}
			}
			.navigationTitle("BetterRest")
		}
	}

//	func calculateBedtime() {
//		do {
//			let config = MLModelConfiguration()
//			let model = try SleepCalculator(configuration: config)
//
//			let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
//			let hour = (components.hour ?? 0) * 60 * 60
//			let minute = (components.minute ?? 0) * 60
//
//			let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(Double(caffeineAmount / 95)))
//
//			var sleepTime = wakeUp - prediction.actualSleep
//			alertTitle = "Your ideal bedtime is..."
//			alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
//		} catch {
//			alertTitle = "Error"
//			alertMessage = "Sorry, there was a problem calculating your bedtime."
//		}
//		showingAlert = true
//	}
}

#Preview {
	ContentView()
}
