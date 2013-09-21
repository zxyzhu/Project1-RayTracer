-------------------------------------------------------------------------------
CIS565: Project 1: CUDA Raytracer  IN PROGRESS!!!!!!!
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

The scenes are still read through the command line. I added focal length and 
aperture as new camera features that can be read in through the scene files, 
so the old scene files would not work. Please use the new scene files provided
in the repository. 

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

Two lights
![Alt text](/renders/screenCap/twoLights.bmp "two lights")

Depth of Field
![Alt text](/renders/screenCap/twoLightDOF.bmp "two lights with DOF")

-------------------------------------------------------------------------------
VIDEO
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
PERFORMANCE EVALUATION
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
THIRD PARTY CODE 
-------------------------------------------------------------------------------
* None, but here are the resources I used for box intersection and sampling
random points on spheres:

*Box intersection: 
http://www.siggraph.org/education/materials/HyperGraph/raytrace/rtinter3.htm

*Sphere random point generation:
http://mathworld.wolfram.com/SpherePointPicking.html

-------------------------------------------------------------------------------
FUTURE WORK
-------------------------------------------------------------------------------
I am currently working on reflective surfaces. After that I plan to make 
refraction and create better camera controls. 

-------------------------------------------------------------------------------
README
-------------------------------------------------------------------------------
All students must replace or augment the contents of this Readme.md in a clear 
manner with the following:

* A brief description of the project and the specific features you implemented.
* At least one screenshot of your project running.
* A 30 second or longer video of your project running.  To create the video you
  can use http://www.microsoft.com/expression/products/Encoder4_Overview.aspx 
* A performance evaluation (described in detail below).

-------------------------------------------------------------------------------
PERFORMANCE EVALUATION
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
SELF-GRADING
-------------------------------------------------------------------------------
* On the submission date, email your grade, on a scale of 0 to 100, to Liam,
  liamboone+cis565@gmail.com, with a one paragraph explanation.  Be concise and
  realistic.  Recall that we reserve 30 points as a sanity check to adjust your
  grade.  Your actual grade will be (0.7 * your grade) + (0.3 * our grade).  We
  hope to only use this in extreme cases when your grade does not realistically
  reflect your work - it is either too high or too low.  In most cases, we plan
  to give you the exact grade you suggest.
* Projects are not weighted evenly, e.g., Project 0 doesn't count as much as
  the path tracer.  We will determine the weighting at the end of the semester
  based on the size of each project.

-------------------------------------------------------------------------------
SUBMISSION
-------------------------------------------------------------------------------
As with the previous project, you should fork this project and work inside of
your fork. Upon completion, commit your finished project back to your fork, and
make a pull request to the master repository.  You should include a README.md
file in the root directory detailing the following

* A brief description of the project and specific features you implemented
* At least one screenshot of your project running, and at least one screenshot
  of the final rendered output of your raytracer
* A link to a video of your raytracer running.
* Instructions for building and running your project if they differ from the
  base code
* A performance writeup as detailed above.
* A list of all third-party code used.
* This Readme file, augmented or replaced as described above in the README section.
