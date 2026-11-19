@tool
extends RefCounted

static var cache: Dictionary = {}

static func texture(asset: String) -> Texture2D:
 if cache.has(asset):
  return cache[asset]
 var vector_path := "res://assets/ui/%s.svg" % asset
 if ResourceLoader.exists(vector_path):
  var vector: Texture2D = load(vector_path)
  cache[asset] = vector
  return vector
 var path := "res://assets/ui/%s.webp" % asset
 if not ResourceLoader.exists(path):
  return null
 var source: Texture2D = load(path)
 var atlas := AtlasTexture.new()
 atlas.atlas = source
 # Ignore very faint alpha noise around generated UI sprites.
 var image := source.get_image()
 var low := image.get_size()
 var high := Vector2i.ZERO
 for y in range(0, image.get_height(), 2):
  for x in range(0, image.get_width(), 2):
   if image.get_pixel(x, y).a > 0.5:
    low.x = mini(low.x, x)
    low.y = mini(low.y, y)
    high.x = maxi(high.x, x)
    high.y = maxi(high.y, y)
 atlas.region = Rect2(Rect2i(low, high - low + Vector2i(2, 2)))
 atlas.filter_clip = true
 cache[asset] = atlas
 return atlas

static func faction_color(faction: int) -> Color:
 if faction==9:return Color("8cb5ba")
 return [Color("c87575"),Color("b08bd8"),Color("9ba5b1"),Color("6ab798"),Color("d7cba6"),Color("d69c63"),Color("77a56e"),Color("76aaa7"),Color("a89b78")][clampi(faction,0,8)]

static func faction_symbol(faction: int, detailed: bool=false) -> Texture2D:
 if faction<0 or faction>8:return null
 var names: Array=["warrior","mage","villagers","rogue","cleric","ruin","wild","necropolis","wastes"]
 return texture(("faction-art-" if detailed else "faction-small-")+names[faction])
