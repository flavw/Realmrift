shader_type canvas_item;
uniform float revealed_until : hint_range(0.0,1.0) = 0.083333;
varying vec4 tint;
void vertex(){tint=COLOR;}
void fragment(){
 vec4 terrain=texture(TEXTURE,UV);
 float light=1.0-smoothstep(revealed_until-0.015,revealed_until+0.12,UV.x);
 if(revealed_until>=0.999){light=1.0;}
 vec3 covered=terrain.rgb*vec3(0.25,0.29,0.32);
 vec3 explored=terrain.rgb*vec3(1.03,1.01,0.96);
 COLOR=vec4(mix(covered,explored,light),terrain.a)*tint;
}
