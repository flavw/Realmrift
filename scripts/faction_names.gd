extends RefCounted

# Keep IDs aligned with CardData.Faction; saved decks store numeric values.
const PT = ["Vanguarda", "Arcano", "Aldeia", "Submundo", "Luminares", "Ruína", "Selvagem", "Necrópole", "Ermos"]
const EN = ["Vanguard", "Arcane", "Village", "Underworld", "Luminaries", "Ruin", "Wilds", "Necropolis", "Wastes"]

static func name_for(faction: int, language: String = "pt") -> String:
 if faction==9:return "Unaligned" if language.begins_with("en") else "Sem facção"
 if faction<0 or faction>=PT.size():return "Village" if language.begins_with("en") else "Aldeia"
 return EN[faction] if language.begins_with("en") else PT[faction]
