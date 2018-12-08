# Final Project for STAT 432, Statistical Learning
This is the code base for the term project for the statistical learning class taught at the University of Illinois at Urbana-Champaign

**Team: ** Fantastic Four
**Members: ** Megan Finnegan (*team contact*); Krishna Bharadwaj; Do Hyun Hwang; Rohan Dalmia

*The content of this project is exploring the clustering accuracy of k-means applied to short time window correlation matrices in fMRI task-based paradigms. k-means is an approach widely used in dynamic connectivity, however it is currently unknown if connectivity matrices are well suited for this approach. Test accuracy is reported for k-means and the performance of alternate classification methods compared. For a summary of the work contained herein, please read the project proposal and the final report pdf's.*

Note that the results of this project are preliminary and several more nuanced considerations have not been implemented given the limited scope and time frame of the class. Although this code is made publicly available it is not intended in any way to make definitive recommendations for classification algorithms or parameters, but merely to suggest future directions.
___

## Running Code
To execute the core computations relevant to this project, a file called `loader.r` has been included in the top-level folder of this project. This will recalculate all results reported based on the starting data of "raw" ROI time courses.

The data used in the project is available upon request and from approval of the Principle Investigator for the original data (Dr. Heidemarie Laurent). Once obtained, place the data folder in the top-level folder and execute the loader file.

A summary of these results included in the reports folder and is submitted for grading in this class.
___

This project is organized into several subfolders that execute distinct phases of this project. They are as follows:

1. **Preprocessing**
   - This is largely for documentation purposes of the data cleaning steps taken in order to produce the ROI time courses. The original data from these experiments is not sumbitted with this project.
     - **dcmConvert** - This contains a batch and script written in MATLAB for the SPM12 toolbox to convert dicom images, which are the standard image format for MRI machines, to NIfTI format, the standard format used in fMRI analysis. The code was implemented in a parallel fashion and the single subject folder contains a template batch for converting a single subject's data.
     - **preprocess** - This contains the preprocessing pipeline for the original data. It contains a batch file created for SPM12 and follows standard preprocessing steps for block-designs in fMRI. This includes slice-timing correction, realignment, gradient field distortion unwarping, coregistration to a high resolution structural image, normalization to standard stereotaxic space (MNI space), and spatial smoothing. See final report for details of the parameters used in this process. 