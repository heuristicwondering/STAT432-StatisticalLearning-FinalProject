library('FIAR')

ShiftVarNames <- function(stimuli){
  # Creates the design matrix, shifts everything by the HRF, then assigns new labels
  #
  # Build design matrix
  design = data.frame(matrix(0, nrow = length(stimuli), ncol = length(levels(stimuli))))
  colnames(design) <- levels(stimuli)
  for(s in levels(stimuli)){
    design[which(stimuli == s),s] <- 1
  }
  
  # Due to an undocument feature of the hrfConvolve function, when raw data is passed, 
  # the assumed aqcuistion rate (TR) is 1 second. Since our data has TR =  2, expand 
  # design matrix to account for this.
  expandedDesign = rbind(design, design)
  n = nrow(design); r <- rep(1:n, each = 2) + (0:1) * n
  expandedDesign <- expandedDesign[r,]; rownames(expandedDesign) <- c(1:(n*2))
  # Shift value in each column by the HRF
  expandedDesign = apply(expandedDesign, MARGIN = 2, hrfConvolve)
  # Down sampling - taking the value at the first second of onset as the instantaneous 
  # value due to slice timing correction to the time point in preprocessing.
  design <- expandedDesign[seq(1,n,2),]
  
  # Reassigning stimuli labels according to what has the max value
  maxStimIndx = apply(design, MARGIN = 1, which.max)
  newStim = levels(stimuli)[maxStimIndx]
  # Although convolution may assign higher values to other stimuli, early time points 
  # should have the label of the first stim presented until it reaches it's first peak
  firstStimIndx = which(newStim == stimuli[1])[1] # Index of first occurance of first stim
  newStim[1:firstStimIndx] <- levels(stimuli)[stimuli[1]]
  
  return(newStim)
  
}

split_path <- function(path) {
  rev(setdiff(strsplit(path,"/|\\\\")[[1]], ""))
}

parentdir <- file.path('..','..','data','ROI_timecourses (With infant ISI removed)')
childdirs = list.dirs(path = parentdir, full.names = TRUE, recursive = FALSE)

newparentdir <- file.path('..','..','data','ROI_timecourses_wo-Inf-ISI_labels-shifted-by-HRF')
dir.create(newparentdir)

for(d in childdirs){
  all.files <- list.files(d, rec=F)
  
  for(f in all.files){
    data = read.csv( file.path(d, f) )
    stimuli = data[,1]
    newStimuli = ShiftVarNames(stimuli)
    data[,1] <- newStimuli
    
    dataFldr = split_path(d)[1]
    newDatadir = file.path(newparentdir, dataFldr)
    dir.create(newDatadir)
    write.csv(data, file = file.path(newDatadir, f), row.names=FALSE)
  }
}