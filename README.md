-------------------------------------------------------------------------------
CIS565: Project 1: CUDA Raytracer
-------------------------------------------------------------------------------
Fall 2013
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
IMPLEMENTATION:
-------------------------------------------------------------------------------
For this project, I learned about CUDA and implemented a simple GPU raytracer.
The basic features include diffuse and phong shading of cubes and spheres with 
raytraced shadows from a single point light. I also added these additional 
features:

* Soft shadows and area lights 
* Depth of field
* Supersampled anti-aliasing
* Movable camera

Please use the new scene files provided in the repository. phongMatScene.txt is 
the scene I used to render the images below.  
The scenes are still read through the command line. I added focal length and 
aperture as new camera features that can be read in through the scene files, 
so the old scene files would not work. 

The camera controls are:
* 'a' and 'd' keys to translate along the x axis
* 'w' and 's' keys to translate along the y axis
* 'j' and 'k' keys to translate along the z axis


-------------------------------------------------------------------------------
SCREENSHOT OF MY RAYTRACER
-------------------------------------------------------------------------------
Screen shot
![Alt text](/renders/screenCap/sampleSceneDOF.jpg "screen shot")

Depth of Field
![Alt text](/renders/screenCap/DOF.bmp "DOF")

Two lights, no DOF
![Alt text](/renders/screenCap/noDOF.bmp "No DOF")

Depth of Field
![Alt text](/renders/screenCap/twoLightDOF.bmp "two lights with DOF")

-------------------------------------------------------------------------------
VIDEO
-------------------------------------------------------------------------------
Video link:

https://vimeo.com/75069384

-------------------------------------------------------------------------------
PERFORMANCE EVALUATION
-------------------------------------------------------------------------------
![Alt text](/renders/performanceAnalysis.png "Performance Analysis")

Link to pdf

https://github.com/zxyzhu/Project1-RayTracer/blob/master/renders/PerformanceAnalysis.pdf

-------------------------------------------------------------------------------
THIRD PARTY CODE 
-------------------------------------------------------------------------------
* None, but here are the resources I used for box intersection and sampling
random points on spheres:

* Box intersection: 
http://www.siggraph.org/education/materials/HyperGraph/raytrace/rtinter3.htm

* Sphere random point generation:
http://mathworld.wolfram.com/SpherePointPicking.html

-------------------------------------------------------------------------------
FUTURE WORK
-------------------------------------------------------------------------------
I am currently working on reflective surfaces. After that I plan to make 
refraction and create better camera controls. 
