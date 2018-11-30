files <- dir("path", recursive=TRUE, full.names=TRUE, pattern="\\.csv$")

filename = vector("character", length(files))
for (i in 1:length(files)) {
  filename[i] = substr(files[i],61,98)
}

#set working directory to an empty folder

for (j in 1:96) {
  mydata = read.csv(file = files[j])
  stimuli = as.vector(unique(mydata[, 1]))
  for (i in stimuli) {
    #mydata=read.csv(assign(filename[j], read.csv(files[j]))
    data = mydata[which(mydata[, 1] == i), ]
    corr = cor(data[, c(2:117)])
    write.csv(corr , paste0(substr(filename[j], 1, 34), i, ".csv"))
  }
}

