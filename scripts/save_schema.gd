extends RefCounted

# Compatibility only: gameplay uses faction/antimagic and canonical card IDs.
const LEGACY_KEYS={
 "card_class":"faction",
 "base_class":"base_faction",
 "class_filter":"faction_filter",
 "abascanto":"antimagic",
 "abascanto_capacity":"antimagic_capacity",
 "abascanto_blocked":"antimagic_blocked",
 "remaining_abascanto":"remaining_antimagic",
 "adventure_abascanto_bonus":"adventure_antimagic_bonus",
 "abascanto_guardian":"antimagic_guardian"
}

static func normalize(value: Variant) -> Variant:
 if value is String:
  if value=="abascanto_guardian":return "antimagic_guardian"
  if value=="Abascanto":return "Antimagic"
  return value
 if value is Array:
  var result: Array=[]
  for part in value:result.append(normalize(part))
  return result
 if value is Dictionary:
  var result: Dictionary={}
  for key in value:
   var canonical: Variant=LEGACY_KEYS.get(key,key) if key is String else key
   # Prefer an explicit current value if a file contains both schemas.
   if canonical!=key and value.has(canonical):continue
   result[canonical]=normalize(value[key])
  return result
 return value
