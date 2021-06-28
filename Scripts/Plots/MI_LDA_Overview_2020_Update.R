library(ggplot2)
library(ggrepel)
library(R.matlab)
library(gridExtra)
library(egg)
library(ggpubr)
Features  <- c('Power','Power','Power','Power','Power','Power','wPLI','wPLI','wPLI','wPLI','wPLI','wPLI','wSMI','wSMI','wSMI','wSMI','wSMI','wSMI')

Labels  <- c('Delta-Power', 'Theta-Power', 'Alpha-Power', 'Sigma-Power', 'Beta-Power', 'Gamma-Power', 'Delta-wPLI', 'Theta-wPLI', 'Alpha-wPLI', 'Sigma-wPLI', 'Beta-wPLI', 'Gamma-wPLI', 'Delta-wSMI', 'Theta-wSMI', 'Alpha-wSMI', 'Sigma-wSMI', 'Beta-wSMI', 'Gamma-wSMI')

data <- readMat('/Users/laura.imperatori/MI_LDA_WN2N3REM_230920_4.mat') 

MEANBSMI=apply(data$I1SBIN, c(1,2), mean)
MEANBSLDA=colMeans(data$AccDist);
MIBIN = colMeans(MEANBSMI); LDAACC = MEANBSLDA; 
allsdmi <- apply(MEANBSMI, 2,sd)/sqrt(24)
lowermi=MIBIN-allsdmi
uppermi=MIBIN+allsdmi
allsdlda <- apply(data$AccDist, 2,sd)
lowerlda=MEANBSLDA-allsdlda
upperlda=MEANBSLDA+allsdlda

df <- data.frame(MIBIN, LDAACC, LDAMI, Features, Labels, lowermi, uppermi, lowerlda, upperlda)
corr <- cor.test(x=df$MIBIN, y=df$LDAACC, method = 'spearman')
print(corr$estimate)
print(corr$p.value)
n <- 500
pall <- ggplot(df, aes(MIBIN, LDAACC, shape = Features)) +
  geom_errorbarh(data=df,aes(xmin=uppermi, xmax=lowermi))+
  geom_errorbar(data=df,aes(ymin=upperlda, ymax=lowerlda))+ 
  geom_point(aes(colour = Features),size = 3) + scale_y_continuous(labels = scales::percent_format(accuracy = 1))+
  geom_text_repel(aes(MIBIN, LDAACC, label = Labels),  force = 5, max.iter = n, size=4) +
  ggtitle("Wakefulness vs. N2-\n vs. N3- vs. REM-Sleep") + 
  xlab("Mutual Information (within subjects)") + ylab("Classification Accuracy (across subjects)") + theme(aspect.ratio=1, plot.title = element_text(hjust = 0.5, size = 24), text = element_text(size = 16), axis.line = element_line(colour = "black"))
pall


data <- readMat('/Users/laura.imperatori/MI_LDA_CUC_230920_4.mat') #WN2N3REM

MEANBSMI=apply(data$I1SBIN, c(1,2), mean)
MEANBSLDA=colMeans(data$AccDist);
MIBIN = colMeans(MEANBSMI); LDAACC = MEANBSLDA; 
allsdmi <- apply(MEANBSMI, 2,sd)/sqrt(24)
lowermi=MIBIN-allsdmi
uppermi=MIBIN+allsdmi
allsdlda <- apply(data$AccDist, 2,sd)
lowerlda=MEANBSLDA-allsdlda
upperlda=MEANBSLDA+allsdlda

