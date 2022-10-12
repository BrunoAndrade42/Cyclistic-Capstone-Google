# Carregar o tidyverse, lubridate, ggplot2 libraries
library(tidyverse)
library(lubridate)
library(ggplot2)

# Importar os arquivos CSVs
data_202101 <- read_csv("datasets/202101-divvy-tripdata.csv")
data_202102 <- read_csv("datasets/202102-divvy-tripdata.csv")
data_202103 <- read_csv("datasets/202103-divvy-tripdata.csv")
data_202104 <- read_csv("datasets/202104-divvy-tripdata.csv")
data_202105 <- read_csv("datasets/202105-divvy-tripdata.csv")
data_202106 <- read_csv("datasets/202106-divvy-tripdata.csv")
data_202107 <- read_csv("datasets/202107-divvy-tripdata.csv")
data_202108 <- read_csv("datasets/202108-divvy-tripdata.csv")
data_202109 <- read_csv("datasets/202109-divvy-tripdata.csv")
data_202110 <- read_csv("datasets/202110-divvy-tripdata.csv")
data_202111 <- read_csv("datasets/202111-divvy-tripdata.csv")
data_202112 <- read_csv("datasets/202112-divvy-tripdata.csv")
data_202201 <- read_csv("datasets/202201-divvy-tripdata.csv")
data_202202 <- read_csv("datasets/202202-divvy-tripdata.csv")
data_202203 <- read_csv("datasets/202203-divvy-tripdata.csv")
data_202204 <- read_csv("datasets/202204-divvy-tripdata.csv")
data_202205 <- read_csv("datasets/202205-divvy-tripdata.csv")
data_202206 <- read_csv("datasets/202206-divvy-tripdata.csv")

# Visualizar a estrutura dos dados
str(data_202101)
str(data_202102)
str(data_202103)
str(data_202104)
str(data_202105)
str(data_202106)
str(data_202107)
str(data_202108)
str(data_202109)
str(data_202110)
str(data_202111)
str(data_202112)
str(data_202201)
str(data_202202)
str(data_202203)
str(data_202204)
str(data_202205)
str(data_202206)

# Juntar todos arquivos CSVs em um só 
all_trips <- bind_rows(data_202101, data_202102, data_202103, data_202104, 
                       data_202105, data_202106, data_202107, data_202108, 
                       data_202109, data_202110, data_202111, data_202112, 
                       data_202201, data_202202, data_202203, data_202204, 
                       data_202205, data_202206)

colnames(all_trips)  # Lista do nome das colunas
nrow(all_trips)  # Total de linhas no dataframe
dim(all_trips)  # Dimensões do dataframe
str(all_trips)  # Veja a lista de colunas e tipos de dados (numeric, character, etc)
head(all_trips)  # Ver as primeiras 6 linhas do dataframe
summary(all_trips)  # Resumo estatístico dos dados. Principalmente para números

# Adiciona colunas que lista a data, mês, dia e ano de cada corrida, assim poderemos agregar os dados em dia, mês e ano
all_trips$date <- as.Date(all_trips$started_at)
all_trips$day <- format(as.Date(all_trips$date), "%d")
all_trips$month <- format(as.Date(all_trips$date), "%B")
all_trips$year <- format(as.Date(all_trips$date), "%Y")
all_trips$day_of_week <- format(as.Date(all_trips$date), "%A")


# Verificar se há discrepâncias em member_casual e rideable_type
unique(all_trips$member_casual)
unique(all_trips$rideable_type)

# Verificar quantos NA's possuem cada coluna
colSums(is.na(all_trips))

# Há muitos NA's contido nas colunas start_station_name, start_station_id, end_station_name, end_station_id. Não achei que compensaria remover tudo, então removi o que tinha poucos NA's.
all_trips <- all_trips %>% drop_na(end_lat)

# Ver se possui alguma estação teste
unique(all_trips$start_station_name[grep("TEST", all_trips$start_station_name)])
unique(all_trips$start_station_name[grep("test", all_trips$start_station_name)])

#Seleciona apenas o que esta relacionado as estações
all_trips_station <- all_trips %>% select(start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, year)
head(all_trips_station)

# Total de rotas das estações, tira NA's e rotas duplicadas
all_trips_station <- all_trips_station %>% drop_na() # Tira NA's
all_trips_station <- all_trips_station[!duplicated(all_trips_station[c(1,2)]),] # remove nomes duplicados start_station_name

NROW(unique(all_trips_station$start_station_name))


# Calcula o tempo da corrida e converte para minutos
all_trips$ride_length <- difftime(all_trips$ended_at, all_trips$started_at)
all_trips$ride_length <- all_trips$ride_length/60
all_trips$ride_length <- round(all_trips$ride_length, 2)

# Calcula o tempo da corrida e converte para minutos
all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))
head(all_trips$ride_length)

# Remove observações aonde ride_length é menor que 0
all_trips <- all_trips[!all_trips$ride_length < 0, ]


