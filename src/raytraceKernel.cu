// CIS565 CUDA Raytracer: A parallel raytracer for Patrick Cozzi's CIS565: GPU Computing at the University of Pennsylvania
// Written by Yining Karl Li, Copyright (c) 2012 University of Pennsylvania
// This file includes code from:
//       Rob Farber for CUDA-GL interop, from CUDA Supercomputing For The Masses: http://www.drdobbs.com/architecture-and-design/cuda-supercomputing-for-the-masses-part/222600097
//       Peter Kutz and Yining Karl Li's GPU Pathtracer: http://gpupathtracer.blogspot.com/
//       Yining Karl Li's TAKUA Render, a massively parallel pathtracing renderer: http://www.yiningkarlli.com

#include <stdio.h>
#include <cuda.h>
#include <cmath>
#include "sceneStructs.h"
#include "glm/glm.hpp"
#include "utilities.h"
#include "raytraceKernel.h"
#include "intersections.h"
#include "interactions.h"
#include <vector>

#if CUDA_VERSION >= 5000
    #include <helper_math.h>
#else
    #include <cutil_math.h>
#endif

void checkCUDAError(const char *msg) {
  cudaError_t err = cudaGetLastError();
  if( cudaSuccess != err) {
    fprintf(stderr, "Cuda error: %s: %s.\n", msg, cudaGetErrorString( err) ); 
    exit(EXIT_FAILURE); 
  }
} 

//LOOK: This function demonstrates how to use thrust for random number generation on the GPU!
//Function that generates static.
__host__ __device__ glm::vec3 generateRandomNumberFromThread(glm::vec2 resolution, float time, int x, int y){
  int index = x + (y * resolution.x);
   
  thrust::default_random_engine rng(hash(index*time));
  thrust::uniform_real_distribution<float> u01(0,1);

  return glm::vec3((float) u01(rng), (float) u01(rng), (float) u01(rng));
}

//TODO: IMPLEMENT THIS FUNCTION
//Function that does the initial raycast from the camera
__host__ __device__ ray raycastFromCameraKernel(glm::vec2 resolution, float time, int x, int y, glm::vec3 eye, glm::vec3 view, glm::vec3 up, glm::vec2 fov){
	
	ray r;

	//ray creation from camear stuff to be used in raycastFromCameraKernel
	glm::vec3 M = eye + view;	//center of screen

	//project screen to world space
	glm::vec3 A = glm::cross(view, up);
	glm::vec3 B = glm::cross(A, view);

	float C = glm::length(view);

	float phi = fov.y/180.0f * PI;		//convert to radians
	B = glm::normalize(B);
	glm::vec3 V = C * tan(phi) * B;

	float theta = fov.x/180.0f * PI;
	A = glm::normalize(A);
	glm::vec3 H = C * tan(theta) * A;

	//find the world space coord of the pixel
	float sx = (float)x / (resolution.x-1.0f);
	float sy = (float)y / (resolution.y-1.0f);

	glm::vec3 P = M + H * (2.0f * sx - 1.0f) + V * (1.0f - 2.0f * sy);

	r.origin = eye;
	r.direction = glm::normalize(P - eye);

	return r;
}

//Kernel that blacks out a given image buffer
__global__ void clearImage(glm::vec2 resolution, glm::vec3* image){
    int x = (blockIdx.x * blockDim.x) + threadIdx.x;
    int y = (blockIdx.y * blockDim.y) + threadIdx.y;
    int index = x + (y * resolution.x);
    if(x<=resolution.x && y<=resolution.y){
      image[index] = glm::vec3(0,0,0);
    }
}