df <- data.frame(MIBIN, LDAACC, LDAMI, Features, Labels, lowermi, uppermi, lowerlda, upperlda)
corr <- cor.test(x=df$MIBIN, y=df$LDAACC, method = 'spearman')
print(corr$estimate)
print(corr$p.value)
n <- 500
pcuc <- ggplot(df, aes(MIBIN, LDAACC, shape = Features)) +
  geom_errorbarh(data=df,aes(xmin=uppermi, xmax=lowermi))+
  geom_errorbar(data=df,aes(ymin=upperlda, ymax=lowerlda))+ 
  geom_point(aes(colour = Features),size = 3) + scale_y_continuous(labels = scales::percent_format(accuracy = 1))+
  geom_text_repel(aes(MIBIN, LDAACC, label = Labels),  force = 5, max.iter = n, size=4) +
  ggtitle("Wakefulness and REM-Sleep \n vs. N2- and N3-Sleep") + 
  xlab("Mutual Information (within subjects)") + ylab("Classification Accuracy (across subjects)") + theme(aspect.ratio=1, plot.title = element_text(hjust = 0.5, size = 24), text = element_text(size = 16), axis.line = element_line(colour = "black"))
pcuc


data <- readMat('/Users/laura.imperatori/MI_LDA_WREM_230920_4.mat') #WN2N3REM

MEANBSMI=apply(data$I1SBIN, c(1,2), mean)
MEANBSLDA=colMeans(data$AccDist);
MIBIN = colMeans(MEANBSMI); LDAACC = MEANBSLDA; 
allsdmi <- apply(MEANBSMI, 2,sd)/sqrt(24)
lowermi=MIBIN-allsdmi
uppermi=MIBIN+allsdmi
allsdlda <- apply(data$AccDist, 2,sd)
lowerlda=MEANBSLDA-allsdlda
upperlda=MEANBSLDA+allsdlda
df <- data.frame(MIBIN, LDAACC, LDAMI, Features, Labels, lowermi, uppermi, lowerlda, upperlda)
corr <- cor.test(x=df$MIBIN, y=df$LDAACC, method = 'spearman')
print(corr$estimate)
print(corr$p.value)
n <- 500
pwrem <- ggplot(df, aes(MIBIN, LDAACC, shape = Features)) +
  geom_errorbarh(data=df,aes(xmin=uppermi, xmax=lowermi))+
  geom_errorbar(data=df,aes(ymin=upperlda, ymax=lowerlda))+ 
  geom_point(aes(colour = Features),size = 3) + scale_y_continuous(labels = scales::percent_format(accuracy = 1))+
  geom_text_repel(aes(MIBIN, LDAACC, label = Labels),  force = 5, max.iter = n, size=4) +
  ggtitle("Wakefulness vs. REM-Sleep\n") + 
  xlab("Mutual Information (within subjects)") + ylab("Classification Accuracy (across subjects)") + theme(aspect.ratio=1, plot.title = element_text(hjust = 0.5, size = 24), text = element_text(size = 16), axis.line = element_line(colour = "black"))
pwrem


pnew <-ggarrange(pall, pcuc, pwrem,
                 labels = c("A", "B", "C"),
                 ncol = 3, nrow = 1, common.legend = TRUE, legend = c("bottom"))+ theme(aspect.ratio=1/3)
annotate_figure(pnew,  top= text_grob("MI vs. LDA Accuracy: Within-subject comparison vs. predictability", face="bold", size=14))


# panel.background = element_blank(), axis.line = element_line(colour = "black"), panel.grid.major = element_line(size = 0.5, linetype = 'solid', colour = "grey"), panel.grid.minor = element_line(size = 0.25, linetype = 'solid', colour = "grey"))


# p <-ggarrange(p1, p2, p3, p4,
#           labels = c("A", "B", "C", "D"),
#           ncol = 2, nrow = 2, common.legend = TRUE, legend = c("bottom"))
# annotate_figure(p,  top= text_grob("Wakefulness vs. N2 vs. N3 vs. REM", face="bold", size=14))



# pnew <-ggarrange(p1, pIS, pIA, pIMI,
#                  labels = c("A", "B", "C", "D"),
#                  ncol = 2, nrow = 2, common.legend = TRUE, legend = c("bottom"))
# annotate_figure(pnew,  top= text_grob("Wakefulness and REM-Sleep vs. N2 and N3 sleep", face="bold", size=14))
