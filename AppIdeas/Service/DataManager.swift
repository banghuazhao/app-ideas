import Foundation
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()

    // Function to get appropriate emoji for app idea
    private func getEmojiForAppIdea(_ name: String, _ description: String) -> String {
        let lowercasedName = name.lowercased()
        let lowercasedDesc = description.lowercased()

        // Calculator and math related
        if lowercasedName.contains("calculator") || lowercasedDesc.contains("calculate") {
            return "🧮"
        }

        // Game related
        if lowercasedName.contains("game") || lowercasedDesc.contains("game") {
            return "🎮"
        }

        // Social and communication
        if lowercasedName.contains("chat") || lowercasedDesc.contains("chat") {
            return "💬"
        }

        // Photo and image related
        if lowercasedName.contains("image") || lowercasedName.contains("photo") || lowercasedDesc.contains("image") {
            return "📸"
        }

        // Music and audio
        if lowercasedName.contains("podcast") || lowercasedDesc.contains("podcast") {
            return "🎧"
        }

        // Food and recipe
        if lowercasedName.contains("recipe") || lowercasedName.contains("meal") || lowercasedDesc.contains("food") {
            return "🍽️"
        }

        // Weather
        if lowercasedName.contains("weather") || lowercasedDesc.contains("weather") {
            return "🌤️"
        }

        // Timer and clock
        if lowercasedName.contains("timer") || lowercasedName.contains("clock") || lowercasedDesc.contains("countdown") {
            return "⏰"
        }

        // Notes and text
        if lowercasedName.contains("note") || lowercasedDesc.contains("note") {
            return "📝"
        }

        // To-do and tasks
        if lowercasedName.contains("todo") || lowercasedDesc.contains("task") {
            return "✅"
        }

        // Calendar
        if lowercasedName.contains("calendar") || lowercasedDesc.contains("calendar") {
            return "📅"
        }

        // Shopping and store
        if lowercasedName.contains("store") || lowercasedDesc.contains("shopping") {
            return "🛒"
        }

        // Money and finance
        if lowercasedName.contains("currency") || lowercasedDesc.contains("money") {
            return "💰"
        }

        // Social media
        if lowercasedName.contains("instagram") || lowercasedDesc.contains("social") {
            return "📱"
        }

        // GitHub and development
        if lowercasedName.contains("github") || lowercasedDesc.contains("github") {
            return "🐙"
        }

        // Password and security
        if lowercasedName.contains("password") || lowercasedDesc.contains("password") {
            return "🔐"
        }

        // QR Code
        if lowercasedName.contains("qr") || lowercasedDesc.contains("qr") {
            return "📱"
        }

        // Drawing and art
        if lowercasedName.contains("draw") || lowercasedDesc.contains("art") {
            return "🎨"
        }

        // Emoji related
        if lowercasedName.contains("emoji") || lowercasedDesc.contains("emoji") {
            return "😊"
        }

        // Quiz and education
        if lowercasedName.contains("quiz") || lowercasedDesc.contains("quiz") {
            return "❓"
        }

        // Memory and cards
        if lowercasedName.contains("memory") || lowercasedDesc.contains("card") {
            return "🃏"
        }

        // Voting and polls
        if lowercasedName.contains("vote") || lowercasedDesc.contains("poll") {
            return "🗳️"
        }

        // Charity and donation
        if lowercasedName.contains("charity") || lowercasedDesc.contains("donation") {
            return "❤️"
        }

        // Movie and entertainment
        if lowercasedName.contains("movie") || lowercasedDesc.contains("movie") {
            return "🎬"
        }

        // Fitness and health
        if lowercasedName.contains("calorie") || lowercasedDesc.contains("fitness") {
            return "💪"
        }

        // Space and NASA
        if lowercasedName.contains("nasa") || lowercasedDesc.contains("space") {
            return "🚀"
        }

        // Default app icon
        return "📱"
    }

    func loadAppIdeas() -> [AppIdea.Draft] {
        let beginnerIdeas: [AppIdeaRaw] = [
            AppIdeaRaw(name: "Bin2Dec App", shortDescription: "Binary-to-Decimal number converter"),
            AppIdeaRaw(name: "Border Radius Previewer", shortDescription: "Preview how CSS3 border-radius values affect an element"),
            AppIdeaRaw(name: "Calculator App", shortDescription: "Calculator"),
            AppIdeaRaw(name: "Christmas Lights App", shortDescription: "Simulate a string of Christmas lights"),
            AppIdeaRaw(name: "Cause Effect App", shortDescription: "Click list item to display item details"),
            AppIdeaRaw(name: "Color Cycle App", shortDescription: "Cycle a color value through incremental changes"),
            AppIdeaRaw(name: "Countdown Timer App", shortDescription: "Event Countdown timer"),
            AppIdeaRaw(name: "CSV2JSON App", shortDescription: "CSV to JSON converter"),
            AppIdeaRaw(name: "Dollars To Cents App", shortDescription: "Convert dollars to cents"),
            AppIdeaRaw(name: "Dynamic CSS Variables", shortDescription: "Dynamically change CSS variable settings"),
            AppIdeaRaw(name: "First DB App", shortDescription: "Your first Database app!"),
            AppIdeaRaw(name: "Flip Image App", shortDescription: "Change the orientation of images across two axes"),
            AppIdeaRaw(name: "GitHub Status App", shortDescription: "Display Current GitHub Status"),
            AppIdeaRaw(name: "Hello App", shortDescription: "User native language greeting"),
            AppIdeaRaw(name: "IOT Mailbox App", shortDescription: "Use callbacks to check your snail mail"),
            AppIdeaRaw(name: "Javascript Validation With Regex", shortDescription: "Script to validate inputs entered by a user using RegEx"),
            AppIdeaRaw(name: "JSON2CSV App", shortDescription: "JSON to CSV converter"),
            AppIdeaRaw(name: "Key Value App", shortDescription: "Keyboard Event Values"),
            AppIdeaRaw(name: "Notes App", shortDescription: "Create an online note pad"),
            AppIdeaRaw(name: "Pearson Regression App", shortDescription: "Calculate the correlation coefficient for two sets of data"),
            AppIdeaRaw(name: "Pomodoro Clock", shortDescription: "Task timer to aid personal productivity"),
            AppIdeaRaw(name: "Product Landing Page", shortDescription: "Showcase product details for possible buyers"),
            AppIdeaRaw(name: "Quiz App", shortDescription: "Test your knowledge by answering questions"),
            AppIdeaRaw(name: "Recipe App", shortDescription: "Recipe"),
            AppIdeaRaw(name: "Random Meal Generator", shortDescription: "Generate random meals"),
            AppIdeaRaw(name: "Random Number Generator", shortDescription: "Generate random number between range."),
            AppIdeaRaw(name: "Roman to Decimal Converter", shortDescription: "Convert Roman to Decimal numbers"),
            AppIdeaRaw(name: "Slider Design", shortDescription: "Display images using a slider control"),
            AppIdeaRaw(name: "Stopwatch App", shortDescription: "Count time spent on activities"),
            AppIdeaRaw(name: "True or False App", shortDescription: "Identify the result of a conditional comparison"),
            AppIdeaRaw(name: "Vigenere Cipher", shortDescription: "Encrypt text using the Vigenere Cypher"),
            AppIdeaRaw(name: "Windchill App", shortDescription: "Calculate the windchill factor from an actual temperature"),
            AppIdeaRaw(name: "Word Frequency App", shortDescription: "Calculate word frequency in a block of text"),
            AppIdeaRaw(name: "Weather App", shortDescription: "Get the temperature, weather condition of a city."),
        ]

        let intermediateIdeas: [AppIdeaRaw] = [
            AppIdeaRaw(name: "Bit Masks App", shortDescription: "Using Bit Masks for Conditions"),
            AppIdeaRaw(name: "Book Finder App", shortDescription: "Search for books by multiple criteria"),
            AppIdeaRaw(name: "Calculator CLI", shortDescription: "Create a basic calculator cli."),
            AppIdeaRaw(name: "Card Memory Game", shortDescription: "Memorize and match hidden images"),
            AppIdeaRaw(name: "Charity Finder App", shortDescription: "Find a Global Charity to donate to"),
            AppIdeaRaw(name: "Chrome Theme Extension", shortDescription: "Build your own chrome theme extention."),
            AppIdeaRaw(name: "Currency Converter", shortDescription: "Convert one currency to another."),
            AppIdeaRaw(name: "Drawing App", shortDescription: "Create digital artwork on the web"),
            AppIdeaRaw(name: "Emoji Translator App", shortDescription: "Translate sentences into Emoji"),
            AppIdeaRaw(name: "FlashCards App", shortDescription: "Review and test your knowledge through Flash Cards"),
            AppIdeaRaw(name: "Flip Art App", shortDescription: "Animate a set of images"),
            AppIdeaRaw(name: "Game Suggestion App", shortDescription: "Create polls to decide what games to play"),
            AppIdeaRaw(name: "GitHub Profiles", shortDescription: "A GitHub user search App"),
            AppIdeaRaw(name: "HighStriker Game", shortDescription: "Highstriker strongman carnival game"),
            AppIdeaRaw(name: "Image Scanner", shortDescription: "Image Scanner App"),
            AppIdeaRaw(name: "Markdown Previewer", shortDescription: "Preview text formatted in GitHub flavored markdown"),
            AppIdeaRaw(name: "Markdown Table Generator", shortDescription: "Convert a table into Markdown-formatted text"),
            AppIdeaRaw(name: "Math Editor", shortDescription: "A math editor for students to use"),
            AppIdeaRaw(name: "Meme Generator App", shortDescription: "Create custom memes"),
            AppIdeaRaw(name: "Name Generator", shortDescription: "Generate names using names dataset"),
            AppIdeaRaw(name: "Password Generator", shortDescription: "Generate random passwords"),
            AppIdeaRaw(name: "Podcast Directory App", shortDescription: "Directory of favorite podcasts"),
            AppIdeaRaw(name: "QRCode Badge App", shortDescription: "Encode badge info in a QRcode"),
            AppIdeaRaw(name: "RegExp Helper App", shortDescription: "Test Regular Expressions"),
            AppIdeaRaw(name: "Sales DB App", shortDescription: "Record Sales Receipts in a DB"),
            AppIdeaRaw(name: "Simple Online Store", shortDescription: "Simple Online Store"),
            AppIdeaRaw(name: "Sports Bracket Generator", shortDescription: "Generate a sports bracket diagram"),
            AppIdeaRaw(name: "String Art", shortDescription: "An animation of moving, colored strings"),
            AppIdeaRaw(name: "This or That Game", shortDescription: "This or That Game"),
            AppIdeaRaw(name: "Timezone Slackbot", shortDescription: "Display Team Timezones"),
            AppIdeaRaw(name: "To-Do App", shortDescription: "Manage personal to-do tasks"),
            AppIdeaRaw(name: "Typing Practice App", shortDescription: "Typing Practice"),
            AppIdeaRaw(name: "Voting App", shortDescription: "Voting App"),
        ]

        let advancedIdeas: [AppIdeaRaw] = [
            AppIdeaRaw(name: "Battleship Bot", shortDescription: "Create a Discord bot that plays Battleship"),
            AppIdeaRaw(name: "Battleship Game Engine", shortDescription: "Create a callable engine to play the Battleship game"),
            AppIdeaRaw(name: "Boole Bot Game", shortDescription: "Battling Bots driven by Boolean algebra"),
            AppIdeaRaw(name: "Calendar App", shortDescription: "Create your own Calendar"),
            AppIdeaRaw(name: "Calorie Counter App", shortDescription: "Calorie Counter Nutrition App"),
            AppIdeaRaw(name: "Chat App", shortDescription: "Real-time chat interface"),
            AppIdeaRaw(name: "Contribution Tracker App", shortDescription: "Track funds donated to charity"),
            AppIdeaRaw(name: "Elevator App", shortDescription: "Elevator simulator"),
            AppIdeaRaw(name: "FastFood App", shortDescription: "Fast Food Restaurant Simulator"),
            AppIdeaRaw(name: "Instagram Clone App", shortDescription: "A clone of Facebook's Instagram app"),
            AppIdeaRaw(name: "GitHub Timeline App", shortDescription: "Generate a timeline of a users GitHub Repos"),
            AppIdeaRaw(name: "Kudos Slackbot", shortDescription: "Give recognition to a deserving peer"),
            AppIdeaRaw(name: "Movie App", shortDescription: "Browse, Find Ratings, Check Actors and Find you next movie to watch"),
            AppIdeaRaw(name: "MyPodcast Library App", shortDescription: "Create a library of favorite podcasts"),
            AppIdeaRaw(name: "NASA Exoplanet Query", shortDescription: "Query NASA's Exoplanet Archive"),
            AppIdeaRaw(name: "Shell Game", shortDescription: "Animated shell game"),
            AppIdeaRaw(name: "Shuffle Deck App", shortDescription: "Evaluate different algorithms for shuffling a card deck"),
            AppIdeaRaw(name: "Slack Archiver", shortDescription: "Archive Slack Messages"),
            AppIdeaRaw(name: "SpellIt App", shortDescription: "A twist on the classic Speak N Spell game"),
            AppIdeaRaw(name: "Survey App", shortDescription: "Define, conduct, and view a survey"),
        ]

        let beginnerAppIdeas = beginnerIdeas.map {
            let detail = loadResource($0.name.replacingOccurrences(of: " ", with: "-"))
            return AppIdea.Draft(
                title: $0.name,
                icon: getEmojiForAppIdea($0.name, detail),
                shortDescription: $0.shortDescription,
                detail: detail,
                categoryID: 1
            )
        }

        let intermediateAppIdeas = intermediateIdeas.map {
            let detail = loadResource($0.name.replacingOccurrences(of: " ", with: "-"))
            return AppIdea.Draft(
                title: $0.name,
                icon: getEmojiForAppIdea($0.name, detail),
                shortDescription: $0.shortDescription,
                detail: detail,
                categoryID: 2
            )
        }

        let advancedAppIdeas = advancedIdeas.map {
            let detail = loadResource($0.name.replacingOccurrences(of: " ", with: "-"))
            return AppIdea.Draft(
                title: $0.name,
                icon: getEmojiForAppIdea($0.name, detail),
                shortDescription: $0.shortDescription,
                detail: detail,
                categoryID: 3
            )
        }

        return beginnerAppIdeas + intermediateAppIdeas + advancedAppIdeas
    }

    private func loadResource(_ resource: String, ext: String = "md") -> String {
        guard let url = Bundle.main.url(forResource: resource, withExtension: ext),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("Could not find \(resource).\(ext))")
            return ""
        }
        return content
    }
}
