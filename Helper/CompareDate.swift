//
//  CompareDate.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 10/5/2024.
//

import Foundation

func compareDate(_ date1: Date, largerOrEqualTo date2: Date) -> Bool {
    let calendar = Calendar.current
    let component1 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date1)
    let component2 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date2)
    
        if let year1 = component1.year, let year2 = component2.year, year1 != year2{
            return year1 >= year2
        }
        
        // Compare the month component
        if let month1 = component1.month, let month2 = component2.month, month1 != month2{
            return month1 >= month2
        }
        
        // Compare the day component
        if let day1 = component1.day, let day2 = component2.day, day1 != day2{
            return day1 >= day2
        }
        
        // Compare the hour component
        if let hour1 = component1.hour, let hour2 = component2.hour, hour1 != hour2{
            return hour1 >= hour2
        }
        
        // Compare the minute component
        if let minute1 = component1.minute, let minute2 = component2.minute, minute1 != minute2{
            return minute1 >= minute2
        }
        // all the same
        return true
}
