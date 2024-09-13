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
    
    static var bsQuestions: [Question] = [
        Question(question: "Who's most likely to go to prison?", weight: 0.99, emoji: "🚔", category: "Hypothetical"),
        Question(question: "Who's most likely to get you out of prison?", weight: 0.98, emoji: "🗝️", category: "Hypothetical"),
        Question(question: "Who spends the most at the equator?", weight: 0.97, emoji: "🌡️", category: "Travel"),
        Question(question: "Who's most likely to survive a zombie apocalypse?", weight: 0.96, emoji: "🧟", category: "Hypothetical"),
        Question(question: "Who's best at keeping a secret?", weight: 0.95, emoji: "🤐", category: "Personality"),
        Question(question: "Who's best at giving advice?", weight: 0.94, emoji: "🧠", category: "Personality"),
        Question(question: "Who's most likely to get lost?", weight: 0.93, emoji: "🗺️", category: "Adventure"),
        Question(question: "Who's most likely to befriend a wild animal?", weight: 0.92, emoji: "🐾", category: "Personality"),
        Question(question: "Who's best at negotiating a good deal?", weight: 0.91, emoji: "🤝", category: "Skills"),
        Question(question: "Who's most likely to accidentally start a fire?", weight: 0.90, emoji: "🔥", category: "Hypothetical"),
        Question(question: "Who's most dramatic for no reason whatsoever?", weight: 0.89, emoji: "🎭", category: "Personality"),
        Question(question: "Who's most likely to become a stand-up comedian?", weight: 0.88, emoji: "🎤", category: "Career"),
        Question(question: "Who's best at giving impromptu speeches?", weight: 0.87, emoji: "📢", category: "Skills"),
        Question(question: "Who's most likely to start a fashion trend?", weight: 0.86, emoji: "👗", category: "Style"),
        Question(question: "Who's got the best fit?", weight: 0.85, emoji: "🕴️", category: "Style"),
        Question(question: "Who's best at telling stories?", weight: 0.84, emoji: "📚", category: "Skills"),
        Question(question: "Who's most likely to start a cult?", weight: 0.83, emoji: "🧘", category: "Hypothetical"),
        Question(question: "Who's best at faking their own death?", weight: 0.82, emoji: "💀", category: "Hypothetical"),
        Question(question: "Who's most likely to volunteer for a one-way trip to Mars?", weight: 0.81, emoji: "🚀", category: "Adventure"),
        Question(question: "Who's best at winning arguments against themselves?", weight: 0.80, emoji: "🤔", category: "Personality"),
        Question(question: "Who's most likely to become president?", weight: 0.79, emoji: "🇺🇸", category: "Career"),
        Question(question: "Who's most likely to make a million from a ridiculous social media stunt?", weight: 0.78, emoji: "💰", category: "Social Media"),
        Question(question: "Who's most likely to get a face tattoo?", weight: 0.77, emoji: "🎨", category: "Style"),
        Question(question: "Who's most likely to come to campus in shorts?", weight: 0.76, emoji: "🩳", category: "Style"),
        Question(question: "Who's most likely to get into a street fight?", weight: 0.75, emoji: "👊", category: "Hypothetical"),
        Question(question: "Who's most likely to survive a week in the wilderness?", weight: 0.74, emoji: "🏕️", category: "Adventure"),
        Question(question: "Who's most likely to accidentally become a local legend?", weight: 0.73, emoji: "🏆", category: "Hypothetical"),
        Question(question: "Who's best at making up believable excuses on the spot?", weight: 0.72, emoji: "🤥", category: "Skills"),
        Question(question: "Who's most likely to skip the group dinner?", weight: 0.71, emoji: "🍽️", category: "Social"),
        Question(question: "Who's most likely to get into an AI relationship?", weight: 0.70, emoji: "🤖", category: "Technology"),
        Question(question: "Who's best at sneaking into exclusive events?", weight: 0.69, emoji: "🕵️", category: "Skills"),
        Question(question: "Who's best at turning every conversation into a conspiracy?", weight: 0.68, emoji: "🕸️", category: "Personality"),
        Question(question: "Who's most likely to get kicked out of a library for being rowdy?", weight: 0.67, emoji: "📚", category: "Hypothetical"),
        Question(question: "Who's got the best stories?", weight: 0.66, emoji: "📖", category: "Personality"),
        Question(question: "Who's most likely to get fired from a job?", weight: 0.65, emoji: "🛑", category: "Career"),
        Question(question: "Who has the best taste in music?", weight: 0.64, emoji: "🎵", category: "Entertainment"),
        Question(question: "Who has the best taste in movies?", weight: 0.63, emoji: "🎬", category: "Entertainment"),
        Question(question: "Who's best at giving thoughtful, personalized gifts?", weight: 0.62, emoji: "🎁", category: "Personality"),
        Question(question: "Who's most likely to bring the whole group together for a dinner?", weight: 0.61, emoji: "🍴", category: "Social"),
        Question(question: "Who's most likely to have a secret life?", weight: 0.60, emoji: "🕴️", category: "Personality"),
        Question(question: "Who's most likely to become an internet meme?", weight: 0.59, emoji: "🌐", category: "Social Media"),
        Question(question: "Who's most likely to binge-watch an entire series in a day?", weight: 0.58, emoji: "📺", category: "Entertainment"),
        Question(question: "Who's most likely to stay up all night gaming?", weight: 0.57, emoji: "🎮", category: "Entertainment"),
        Question(question: "Who's most likely to get a reality TV show?", weight: 0.56, emoji: "📹", category: "Entertainment"),
        Question(question: "Who's best at remembering random facts?", weight: 0.55, emoji: "🧠", category: "Skills"),
        Question(question: "Who yaps the most on campus?", weight: 0.54, emoji: "🗣️", category: "Personality"),
        Question(question: "Who's most likely to invent something revolutionary?", weight: 0.53, emoji: "💡", category: "Career"),
        Question(question: "Who's most likely to move to a foreign country on a whim?", weight: 0.52, emoji: "✈️", category: "Adventure"),
        Question(question: "Who's best at giving heartfelt talks?", weight: 0.51, emoji: "❤️", category: "Personality"),
        Question(question: "Who's most likely to write a bestselling novel?", weight: 0.50, emoji: "📘", category: "Creative"),
        Question(question: "Who's most likely to get kicked out of a karaoke bar?", weight: 0.49, emoji: "🎤", category: "Entertainment"),
        Question(question: "Who's most likely to win a Nobel Prize?", weight: 0.48, emoji: "🏅", category: "Academic"),
        Question(question: "Who's most likely to ghost the group chat for months?", weight: 0.47, emoji: "👻", category: "Social"),
        Question(question: "Who's best at staying calm during a crisis?", weight: 0.46, emoji: "😌", category: "Personality"),
        Question(question: "Who's most likely to forget their own birthday?", weight: 0.45, emoji: "🎂", category: "Personality"),
        Question(question: "Who's most likely to start a midnight adventure?", weight: 0.44, emoji: "🌙", category: "Adventure"),
        Question(question: "Who's most likely to pull an all-nighter for no reason?", weight: 0.43, emoji: "🦉", category: "Personality"),
        Question(question: "Who's most likely to become TikTok famous overnight?", weight: 0.42, emoji: "📱", category: "Social Media"),
        Question(question: "Who's most likely to get kicked out of an amusement park?", weight: 0.41, emoji: "🎢", category: "Hypothetical"),
        Question(question: "Who's best at finding loopholes in any situation?", weight: 0.40, emoji: "🔍", category: "Skills"),
        Question(question: "Who's most likely to become a professional chef?", weight: 0.39, emoji: "👨‍🍳", category: "Career"),
        Question(question: "Who's most likely to quit everything and live on a beach?", weight: 0.38, emoji: "🏖️", category: "Hypothetical"),
        Question(question: "Who's best at cheering everyone up when they're down?", weight: 0.37, emoji: "😊", category: "Personality"),
        Question(question: "Who's most likely to invent a new game?", weight: 0.36, emoji: "🎲", category: "Creative"),
        Question(question: "Who's the funniest on campus?", weight: 0.35, emoji: "😂", category: "Personality"),
        Question(question: "Who's most likely to become a motivational speaker?", weight: 0.34, emoji: "💪", category: "Career"),
        Question(question: "Who's most likely to walk into a glass door?", weight: 0.33, emoji: "🚪", category: "Hypothetical"),
        Question(question: "Who's best at playing devil's advocate in every conversation?", weight: 0.32, emoji: "😈", category: "Personality"),
        Question(question: "Who's most likely to open a quaint café?", weight: 0.31, emoji: "☕", category: "Career"),
        Question(question: "Who's most likely to have a secret talent?", weight: 0.30, emoji: "🎭", category: "Personality"),
        Question(question: "Who's most likely to forget where they parked their car?", weight: 0.29, emoji: "🚗", category: "Personality"),
        Question(question: "Who's most likely to have the best travel stories?", weight: 0.28, emoji: "🌎", category: "Adventure"),
        Question(question: "Who's most likely to turn a casual hangout into a deep conversation?", weight: 0.27, emoji: "🤔", category: "Personality"),
        Question(question: "Who's most likely to have a burner Twitter account?", weight: 0.26, emoji: "🐦", category: "Social Media"),
        Question(question: "Who's most likely to arrive fashionably late?", weight: 0.25, emoji: "⏰", category: "Personality"),
        Question(question: "Who's most likely to show up with a spontaneous new hairstyle?", weight: 0.24, emoji: "💇", category: "Style"),
        Question(question: "Who's most likely to stay friends with an ex?", weight: 0.23, emoji: "💔", category: "Personality"),
        Question(question: "Who's most likely to wear sunglasses indoors?", weight: 0.22, emoji: "😎", category: "Style"),
        Question(question: "Who's most likely to start their own podcast?", weight: 0.21, emoji: "🎙️", category: "Creative"),
        Question(question: "Who's most likely to create their own slang?", weight: 0.20, emoji: "🗣️", category: "Creative"),
        Question(question: "Who's most likely to have a million side hustles?", weight: 0.19, emoji: "💼", category: "Career"),
        Question(question: "Who's most likely to be up-to-date on all gossip?", weight: 0.18, emoji: "🗞️", category: "Social"),
        Question(question: "Who's most likely to become famous on Instagram?", weight: 0.17, emoji: "📸", category: "Social Media"),
        Question(question: "Who would win in a dance-off?", weight: 0.16, emoji: "💃", category: "Entertainment"),
        Question(question: "Who's most likely to become a professional athlete?", weight: 0.15, emoji: "🏅", category: "Sports"),
        Question(question: "Who would be the best person to be stranded on a deserted island with?", weight: 0.14, emoji: "🏝️", category: "Hypothetical"),
        Question(question: "Who's most likely to win a talent show?", weight: 0.13, emoji: "🎭", category: "Entertainment"),
        Question(question: "Who would make the best superhero sidekick?", weight: 0.12, emoji: "🦸", category: "Hypothetical"),
        Question(question: "Who's most likely to become a teacher at our school?", weight: 0.11, emoji: "📚", category: "Career"),
        Question(question: "Who has the most school spirit?", weight: 0.10, emoji: "📣", category: "School"),
        Question(question: "Who's most likely to become an influencer?", weight: 0.09, emoji: "🤳", category: "Social Media"),
        Question(question: "Who would win in a karaoke contest?", weight: 0.08, emoji: "🎙️", category: "Entertainment"),
        Question(question: "Who has the best study habits?", weight: 0.07, emoji: "📝", category: "Academic"),
        Question(question: "Who would make the best class president?", weight: 0.06, emoji: "🗳️", category: "School"),
        Question(question: "Who has the most interesting hobby?", weight: 0.05, emoji: "🎨", category: "Personality"),
        Question(question: "Who would be the best at organizing a school event?", weight: 0.04, emoji: "🎉", category: "School"),
        Question(question: "Who's most likely to start a viral trend?", weight: 0.03, emoji: "🌟", category: "Social Media"),
        Question(question: "Who would win in a video game tournament?", weight: 0.02, emoji: "🎮", category: "Entertainment"),
        Question(question: "Who has the coolest room decoration?", weight: 0.01, emoji: "🛋️", category: "Style")
    ]

    
    
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
