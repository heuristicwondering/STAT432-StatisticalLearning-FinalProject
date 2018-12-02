setwd("C:/Users/krish/OneDrive/Krishna/Coursework/STAT432/Final project/data/ROI_timecourses/112")

MyData <- read.csv(file="112_affect_1_AALROImeanTimeCourses.csv", header=TRUE, sep=",")

data.isi        =MyData[which(MyData[,1]=="ISI"),]
corr.isi=cor(data.isi[,-1])
write.csv(corr.isi, file="corr_isi_subject.csv")


data.EmoLabNeg  =MyData[which(MyData[,1]=="EmoLabelNeg"),]
corr.EmoLabNeg=cor(data.EmoLabNeg[,-1])


data.EmoLabPos  =MyData[which(MyData[,1]=="EmoLabelPos"),]
corr.EmoLabPos=cor(data.EmoLabPos[,-1])


data.EmoLookNeg =MyData[which(MyData[,1]=="EmoLookNeg"),]
corr.EmoLookNeg=cor(data.EmoLookNeg[,-1])


data.EmoLookPos =MyData[which(MyData[,1]=="EmoLookPos"),]
corr.EmoLookPos=cor(data.EmoLookPos[,-1])








corr.isi=cor(data.isi[,-1])
