shader_type canvas_item;
uniform vec2 focus=vec2(0.5,0.32);
uniform vec2 crop=vec2(0.8,0.55);
uniform vec4 rim: source_color=vec4(0.8,0.66,0.35,1.0);
varying vec4 node_tint;
void vertex(){node_tint=COLOR;}
void fragment(){
 float d=length(UV-vec2(0.5));
 vec4 art=texture(TEXTURE,(UV-vec2(0.5))*crop+focus);
 COLOR=vec4(mix(art.rgb,rim.rgb,smoothstep(0.44,0.46,d)),art.a*(1.0-smoothstep(0.485,0.5,d)))*node_tint;
}