//Kernel that writes the image to the OpenGL PBO directly.
__global__ void sendImageToPBO(uchar4* PBOpos, glm::vec2 resolution, glm::vec3* image){
  
  int x = (blockIdx.x * blockDim.x) + threadIdx.x;
  int y = (blockIdx.y * blockDim.y) + threadIdx.y;
  int index = x + (y * resolution.x);
  
  if(x<=resolution.x && y<=resolution.y){

      glm::vec3 color;
      color.x = image[index].x*255.0;
      color.y = image[index].y*255.0;
      color.z = image[index].z*255.0;

      if(color.x>255){
        color.x = 255;
      }

      if(color.y>255){
        color.y = 255;
      }

      if(color.z>255){
        color.z = 255;
      }
      
      // Each thread writes one pixel location in the texture (textel)
      PBOpos[index].w = 0;
      PBOpos[index].x = color.x;
      PBOpos[index].y = color.y;
      PBOpos[index].z = color.z;
  }
}

//TODO: IMPLEMENT THIS FUNCTION
//Core raytracer kernel
__global__ void raytraceRay(glm::vec2 resolution, float time, cameraData cam, int rayDepth, glm::vec3* colors,
                            staticGeom* geoms, int numberOfGeoms, material* materials, int numLights, int* lightID){

	int x = (blockIdx.x * blockDim.x) + threadIdx.x;
	int y = (blockIdx.y * blockDim.y) + threadIdx.y;
	int index = x + (y * resolution.x);

	glm::vec3 intersection;
	glm::vec3 normal;

	if((x<=resolution.x && y<=resolution.y)){
		ray firstRay = raycastFromCameraKernel(resolution, time, x, y, cam.position, cam.view, cam.up, cam.fov);

		//do intersection test
		float len = FLT_MAX;
		float tempLen = -1;
		int objID = -1;
		glm::vec3 tempIntersection;
		glm::vec3 tempNormal;
		glm::vec3 surfColor(0,0,0);
		glm::vec3 finalColor(0,0,0);

		//check for interesction
		for(int i = 0; i<numberOfGeoms; ++i){
			
			if(geoms[i].type == CUBE){
				tempLen = boxIntersectionTest(geoms[i], firstRay, tempIntersection, tempNormal);
			}

			else if (geoms[i].type == SPHERE){
				tempLen = sphereIntersectionTest(geoms[i], firstRay, tempIntersection, tempNormal);
			}
			
			else if(geoms[i].type == MESH){
				
			}
							
			//if intersection occurs and object is in front of previously intersected object
			if(tempLen != -1 && tempLen < len){
				len =tempLen;
				intersection = tempIntersection;
				normal = tempNormal;
				objID = i;
			}
		}

		//if no intersection, return
		if(objID == -1)
			return;		
		
		int matID = geoms[objID].materialid;
		surfColor = materials[matID].color;

		//check if you intersected with light, if so, just return light color
		if(materials[matID].emittance > 0){
			colors[index] = surfColor;
			return;
		}

		//else, just do normal color computation
		for(int i = 0; i < numLights; ++i){
			int lightGeomID = lightID[i];
			glm::vec3 lightPos = geoms[lightGeomID].translation;
			//glm::vec3 lightColor = materials[geoms[lightGeomID].materialid].color;

			//find a random point on the light
			if(geoms[lightGeomID].type == CUBE){
				//lightPos = getRandomPointOnCube(geoms[lightGeomID], time);
			}
			else if(geoms[lightGeomID].type == SPHERE){
				//lightPos = getRandomPointOnSphere(geoms[lightGeomID], time);
			}

			//find vector from intersection to point on light
			glm::vec3 L = glm::normalize(lightPos - intersection);

			//do diffuse calculation
			float Kd = glm::clamp(glm::dot(L, normal), 0.0f, 1.0f);		//diffuse
			finalColor = Kd * surfColor ;
		}
		
		colors[index] = finalColor;

	}
}

