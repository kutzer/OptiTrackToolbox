# OptiTrackToolbox
MATLAB Toolbox for OptiTrack NatNet SDK (**Motive 2.x**). This toolbox interfaces the OptiTrack motion capture hardware through the NatNet SDK. This toolbox allows users to create an OptiTrack object containing all pertinent information and conversions associated with objects tracked using the OptiTrack Motive 2.x software package. This download includes an install file to create the toolbox, and add paths as needed. All toolbox functions include extensive help documentation and error checking.

## Known Issues
1. This toolbox was developed using NatNet SDK for Motive 2.x. This toolbox will not fully function with Motive >2.x (e.g. Motive 3.x). 
    - Some toolbox functionality is available when using Motive 3.x if the OptiTrack object is initialized in debug mode. See OptiTrack.m documentation for additional information.
  
## First Time Installation Instructions
1. Download "OptiTrackToolbox.zip" (or alternate version)
2. Unzip/Extract "OptiTrackToolbox.zip"
3. Open MATLAB as an administrator
4. Change your MATLAB Current Directory to the location containing contents of the unzipped OptiTrackToolbox
5. Run "installOptiTrackToolbox"

## Update Instructions
1. Open MATLAB as an administrator
2. Run "OptiTrackToolboxUpdate"
