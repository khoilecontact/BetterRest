//
//  ContentView.swift
//  BetterRest
//
//  Created by KhoiLe on 19/06/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeupTime
    @State private var sleepAmmount = 8.0
    @State private var coffeeAmmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 20) {
                    Text("When do you like to wake up")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp,
                               displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        //.datePickerStyle(WheelDatePickerStyle())
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Desired ammount to sleep")
                        .font(.headline)
                    
                    Stepper(value: $sleepAmmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmmount, specifier: "%g") hours")
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Daily coffee intake")
                    Stepper(value: $coffeeAmmount, in: 0...20) {
                        if coffeeAmmount == 1 {
                            Text("1 cup")
                        }
                        else {
                            Text("\(coffeeAmmount) cups")
                        }
                    }
                }
            }
            .navigationBarTitle("BetterRest")
            .navigationBarItems(trailing:
                                    Button(action: calculateBedtime, label: {
                                        Text("Calculate")
                                    }))
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    static var defaultWakeupTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    //using machine learning to predict the result
    func calculateBedtime() {
         let model = SleepCalculator()
        let componets = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (componets.hour ?? 0) * 60 * 60
        let minute = (componets.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour+minute), estimatedSleep: Double(sleepAmmount),
                coffee: Double(coffeeAmmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bedtime is"
        }
        catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was some errors calculating your bedtime."
        }
        
        showingAlert =  true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