//TODO: FINISH THIS FUNCTION
// Wrapper for the __global__ call that sets up the kernel calls and does a ton of memory management
void cudaRaytraceCore(uchar4* PBOpos, camera* renderCam, int frame, int iterations, material* materials, int numberOfMaterials, geom* geoms, int numberOfGeoms){
  
  int traceDepth = 1; //determines how many bounces the raytracer traces

  // set up crucial magic
  int tileSize = 8;
  dim3 threadsPerBlock(tileSize, tileSize);			//each block has 8 * 8 threads
  dim3 fullBlocksPerGrid((int)ceil(float(renderCam->resolution.x)/float(tileSize)), (int)ceil(float(renderCam->resolution.y)/float(tileSize)));
  
  //send image to GPU
  glm::vec3* cudaimage = NULL;
  cudaMalloc((void**)&cudaimage, (int)renderCam->resolution.x*(int)renderCam->resolution.y*sizeof(glm::vec3));
  cudaMemcpy( cudaimage, renderCam->image, (int)renderCam->resolution.x*(int)renderCam->resolution.y*sizeof(glm::vec3), cudaMemcpyHostToDevice);
  
  std::vector<int> lightVec;

  //package geometry and materials and sent to GPU
  staticGeom* geomList = new staticGeom[numberOfGeoms];
  for(int i=0; i<numberOfGeoms; i++){
    staticGeom newStaticGeom;
    newStaticGeom.type = geoms[i].type;
    newStaticGeom.materialid = geoms[i].materialid;
    newStaticGeom.translation = geoms[i].translations[frame];
    newStaticGeom.rotation = geoms[i].rotations[frame];
    newStaticGeom.scale = geoms[i].scales[frame];
    newStaticGeom.transform = geoms[i].transforms[frame];
    newStaticGeom.inverseTransform = geoms[i].inverseTransforms[frame];
    geomList[i] = newStaticGeom;
  
	//store which objects are lights
	if(materials[geoms[i].materialid].emittance > 0)
		lightVec.push_back(i);

  }
  
  staticGeom* cudageoms = NULL;
  cudaMalloc((void**)&cudageoms, numberOfGeoms*sizeof(staticGeom));
  cudaMemcpy( cudageoms, geomList, numberOfGeoms*sizeof(staticGeom), cudaMemcpyHostToDevice);

  //copy materials to memory
  material* cudaMaterials = NULL;
  cudaMalloc((void**)&cudaMaterials, numberOfMaterials*sizeof(material));
  cudaMemcpy( cudaMaterials, materials, numberOfMaterials*sizeof(material), cudaMemcpyHostToDevice);

  //copy light ID to memeory
  int numLights = lightVec.size();
  int* lightID = new int[numLights];
  for(int i = 0; i <numLights; ++i)
	  lightID[i] = lightVec[i];
  
  int* cudaLights = NULL;
  cudaMalloc((void**)&cudaLights, numLights*sizeof(int));
  cudaMemcpy( cudaLights, lightID, numLights*sizeof(int), cudaMemcpyHostToDevice);
  
  //package camera
  cameraData cam;
  cam.resolution = renderCam->resolution;
  cam.position = renderCam->positions[frame];
  cam.view = renderCam->views[frame];
  cam.up = renderCam->ups[frame];
  cam.fov = renderCam->fov;

  //kernel launches
  raytraceRay<<<fullBlocksPerGrid, threadsPerBlock>>>(renderCam->resolution, (float)iterations, cam, traceDepth, cudaimage, cudageoms, numberOfGeoms, 
													cudaMaterials, numLights, cudaLights);

  sendImageToPBO<<<fullBlocksPerGrid, threadsPerBlock>>>(PBOpos, renderCam->resolution, cudaimage);

  //retrieve image from GPU
  cudaMemcpy( renderCam->image, cudaimage, (int)renderCam->resolution.x*(int)renderCam->resolution.y*sizeof(glm::vec3), cudaMemcpyDeviceToHost);

  //free up stuff, or else we'll leak memory like a madman
  cudaFree( cudaimage );
  cudaFree( cudageoms );
  cudaFree( cudaMaterials);
  delete geomList;
  delete lightID;

  // make certain the kernel has completed
  cudaThreadSynchronize();

  checkCUDAError("Kernel failed!");
}
