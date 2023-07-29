//
//  ContentView.swift
//  BetterRest
//
//  Created by Никита Мартьянов on 24.07.23.
//
import CoreML
import SwiftUI


struct ContentView: View {
    @State private var wakeUp = DefaulWakeTime
    @State private var sleepAmount = 8.0
    @State private var cofeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    static var DefaulWakeTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    var body: some View {
        NavigationView{
            Form {
                Section {    Text("Когда вы хотите проснуться?")
                        .font(.headline)
                    DatePicker("Пожалуйста введите время",selection: $wakeUp,displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .position(.init(x: 40, y: 20))
                }
                Section {   Text("Желаемое кол-во сна")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) часов",value: $sleepAmount,in: 4...12,step: 0.25)
                }
                Section {
                    Text("Ежедневное потребление кофе")
                        .font(.headline)
                    Picker("Количество чашек", selection: $cofeeAmount) {
                        ForEach(1...20, id: \.self) { amount in
                            Text("\(amount) чашк\(amount == 1 ? "а" : "и")")

                        }
                    }


                
                    }
                Section {
                    Text("Ваше идеальное время отхода ко сну")
                        .font(.headline)
                        .foregroundColor(.purple)
                    Button("Рассчитать", action: calculatedBedTime)
                        .position(.init(x: 268, y: 20))
                

                    
                    
                }
                }
            
            .navigationTitle("Лучший отдых")
            .alert(alertTitle,isPresented: $showingAlert) {
                Button("OK") {
                }}
        message: {
            Text(alertMessage)
        }
            
            
        }}
    func calculatedBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .day], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0 ) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: Double(sleepAmount), coffee: Double(cofeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Ваше идеальное время отхода ко сну..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        }
        catch {
            alertTitle = "Ошибка"
            alertMessage = "Извините, возникла проблема с расчетом вашего времени отхода ко сну."
            
        }
        showingAlert = true
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
