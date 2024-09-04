//
//  Question.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import Foundation

struct Question {
    var question: String
    var weight: Double // how relevant / spicy the question is (context this is for a highschool) 0-1
    var emoji: String
    var category: String
    
    static var allQuestions: [Question] = [
        Question(question: "Who's most likely to become a famous TikToker?", weight: 0.8, emoji: "📱", category: "Social Media"),
        Question(question: "Who's most likely to become famous on Instagram?", weight: 0.7, emoji: "📸", category: "Social Media"),
        Question(question: "Who would survive the longest in a zombie apocalypse?", weight: 0.9, emoji: "🧟", category: "Hypothetical"),
        Question(question: "Who has the best taste in music?", weight: 0.6, emoji: "🎵", category: "Entertainment"),
        Question(question: "Who's most likely to win a Nobel Prize?", weight: 0.5, emoji: "🏆", category: "Academic"),
        Question(question: "Who would make the best stand-up comedian?", weight: 0.7, emoji: "🎤", category: "Entertainment"),
        Question(question: "Who's most likely to travel the world before turning 25?", weight: 0.8, emoji: "🌍", category: "Adventure"),
        Question(question: "Who's got the most contagious laugh?", weight: 0.6, emoji: "😂", category: "Personality"),
        Question(question: "Who would win in a dance-off?", weight: 0.7, emoji: "💃", category: "Entertainment"),
        Question(question: "Who's most likely to start a business?", weight: 0.6, emoji: "💼", category: "Career"),
        Question(question: "Who gives the best advice?", weight: 0.5, emoji: "🧠", category: "Personality"),
        Question(question: "Who's most likely to become a professional athlete?", weight: 0.7, emoji: "🏅", category: "Sports"),
        Question(question: "Who would be the best person to be stranded on a deserted island with?", weight: 0.8, emoji: "🏝️", category: "Hypothetical"),
        Question(question: "Who's most likely to win a talent show?", weight: 0.7, emoji: "🎭", category: "Entertainment"),
        Question(question: "Who has the best fashion sense?", weight: 0.6, emoji: "👗", category: "Style"),
        Question(question: "Who would make the best superhero sidekick?", weight: 0.8, emoji: "🦸", category: "Hypothetical"),
        Question(question: "Who's most likely to become a teacher at our school?", weight: 0.5, emoji: "📚", category: "Career"),
        Question(question: "Who has the most school spirit?", weight: 0.6, emoji: "📣", category: "School"),
        Question(question: "Who's most likely to become an influencer?", weight: 0.7, emoji: "🤳", category: "Social Media"),
        Question(question: "Who would win in a karaoke contest?", weight: 0.7, emoji: "🎙️", category: "Entertainment"),
        Question(question: "Who's most likely to write a bestselling novel?", weight: 0.6, emoji: "📖", category: "Creative"),
        Question(question: "Who has the best study habits?", weight: 0.5, emoji: "📝", category: "Academic"),
        Question(question: "Who would make the best class president?", weight: 0.6, emoji: "🗳️", category: "School"),
        Question(question: "Who's most likely to appear on a reality TV show?", weight: 0.8, emoji: "📺", category: "Entertainment"),
        Question(question: "Who has the most interesting hobby?", weight: 0.6, emoji: "🎨", category: "Personality"),
        Question(question: "Who's most likely to become a famous chef?", weight: 0.6, emoji: "👨‍🍳", category: "Career"),
        Question(question: "Who would be the best at organizing a school event?", weight: 0.5, emoji: "🎉", category: "School"),
        Question(question: "Who's most likely to start a viral trend?", weight: 0.8, emoji: "🌟", category: "Social Media"),
        Question(question: "Who has the best sense of humor?", weight: 0.7, emoji: "😆", category: "Personality"),
        Question(question: "Who would win in a video game tournament?", weight: 0.7, emoji: "🎮", category: "Entertainment"),
        Question(question: "Who's most likely to become a movie director?", weight: 0.6, emoji: "🎬", category: "Career"),
        Question(question: "Who has the coolest room decoration?", weight: 0.5, emoji: "🛋️", category: "Style"),
        Question(question: "Who's most likely to win an eating contest?", weight: 0.7, emoji: "🍔", category: "Hypothetical"),
        Question(question: "Who would be the best person to team up with for a group project?", weight: 0.5, emoji: "🤝", category: "School"),
        Question(question: "Who's most likely to become a professional photographer?", weight: 0.6, emoji: "📷", category: "Career"),
        Question(question: "Who has the most unique style?", weight: 0.6, emoji: "🕶️", category: "Style"),
        Question(question: "Who would be the best at giving a TED Talk?", weight: 0.7, emoji: "🎤", category: "Hypothetical"),
        Question(question: "Who's most likely to become a famous actor/actress?", weight: 0.7, emoji: "🎭", category: "Career"),
        Question(question: "Who has the best taste in movies?", weight: 0.6, emoji: "🍿", category: "Entertainment"),
        Question(question: "Who would win in a lip-sync battle?", weight: 0.7, emoji: "🎶", category: "Entertainment"),
        Question(question: "Who's most likely to become a successful entrepreneur?", weight: 0.6, emoji: "💡", category: "Career"),
        Question(question: "Who has the most interesting Instagram feed?", weight: 0.7, emoji: "📱", category: "Social Media"),
        Question(question: "Who would be the best at hosting a podcast?", weight: 0.6, emoji: "🎙️", category: "Creative"),
        Question(question: "Who's most likely to become a professional gamer?", weight: 0.7, emoji: "🕹️", category: "Career"),
        Question(question: "Who has the best handwriting?", weight: 0.5, emoji: "✍️", category: "School"),
        Question(question: "Who would make the best tour guide for our town?", weight: 0.5, emoji: "🏙️", category: "Personality"),
        Question(question: "Who's most likely to win a trivia game show?", weight: 0.6, emoji: "🧠", category: "Entertainment"),
        Question(question: "Who would be the best at planning a surprise party?", weight: 0.6, emoji: "🎊", category: "Personality"),
        Question(question: "Who's most likely to become a famous scientist?", weight: 0.5, emoji: "🔬", category: "Career"),
        Question(question: "Who has the most impressive hidden talent?", weight: 0.7, emoji: "🎩", category: "Personality")
    ]
}