# Saber um resumo estatístico de ride_length
mean(all_trips$ride_length) # média direta (total ride length / rides)
median(all_trips$ride_length) # mediana
max(all_trips$ride_length) # maior corrida
min(all_trips$ride_length) # menor corrida

summary(all_trips$ride_length) # As quatro linhas acima condensada

# Compara membros e usuários casuais de 2 maneiras diferentes, com aggregate 
# e usando pipe
aggregate(all_trips$ride_length ~ all_trips$member_casual, FUN = mean)
aggregate(all_trips$ride_length ~ all_trips$member_casual, FUN = median)
aggregate(all_trips$ride_length ~ all_trips$member_casual, FUN = max)
aggregate(all_trips$ride_length ~ all_trips$member_casual, FUN = min)

all_trips %>% group_by(member_casual) %>%
  summarise(avg_ride_length = mean(ride_length)
            , median_ride_length = median(ride_length)
            , max_ride_length = max(ride_length)
            , min_ride_length = min(ride_length))

# Organiza dia da semana
all_trips$day_of_week <- ordered(all_trips$day_of_week
                             ,levels= c("domingo","segunda-feira", "terça-feira"
                                        , "quarta-feira", "quinta-feira"
                                        , "sexta-feira", "sábado"))

all_trips$month <- ordered(all_trips$month
                         ,levels= c("janeiro","fevereiro", "março", "abril"
                                    , "maio", "junho", "julho", "agosto"
                                    , "setembro", "outubro", "novembro"
                                    , "dezembro"))


# Tempo médio de corrida por cada dia para usuários membros vs casual
aggregate(all_trips$ride_length ~ all_trips$member_casual + 
            all_trips$day_of_week, FUN = mean)


# Todas corridas por dia da semana, tipo de usuário e ano
all_trips %>% group_by(year, member_casual, day_of_week) %>%
  summarise(number_of_rides = n(),
            average_duration = mean(ride_length)) %>%
  arrange(year, member_casual, day_of_week)

# Todas corridas por dia da semana, tipo de usuário
all_trips %>% group_by(member_casual, day_of_week) %>%
  summarise(number_of_rides = n(),
            average_duration = mean(ride_length)) %>%
  arrange(member_casual, day_of_week)


# Tira a notação científica
options(scipen=999)

# Encontrar o total de usuários casuais e membros nos finais de semana, comparado com dias de semana

final_de_semana_casual <- NROW(filter(all_trips,
  member_casual == "casual" & (day_of_week == "sábado" | day_of_week == "domingo")))

final_de_semana_member <- NROW(filter(all_trips, 
  member_casual == "member" & (day_of_week == "sábado" | day_of_week == "domingo")))


dia_de_semana_casual <- NROW(filter(all_trips, 
  member_casual == "casual" & !(day_of_week == "sábado" | day_of_week == "domingo")))

dia_de_semana_member <- NROW(filter(all_trips, 
  member_casual == "member" & !(day_of_week == "sábado" | day_of_week == "domingo")))

#Porcentagem de usuários casuais e membros dos finais de semana comparado com dias da semana

arr <- c("Dia de semana ", "Finais de semana ")
separar_casual_semana <- c(dia_de_semana_casual, final_de_semana_casual)
percentagem_casual <- round(separar_casual_semana / sum(separar_casual_semana) * 100, 1)
res_casual_semana <- paste(arr, percentagem_casual, "%", sep="")


separar_member_semana <- c(dia_de_semana_member, final_de_semana_member)
percentagem_member <- round(separar_member_semana / sum(separar_member_semana) * 100, 1)
res_member_semana <- paste(arr, percentagem_member, "%", sep="")

res_casual_semana
res_member_semana


