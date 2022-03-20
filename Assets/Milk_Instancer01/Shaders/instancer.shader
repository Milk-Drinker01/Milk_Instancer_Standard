// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Milk_Instancer/Lit"
{
	Properties
	{
		_MainTex("Base Color Map", 2D) = "white" {}
		[Normal]_BumpMap("Normal Map", 2D) = "bump" {}
		_NormalScale("Normal Map Strength", Float) = 1
		_MetallicGlossMap("Metallic Smoothness", 2D) = "gray" {}
		_OcclusionMap("Occlusion", 2D) = "white" {}
		_Color("Base Color", Color) = (1,1,1,1)
		_MetalicMin("Metalic Min", Range( 0 , 1)) = 0
		_MetalicMax("Metalic Max", Range( 0 , 1)) = 1
		_SmoothnessRemapMin("Smoothness Min", Range( 0 , 1)) = 0
		_SmoothnessRemapMax("Smoothness Max", Range( 0 , 1)) = 1
		_AORemapMin("AO Min", Range( 0 , 1)) = 0
		_AORemapMax("AO Max", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#include "Assets/Milk_Instancer01/Shaders/logic/setup.hlsl"
		#pragma instancing_options procedural:setup
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

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
		uniform float _AORemapMin;
		uniform float _AORemapMax;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = UnpackScaleNormal( tex2D( _BumpMap, i.uv_texcoord ), _NormalScale );
			float4 tex2DNode11_g1 = tex2D( _MainTex, i.uv_texcoord );
			o.Albedo = ( _Color * tex2DNode11_g1 ).rgb;
			float4 tex2DNode12_g1 = tex2D( _MetallicGlossMap, i.uv_texcoord );
			o.Metallic = (_MetalicMin + (tex2DNode12_g1.r - 0.0) * (_MetalicMax - _MetalicMin) / (1.0 - 0.0));
			o.Smoothness = (_SmoothnessRemapMin + (tex2DNode12_g1.a - 0.0) * (_SmoothnessRemapMax - _SmoothnessRemapMin) / (1.0 - 0.0));
			o.Occlusion = (_AORemapMin + (tex2D( _OcclusionMap, i.uv_texcoord ).g - 0.0) * (_AORemapMax - _AORemapMin) / (1.0 - 0.0));
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
1268;216;1754;856;1080.237;216.725;1;True;True
Node;AmplifyShaderEditor.FunctionNode;14;-260.9839,14.46393;Inherit;False;StandardShading;0;;1;5e7e2ae5299f0b54ea8330c3cad1f8cb;0;0;6;COLOR;24;FLOAT3;23;FLOAT;20;FLOAT;19;FLOAT;18;FLOAT;22
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;12;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Milk_Instancer/Lit;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;2;Include;;True;b0e32ed493dd7164582dd2ba66536a16;Custom;Pragma;instancing_options procedural:setup;False;;Custom;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;12;0;14;24
WireConnection;12;1;14;23
WireConnection;12;3;14;20
WireConnection;12;4;14;19
WireConnection;12;5;14;18
ASEEND*/
//CHKSM=6D88793CD3BB98DC45E3F3F9DBA8E725B349C9F7