extends RefCounted

# Keep IDs aligned with CardData.CardClass; saved decks store numeric values.
const PT = ["Vanguarda", "Arcano", "Neutro", "Submundo", "Luminares", "Horda", "Selvagem"]
const EN = ["Vanguard", "Arcane", "Neutral", "Underworld", "Luminaries", "Horde", "Wilds"]

static func name_for(faction: int, language: String = "pt") -> String:
 if faction<0 or faction>=PT.size():return "Neutral" if language.begins_with("en") else "Neutros"
 return EN[faction] if language.begins_with("en") else PT[faction]
