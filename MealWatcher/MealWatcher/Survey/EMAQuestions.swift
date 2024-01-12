//
//  EMAQuestions.swift
//  SurveyDemoLight
//
//  Created by Jimmy Nguyen on 7/7/23.
//

import Foundation
import SwiftUI
import Combine

func TrueFalseQuestion( _ title : String ) -> MultipleChoiceQuestion {
    return MultipleChoiceQuestion(title: title, answers: [ "Definitely false" , "Mostly False", "Mostly true", "Definitely true" ], tag: TitleToTag(title))
}

let EMAQuestions = Survey([
    
    start_time,
    
    MCQ(title: "Did you just finish your meal before answering this survey?",
                                          items: [
                                            "Yes",
                                            MultipleChoiceResponse("If no, what time?", allowsCustomTextEntry: true)
                                          ], multiSelect: false,
                                          tag: "meal-time"),
    
    MCQ(title: "Please select all of the following types of beverages that were consumed during this meal or snack:",
                                          items: [
                                            "Water",
                                            "Non-caloric beverage (e.g., diet soda)",
                                            "Caloric beverage (e.g. regular soda, juice, milk)",
                                            "Alcohol",
                                            "None",
                                            MultipleChoiceResponse("Other", allowsCustomTextEntry: true)
                                          ], multiSelect: true,
                                          tag: "beverage-types"),
    
    MCQ(title: "Did you consume any of the following:",
                                          items: [
                                            "Cheese", "Fried Food", "Beef", "Pork", "Ham", "Sausage", "Bacon", "Lunch Meats", "Hot Dogs",
                                            "Chips or other Salty Snacks","None of these categories apply"
                                          ], multiSelect: true,
                                          tag: "high-fat-items"),
    
    MCQ(title: "Did you consume any of the following:",
                                          items: [
                                            "Sugar or honey (include if you put any sugar in drinks)", "Chocolate or other types of candy",
                                            "Sweets (like donuts, cake, etc.", "Ice cream or other frozen desserts"
                                          ], multiSelect: true,
                                          tag: "high-sugar-items"),
    
    MCQ(title: "Where did you eat this meal or snack?",
                                          items: [
                                            "Home", "Work/School", "Friend/Family's House", "Restaurant/Cafe", "'On the go' (car, walking, commuting)", "Outside (park, hike, etc)",
                                            MultipleChoiceResponse("Other", allowsCustomTextEntry: true)
                                          ], multiSelect: false,
                                          tag: "meal-location"),
    
    MCQ(title: "Were you doing anything else while eating?",
                                          items: [
                                            "Just eating", "Talking with another person", "Watching TV or media", "Working", "Doing chores", "Walking", "Driving or traveling",
                                            MultipleChoiceResponse("Other", allowsCustomTextEntry: true)
                                          ], multiSelect: true,
                                          tag: "activity-during-meal"),
    
    MCQ(title: "Which of these establishments did you get your food for this meal or snack from?",
                                          items: [
                                            "Homemade", "Fast food", "Carry-out Restaurant", "Full service restaurant", "Coffee shop or cafe",
                                            "Supermarket (including stores with markets)", "Bar", "Corner store", "Convenience Store",
                                            "Pharmacy", "Specialty Food Store", "Farmer's Market", "Food pantry", "None",
                                            MultipleChoiceResponse("Other", allowsCustomTextEntry: true)
                                          ], multiSelect: false,
                                          tag: "food-source"),
    
    MCQ(title: "Who prepared your food for this meal/snack",
                                          items: [
                                            "Myself", "By someone in my household", "By an acquaintance", "At a restaurant", "Unknown",
                                            MultipleChoiceResponse("Other", allowsCustomTextEntry: true)
                                          ], multiSelect: true,
                                          tag: "food-preperation"),
    
    
    InlineMultipleChoiceQuestionGroup(title: "Select the response that feels most appropriate to the following statement",
                                      questions: [
                                        TrueFalseQuestion("I was resticting my eating to control my weight"),
                                        TrueFalseQuestion("When I started eating, I felt that I couldn't stop until it was finished"),
                                        TrueFalseQuestion("I ate even though I was not physically hungry"),
                                      ],
                                      tag: "true-false-questions"),
    
    vegetable_servings,
    
    fruit_servings,
    
],
version: "001")


let vegetable_servings = CommentsFormQuestion(title: "How many servings of vegetables (not including potatoes) did you eat?",
                                         subtitle: "1 serving = 1/2 cup or half of a fistful",
                                         tag: "vegetable-serving-size")

let fruit_servings = CommentsFormQuestion(title: "How many servings of fruit did you eat?",
                                         subtitle: "1 serving = 1/2 cup or half of a fistful",
                                         tag: "fruit-serving-size")

let start_time = CommentsFormQuestion(title: "When did you start eating?",
                                     subtitle: "Give a time like 8:30PM",
                                     tag: "meal-start-time")
