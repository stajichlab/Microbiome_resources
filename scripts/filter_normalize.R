library(gplots)
library(RColorBrewer)
library(colorRamps)
library(vegan)
library(pheatmap)

 
palette_bluewhite <- colorRampPalette(c('red','white','blue'))(50)
scaleyellowred <- colorRampPalette(c("lightyellow", "red"), space = "rgb")(100)

n<-read.csv("OTUs_count_reordercols.csv",header=T,row.names=1,sep=",")
#summary(n)
head(n)
#head(nt)
colsum <- colSums(n)
head(colsum)
data.prop <- n / colsum

for ( i in 1:length(n)) {
 data.prop[,i] <- 100 * (n[,i] / colsum[i])
}
# these should all be 100 (add to 100%)
colSums(data.prop)
write.csv(data.prop,"OTUs_freqinsample.csv")


maxab <- apply(data.prop, 1, max)
head(maxab)
maxab
n1 <- names(which(maxab > 5))
length(n1)
rownames(data.prop)
data.prop.1 <- data.prop[which(rownames(data.prop) %in% n1),]

write.csv(data.prop.1,"OTUs_freqinsample_5percent_filter.csv")

