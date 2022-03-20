// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Milk_Instancer/Grass"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		_MainTex("Base Color Map", 2D) = "white" {}
		_Color("_Color", Color) = (1,1,1,1)
		[Normal]_BumpMap("Normal Map", 2D) = "bump" {}
		_NormalScale("Normal Map Strength", Range( 0 , 10)) = 1
		_MetallicGlossMap("Metallic Smoothness", 2D) = "gray" {}
		_OcclusionMap("Occlusion", 2D) = "white" {}
		_MetalicMin("Metalic Min", Range( 0 , 1)) = 0
		_MetalicMax("Metalic Max", Range( 0 , 1)) = 1
		_SmoothnessRemapMin("Smoothness Min", Range( 0 , 1)) = 0
		_SmoothnessRemapMax("Smoothness Max", Range( 0 , 1)) = 1
		_AORemapMin1("AO Min", Range( 0 , 1)) = 0
		_AORemapMax1("AO Max", Range( 0 , 1)) = 1
		_maxHeight("maxHeight", Float) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Grass"  "Queue" = "Geometry+0" }
		Cull Off
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#pragma target 3.0
		#include "Assets/Milk_Instancer01/Shaders/logic/setup.hlsl"
		#pragma instancing_options procedural:setup
		#pragma surface surf StandardCustom keepalpha addshadow fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Transmission;
			half3 Translucency;
		};

		uniform float4 _wind_angle_strength;
		uniform float _maxHeight;
		uniform float4 _windNoiseUVs;
		uniform sampler2D _BumpMap;
		uniform float _NormalScale;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform sampler2D _MetallicGlossMap;
		uniform float _MetalicMin;
		uniform float _MetalicMax;
		uniform float _SmoothnessRemapMin;
		uniform float _SmoothnessRemapMax;
		uniform sampler2D _OcclusionMap;
		uniform float _AORemapMin1;
		uniform float _AORemapMax1;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform float _Cutoff = 0.5;


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }

		inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }

		inline float valueNoise (float2 uv)
		{
			float2 i = floor(uv);
			float2 f = frac( uv );
			f = f* f * (3.0 - 2.0 * f);
			uv = abs( frac(uv) - 0.5);
			float2 c0 = i + float2( 0.0, 0.0 );
			float2 c1 = i + float2( 1.0, 0.0 );
			float2 c2 = i + float2( 0.0, 1.0 );
			float2 c3 = i + float2( 1.0, 1.0 );
			float r0 = noise_randomValue( c0 );
			float r1 = noise_randomValue( c1 );
			float r2 = noise_randomValue( c2 );
			float r3 = noise_randomValue( c3 );
			float bottomOfGrid = noise_interpolate( r0, r1, f.x );
			float topOfGrid = noise_interpolate( r2, r3, f.x );
			float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
			return t;
		}


		float SimpleNoise(float2 UV)
		{
			float t = 0.0;
			float freq = pow( 2.0, float( 0 ) );
			float amp = pow( 0.5, float( 3 - 0 ) );
			t += valueNoise( UV/freq )*amp;
			freq = pow(2.0, float(1));
			amp = pow(0.5, float(3-1));
			t += valueNoise( UV/freq )*amp;
			freq = pow(2.0, float(2));
			amp = pow(0.5, float(3-2));
			t += valueNoise( UV/freq )*amp;
			return t;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 temp_output_47_0_g35 = ase_vertex3Pos;
			float temp_output_43_0_g35 = _wind_angle_strength.x;
			float3 appendResult25_g35 = (float3(( cos( temp_output_43_0_g35 ) * -1.0 ) , 0.0 , sin( temp_output_43_0_g35 )));
			float3 worldToObjDir41_g35 = normalize( mul( unity_WorldToObject, float4( appendResult25_g35, 0 ) ).xyz );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 worldToObj137 = mul( unity_WorldToObject, float4( ase_worldPos, 1 ) ).xyz;
			float clampResult3_g35 = clamp( ( worldToObj137.y / _maxHeight ) , 0.0 , 1.0 );
			float3 appendResult132 = (float3(worldToObj137.x , 0.0 , worldToObj137.z));
			float3 rotatedValue12_g35 = RotateAroundAxis( appendResult132, temp_output_47_0_g35, normalize( worldToObjDir41_g35 ), radians( ( ( ( pow( clampResult3_g35 , 1.5 ) * 0.85 ) * -1.0 ) * 90.0 ) ) );
			float2 appendResult74 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 pos75 = appendResult74;
			float2 appendResult83 = (float2(_windNoiseUVs.x , _windNoiseUVs.y));
			float2 noiseUV84 = appendResult83;
			float simpleNoise81 = SimpleNoise( ( pos75 + noiseUV84 )*_wind_angle_strength.z );
			float3 lerpResult28_g35 = lerp( temp_output_47_0_g35 , rotatedValue12_g35 , ( (0.25 + (simpleNoise81 - 0.0) * (0.85 - 0.25) / (1.0 - 0.0)) * (0.25 + (_wind_angle_strength.y - 0.0) * (1.0 - 0.25) / (10.0 - 0.0)) ));
			v.vertex.xyz = lerpResult28_g35;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			#if !defined(DIRECTIONAL)
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			half3 transmission = max(0 , -dot(s.Normal, gi.light.dir)) * gi.light.color * s.Transmission;
			half4 d = half4(s.Albedo * transmission , 0);

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + c + d;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			o.Normal = UnpackScaleNormal( tex2D( _BumpMap, i.uv_texcoord ), _NormalScale );
			float4 tex2DNode14_g37 = tex2D( _MainTex, i.uv_texcoord );
			float4 temp_output_164_0 = ( _Color * tex2DNode14_g37 );
			o.Albedo = temp_output_164_0.rgb;
			float4 tex2DNode33_g37 = tex2D( _MetallicGlossMap, i.uv_texcoord );
			o.Metallic = (_MetalicMin + (tex2DNode33_g37.r - 0.0) * (_MetalicMax - _MetalicMin) / (1.0 - 0.0));
			o.Smoothness = (_SmoothnessRemapMin + (tex2DNode33_g37.a - 0.0) * (_SmoothnessRemapMax - _SmoothnessRemapMin) / (1.0 - 0.0));
			o.Occlusion = (_AORemapMin1 + (tex2D( _OcclusionMap, i.uv_texcoord ).g - 0.0) * (_AORemapMax1 - _AORemapMin1) / (1.0 - 0.0));
			o.Transmission = temp_output_164_0.rgb;
			o.Translucency = temp_output_164_0.rgb;
			o.Alpha = 1;
			clip( ( _Color.a * tex2DNode14_g37.a ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
339;535;1754;844;2226.412;1181.135;3.056333;True;True
Node;AmplifyShaderEditor.Vector4Node;82;-2005.071,634.0352;Inherit;False;Global;_windNoiseUVs;_windNoiseUVs;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;-41.49352,123.0527,-39.72674,117.8126;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;73;-1939.783,484.7622;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;74;-1744.15,512.2599;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;83;-1772.817,633.0942;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;-1636.227,634.058;Inherit;False;noiseUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-1612.521,507.5862;Inherit;False;pos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-1479.302,218.8742;Inherit;False;75;pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;87;-1461.455,305.2564;Inherit;False;84;noiseUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;71;-1357.347,493.3405;Inherit;False;Global;_wind_angle_strength;_wind_angle_strength;11;0;Create;True;0;0;0;False;0;False;0,0,0,0;3.428172,3.33,6.99,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-1281.846,208.38;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;81;-1129.003,240.9388;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;139;-1036.821,646.3061;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;125;-614.2593,861.0113;Inherit;False;Property;_maxHeight;maxHeight;21;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;79;-857.9418,254.3462;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.25;False;4;FLOAT;0.85;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;137;-857.2523,637.9921;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TFHCRemapNode;88;-912.9957,464.1854;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;0.25;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;132;-617.2921,619.9553;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;92;-604.9239,268.4389;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-586.5522,413.1455;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;135;-444.5839,750.9626;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-1114.725,1335.617;Inherit;False;Property;_Float0;Float 0;22;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;122;-1393.508,1104.496;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;121;-1581.298,1251.358;Inherit;False;Constant;_zero;zero;12;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;111;407.9583,-165.3874;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;124;-1099.875,1205.877;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;-1637.164,730.1567;Inherit;False;shiverNoiseUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;85;-1773.753,729.1918;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;126;-1124.98,1075.146;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;123;-1421.419,1250.922;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StickyNoteNode;133;-429.1748,852.5073;Inherit;False;150;100;New Note;;1,1,1,1;0-1 based off height$;0;0
Node;AmplifyShaderEditor.StickyNoteNode;129;-936.863,1307.697;Inherit;False;150;100;New Note;;1,1,1,1;0-1 based off height$;0;0
Node;AmplifyShaderEditor.FunctionNode;148;-262.285,352.9272;Inherit;False;bendCalculation;-1;;35;5788042df6d75de418f645f58dc6dc15;0;5;61;FLOAT;0;False;47;FLOAT3;0,0,0;False;62;FLOAT3;0,0,0;False;44;FLOAT;1;False;43;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;134;-630.1868,765.6866;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;127;-952.2723,1206.153;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;138;-816.6107,791.1674;Inherit;False;Constant;_Vector0;Vector 0;12;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;110;153.9583,-133.3874;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;128;-993.9402,1044.182;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StickyNoteNode;130;-1410.799,1412.135;Inherit;False;150;100;New Note;;1,1,1,1;object position$;0;0
Node;AmplifyShaderEditor.FunctionNode;164;-303.207,48.68234;Inherit;False;FoliageShading;8;;37;327aa30652bb0fd488ed810b7ca6e7b2;0;0;6;COLOR;0;FLOAT3;19;FLOAT;41;FLOAT;40;FLOAT;39;FLOAT;18
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;161;-1.3,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Milk_Instancer/Grass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Grass;;Geometry;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;0;1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;2;Include;;True;b0e32ed493dd7164582dd2ba66536a16;Custom;Pragma;instancing_options procedural:setup;False;;Custom;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;74;0;73;1
WireConnection;74;1;73;3
WireConnection;83;0;82;1
WireConnection;83;1;82;2
WireConnection;84;0;83;0
WireConnection;75;0;74;0
WireConnection;78;0;76;0
WireConnection;78;1;87;0
WireConnection;81;0;78;0
WireConnection;81;1;71;3
WireConnection;79;0;81;0
WireConnection;137;0;139;0
WireConnection;88;0;71;2
WireConnection;132;0;137;1
WireConnection;132;2;137;3
WireConnection;80;0;79;0
WireConnection;80;1;88;0
WireConnection;135;0;137;2
WireConnection;135;1;125;0
WireConnection;111;0;110;1
WireConnection;111;2;110;3
WireConnection;124;0;122;2
WireConnection;124;1;123;2
WireConnection;86;0;85;0
WireConnection;85;0;82;3
WireConnection;85;1;82;4
WireConnection;126;0;122;1
WireConnection;126;1;123;2
WireConnection;126;2;122;3
WireConnection;123;0;121;0
WireConnection;148;61;135;0
WireConnection;148;47;92;0
WireConnection;148;62;132;0
WireConnection;148;44;80;0
WireConnection;148;43;71;1
WireConnection;134;0;137;2
WireConnection;134;1;138;2
WireConnection;127;0;124;0
WireConnection;127;1;136;0
WireConnection;128;0;126;0
WireConnection;161;0;164;0
WireConnection;161;1;164;19
WireConnection;161;3;164;41
WireConnection;161;4;164;40
WireConnection;161;5;164;39
WireConnection;161;6;164;0
WireConnection;161;7;164;0
WireConnection;161;10;164;18
WireConnection;161;11;148;0
ASEEND*/
//CHKSM=7701FF8725BB9502F8F852494281651B53F75C9D