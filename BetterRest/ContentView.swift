//
//  ContentView.swift
//  BetterRest
//
//  Created by Ishaan Bhasin on 2/23/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultDateTime
    @State private var sleepAmount = 4.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    static var defaultDateTime: Date {
        var component = DateComponents()
        component.hour = 7
        component.minute = 0
        return Calendar.current.date(from: component) ?? Date.now
    }
    var body: some View {
        NavigationView{
            Form{
                Section("When do you want to wake up?") {
                    HStack{
                        Spacer()
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            
                        Spacer()
                    }
                }
            
                VStack(alignment: .leading, spacing: 0){
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                VStack(alignment: .leading, spacing: 0){
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in:  1...20)
                }
            }
            .navigationTitle("Better Rest")
            .toolbar {
                Button("Calculate") {
                    calculateBedTime()
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("Ok"){showAlert = false}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedTime(){
        do {
            let config = MLModelConfiguration()
            let model = try Better(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let min = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + min), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleeptime = wakeUp - prediction.actualSleep
            alertTitle = "Your Ideal bed Time is..."
            alertMessage = sleeptime.formatted(date: .omitted, time: .shortened)
        }catch{
            alertTitle = "Error"
            alertMessage = "Sorry! There was an error"
            
        }
        showAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
