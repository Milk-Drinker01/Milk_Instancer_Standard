# Milk_Instancer_Standard

GPU Instancing in unity with culling and LOD


this is a version of Milk_Instancer01 that supports the Built in render pipeline. occlusion culling is currently broken because i do not have a functional method to generate an hiz depth texture that works for both forward and deferred rendering. if someone wants to do that themselves feel free to contribute.

also in unity 2021.2, shadergraph now works in the built in render pipeline. however, something about it is super fucking gay, and the setup i use for indirect instancing doesnt work with it, even tho it does in urp and hdrp
