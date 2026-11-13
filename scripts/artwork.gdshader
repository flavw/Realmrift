shader_type canvas_item;

uniform float view_aspect = 0.746835;
uniform float source_aspect = 0.75;
uniform float artwork_zoom = 1.0;
uniform vec2 artwork_focus = vec2(0.5, 0.5);
uniform float corner_radius = 8.0;
varying vec4 tint;

void vertex() {
 tint = COLOR;
}

void fragment() {
 vec2 visible = vec2(min(1.0, view_aspect / source_aspect), min(1.0, source_aspect / view_aspect)) / artwork_zoom;
 vec2 center = clamp(artwork_focus, visible * 0.5, vec2(1.0) - visible * 0.5);
 vec2 art_uv = center + (UV - vec2(0.5)) * visible;
 COLOR = texture(TEXTURE, art_uv) * tint;
 vec2 dimensions=vec2(350.0,470.0);
 vec2 q=abs((UV-vec2(0.5))*dimensions)-(dimensions*0.5-vec2(corner_radius));
 float distance_to_edge=length(max(q,vec2(0.0)))+min(max(q.x,q.y),0.0)-corner_radius;
 COLOR.a*=1.0-smoothstep(-0.75,0.75,distance_to_edge);
}
