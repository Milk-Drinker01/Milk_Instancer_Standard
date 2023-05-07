# Milk_Instancer_Standard

GPU Instancing in unity with culling and LOD

NOTICE: This version of the project is to be archived. I am completelely refactoring consolidating all the projects into the main one - https://github.com/Milk-Drinker01/Milk_Instancer01

NOTICE: THIS VERSION IS CURRENTLY OUTDATED VS THE URP AND HDRP VERSIONS. IT WILL BE UPDATED SOON

this is a version of Milk_Instancer01 that supports the Built in render pipeline. occlusion culling is currently broken because i do not have a functional method to generate an hiz depth texture that works for both forward and deferred rendering. if someone wants to do that themselves feel free to contribute.

![Screenshot_1](https://user-images.githubusercontent.com/59656122/170803943-325713b7-043a-47d0-bdd0-1ed423829aa9.png)

also in unity 2021.2, shadergraph now works in the built in render pipeline. however, something about it is super fucking gay, and the setup i use for indirect instancing doesnt work with it, even tho it does in urp and hdrp
