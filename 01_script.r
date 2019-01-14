
#install.packages(c("psych", "sandwich",
 #                 "lmtest", "ggplot2", "car"))

##uncomment above if there's any installaction problem here

library(psych)
library(sandwich)
library(lmtest)
library(ggplot2)
# library(car)

df_total <- read.csv('data/data_caio.csv', sep = ',', 
                     fileEncoding = 'utf-8') 


df <- df_total[c('UF','TAXA.DE.HOMICIDIO.DE.NEGROS',
                 'TAXA.DE.HOMICIDIOS.DE.NÃO.NEGROS',
                 'POPULAÇÃO.EVANGÉLICA',
                 'POPULAÇÃO.TOTAL.2010',
                 'TAXA.DE.HOMICIDIOS.POR.ARMA.DE.FOGO',
                 'VOTAÇÃO.JAIR.BOLSONARO...PSL..PRIMEIRO.TURNO_mi')]

colnames(df) <- c('uf','tx_hom_negro','tx_hom_nnegro',
                  'pop_evangelica','populacao','tx_hom_arma',
                  'voto_bolsonaro')


describe(df[c('voto_bolsonaro','tx_hom_negro',
              'tx_hom_arma','pop_evangelica')])


theme_set(theme_bw()) 

ggplot(data=df, aes(voto_bolsonaro)) +
    geom_histogram(bins=10, col="gray") +
        labs(y="Frequency", 
               title="Histogram") 




ggplot(data=df, aes(tx_hom_negro)) +
    geom_histogram(bins=10, col="gray") +
        labs(y="Frequency",       title="Histogram") 



ggplot(data=df, aes(tx_hom_arma)) +
    geom_histogram(bins=10, col="gray") +
        labs(y="Frequency", 
               title="Histogram") 


ggplot(data=df, aes(pop_evangelica)) +
    geom_histogram(bins=10, col="gray") +
        labs(y="Frequency", 
               title="Histogram") 

df$log_vbolsonaro <- log(df$voto_bolsonaro)

df$log_pevangelica <- log(df$pop_evangelica)


ggplot(df, aes(x=tx_hom_negro, y=log_vbolsonaro )) + 
  geom_point(size = 3)+ 
labs(y="Logarithm of of the votes to Bolsonaro", 
     x="Black population homicides rate") + 
ggsave("logBolsoBlackpop.png",    dpi = 300)

ggplot(df, aes(x=tx_hom_arma, y=log_vbolsonaro )) + 
  geom_point(size = 3 ) +
labs(y="Logarithm of of the votes to Bolsonaro",
     x="Gun-related homicides rate") +
ggsave("logBolsoGunrate.png",    dpi = 300)

ggplot(df, aes(x=log_pevangelica, y=log_vbolsonaro )) + 
  geom_point(size = 3 ) + 
labs(y="Logarithm of of the votes to Bolsonaro", 
               x="Log of the Evangelical Population in the EUA") +
ggsave("logBolsologEvan.png",dpi = 300)

reg <- lm(log_vbolsonaro ~ tx_hom_negro + tx_hom_arma +
            log_pevangelica, data = df)


df$predicted <- predict(reg)   # Save the predicted values
df$residuals <- residuals(reg) # Save the residual values

## Sumário do modelo
summary(reg)


ggplot(data=df, aes(residuals)) +
    geom_histogram(bins = 8, col="gray") +
        labs(y="Frequency",x = "Residuals",
             title="Histogram of residuals") + 
ggsave("residualshist.png", dpi = 300) 


plot(reg,which = 1)

ggplot(reg, aes(.fitted, .resid))+
geom_point() + stat_smooth(method="loess")+
geom_hline(yintercept=0, col="red", linetype="dashed")+
xlab("Fitted values")+ylab("Residuals") + 
ggsave("residualsfitted.png", dpi = 300)



coeftest(reg,vcov. = vcovHC)