# Visualizar o número de corridas por usuários casuais e membros (dia)
all_trips %>% group_by(member_casual, day_of_week) %>%
  summarise(number_of_rides = n()) %>%
  ggplot(aes(x=day_of_week, y=number_of_rides, fill=member_casual)) +
  geom_col(position="dodge") +
  scale_fill_discrete(name = "Member/Casual", labels = c("Casual", "Member")) +
  theme_bw() +
  theme(plot.title=element_text(hjust=0.5)
        , axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Total de corridas por dia", y = "", x= "")


# Visualizar o tempo médio das corridas por usuários casuais e membros
all_trips %>% group_by(member_casual, day_of_week) %>%
  summarise(average_duration = mean(ride_length)) %>%
  ggplot(aes(x=day_of_week, y=average_duration, fill=member_casual)) +
  geom_col(position="dodge") +
  scale_fill_discrete(name = "Member/Casual", labels = c("Casual", "Member")) +
  theme_bw() +
  theme(plot.title=element_text(hjust=0.5)
        , axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Tempo médio das corridas por dia", y = "", x= "")


# Visualizar o número de corridas por usuários casuais e membros (mês)
all_trips %>% group_by(member_casual, month) %>%
  summarise(number_of_rides = n()) %>%
  ggplot(aes(x=month, y=number_of_rides, fill=member_casual)) +
  geom_col(position="dodge") +
  scale_fill_discrete(name = "Member/Casual", labels = c("Casual", "Member")) +
  theme_bw() +
  theme(plot.title=element_text(hjust=0.5)
        , axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Total de corridas por mês", y = "", x= "")


# Visualizar o tempo médio das corridas por usuários casuais e membros (mês)
all_trips %>% group_by(member_casual, month) %>%
  summarise(average_duration = mean(ride_length)) %>%
  ggplot(aes(x=month, y=average_duration, fill=member_casual)) +
  geom_col(position="dodge") +
  scale_fill_discrete(name = "Member/Casual", labels = c("Casual", "Member")) +
  theme_bw() +
  theme(plot.title=element_text(hjust=0.5)
        , axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Tempo médio das corridas por mês", y = "", x= "")


# Visualizara preferência do tipo da bicicleta por usuários casuais e membros
all_trips %>% group_by(rideable_type, member_casual) %>%
  summarise(number_of_rides = n()) %>%
  ggplot(aes(x=member_casual, y=number_of_rides, fill=rideable_type)) +
  geom_col(position="dodge") +
  scale_fill_discrete(name = "Tipo", labels = c("Clássica", "Ancorada", "Elétrica")) +
  theme_bw() +
  theme(plot.title=element_text(hjust=0.5)) +
  labs(title = "Preferência do bicicletas por usuários", y = "", x= "")


# Dividir o member_casual e tirar todos os NA's
all_trips_casual <-  all_trips %>% filter(member_casual == "casual") %>%
  drop_na()
all_trips_member <-  all_trips %>% filter(member_casual == "member") %>%
  drop_na()

# casual
all_trips_casual <- all_trips_casual %>%
  mutate(route = paste(start_station_name, "To", sep=" "))

all_trips_casual <- all_trips_casual %>%       
  mutate(route = paste(route, end_station_name, sep =" "))

# member
all_trips_member <- all_trips_member %>%
  mutate(route = paste(start_station_name, "To", sep=" "))

all_trips_member <- all_trips_member %>%       
  mutate(route = paste(route, end_station_name, sep =" "))


# Encontrar a rota mais popular por numero de corridas

# casual
popular_ride_route_casual <- all_trips_casual %>% 
  group_by(route) %>%
  summarise(number_of_rides  = n(), average_duration_minutes = mean(ride_length)) %>% 
  arrange(route, number_of_rides, average_duration_minutes)

# member
popular_ride_route_member <- all_trips_member %>% 
  group_by(route) %>%
  summarise(number_of_rides  = n(), average_duration_minutes = mean(ride_length)) %>% 
  arrange(route, number_of_rides, average_duration_minutes)

# Cria uma tabela das top 10 rotas

popular_ride_route_top10_casual <- head(arrange(popular_ride_route_casual, desc(number_of_rides)), 10)

popular_ride_route_top10_member <- head(arrange(popular_ride_route_member, desc(number_of_rides)), 10)

head(popular_ride_route_top10_casual, 10)
head(popular_ride_route_top10_member, 10)


# Separa os top 10 estação start e end

popular_ride_route_top10_casual <- popular_ride_route_top10_casual %>%
  separate(route, c("start_station_name", "end_station_name"), sep = " To ")


popular_ride_route_top10_member <- popular_ride_route_top10_member %>%
  separate(route, c("start_station_name", "end_station_name"), sep = " To ")


# Seleciona as colunas start, average ride e número de corridas
route_top10_start_casual <- popular_ride_route_top10_casual[,c(1,3,4)]
route_top10_start_member <- popular_ride_route_top10_member[,c(1,3,4)]


# Juntar com all_trips_stations para pegar a latitude e longitude das top das estações
top10_stations_casual <- merge(popular_ride_route_top10_casual, all_trips_station)
top10_stations_casual
top10_stations_member <- merge(popular_ride_route_top10_member, all_trips_station)


# Juntar com all_trips_stations para pegar a latitude e longitude das top das estações
top10_stations_member <- merge(popular_ride_route_top10_member, all_trips_station)
top10_stations_member


# Função que serve para criar gráfico de pizza
piechart <- function(arr, separar_semana, percentagem, title) {
  data_casual <- data.frame(
    class=arr,
    n=separar_semana,
    prop=percentagem
  )
  
  # Visualizar o número de corridas por usuários casuais e membros (dia)
  data_casual %>%  arrange(desc(class)) %>%
    mutate(lab.ypos = cumsum(prop) - 0.5*prop) %>%
    ggplot(aes(x="", y=prop, fill=class)) +
    geom_bar(stat="identity", width=1, color="white") +
    coord_polar("y", start=0) +
    geom_text(aes(y = lab.ypos, label = prop), color = "white")+
    scale_fill_discrete(name = "Semana") +
    labs(title = title, y = "", x= "") +
    theme_void()
}
piechart(arr, separar_casual_semana, percentagem_casual, "Distribuição dos casuais pela semana")
piechart(arr, separar_member_semana, percentagem_member, "Distribuição dos membros pela semana")







