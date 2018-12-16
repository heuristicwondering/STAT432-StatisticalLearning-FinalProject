part_name = c('Precentral_L', 'Precentral_R', 'Frontal_Sup_L',
              'Frontal_Sup_R', 'Frontal_Sup_Orb_L', 'Frontal_Sup_Orb_R',
              'Frontal_Mid_L', 'Frontal_Mid_R', 'Frontal_Mid_Orb_L',
              'Frontal_Mid_Orb_R', 'Frontal_Inf_Oper_L', 'Frontal_Inf_Oper_R',
              'Frontal_Inf_Tri_L', 'Frontal_Inf_Tri_R', 'Frontal_Inf_Orb_L',
              'Frontal_Inf_Orb_R', 'Rolandic_Oper_L', 'Rolandic_Oper_R',
              'Supp_Motor_Area_L', 'Supp_Motor_Area_R', 'Olfactory_L',
              'Olfactory_R', 'Frontal_Sup_Medial_L', 'Frontal_Sup_Medial_R',
              'Frontal_Med_Orb_L', 'Frontal_Med_Orb_R', 'Rectus_L', 'Rectus_R',
              'Insula_L', 'Insula_R', 'Cingulum_Ant_L', 'Cingulum_Ant_R',
              'Cingulum_Mid_L', 'Cingulum_Mid_R', 'Cingulum_Post_L',
              'Cingulum_Post_R', 'Hippocampus_L', 'Hippocampus_R',
              'ParaHippocampal_L', 'ParaHippocampal_R', 'Amygdala_L',
              'Amygdala_R', 'Calcarine_L', 'Calcarine_R', 'Cuneus_L',
              'Cuneus_R', 'Lingual_L', 'Lingual_R', 'Occipital_Sup_L',
              'Occipital_Sup_R', 'Occipital_Mid_L', 'Occipital_Mid_R',
              'Occipital_Inf_L', 'Occipital_Inf_R', 'Fusiform_L', 'Fusiform_R',
              'Postcentral_L', 'Postcentral_R', 'Parietal_Sup_L', 'Parietal_Sup_R',
              'Parietal_Inf_L', 'Parietal_Inf_R', 'SupraMarginal_L', 
              'SupraMarginal_R', 'Angular_L', 'Angular_R', 'Precuneus_L',
              'Precuneus_R', 'Paracentral_Lobule_L', 'Paracentral_Lobule_R',
              'Caudate_L', 'Caudate_R', 'Putamen_L', 'Putamen_R', 'Pallidum_L',
              'Pallidum_R', 'Thalamus_L', 'Thalamus_R', 'Heschl_L', 'Heschl_R',
              'Temporal_Sup_L', 'Temporal_Sup_R', 'Temporal_Pole_Sup_L',
              'Temporal_Pole_Sup_R', 'Temporal_Mid_L', 'Temporal_Mid_R',
              'Temporal_Pole_Mid_L', 'Temporal_Pole_Mid_R', 'Temporal_Inf_L',
              'Temporal_Inf_R', 'Cerebelum_Crus1_L', 'Cerebelum_Crus1_R',
              'Cerebelum_Crus2_L', 'Cerebelum_Crus2_R', 'Cerebelum_3_L',
              'Cerebelum_3_R', 'Cerebelum_4_5_L', 'Cerebelum_4_5_R',
              'Cerebelum_6_L', 'Cerebelum_6_R', 'Cerebelum_7b_L',
              'Cerebelum_7b_R', 'Cerebelum_8_L', 'Cerebelum_8_R',
              'Cerebelum_9_L', 'Cerebelum_9_R', 'Cerebelum_10_L',
              'Cerebelum_10_R', 'Vermis_1_2', 'Vermis_3', 'Vermis_4_5',
              'Vermis_6', 'Vermis_7', 'Vermis_8', 'Vermis_9', 'Vermis_10')
part_code = aal116$name
fin = data.frame(Name = part_name, Code = part_code)
fin$Code = levels(fin$Code)[as.numeric(fin$Code)]
fin$Name = levels(fin$Name)[as.numeric(fin$Name)]
x = list.files()
#function to detect integer(0) error
is.integer0 <- function(x)
{
  is.integer(x) && length(x) == 0L
}

#removes files names with ISI in them
y = c()
for (m in 1:528) {
  if (is.integer0(grep("ISI", x[m])))
    y[m] = m
}

y = y[!is.na(y)]
x = x[34]

library(brainGraph)
library(igraph)
richclub_coef = numeric(432)
mean_dist = numeric(432)
for (i in 1:length(x)) {
  file = read.csv(x[i])
  cor_mat = as.matrix(file)
  data = cor_mat[,-1]
  rownames(data) = data[,1]
  for (j in 1:116) {
    for (k in 1:116) {
      if(colnames(data)[j] == fin$Name[k])
        colnames(data)[j] = fin$Code[k]
    }
  }
  rownames(data) = colnames(data)
  cor_g <- graph_from_adjacency_matrix(data, mode='directed',
                                       weighted = 'correlation')
  cor_edge_list <- igraph::as_data_frame(cor_g, 'edges')
  only_sig <- cor_edge_list[abs(cor_edge_list$correlation)>.85 &
                              abs(cor_edge_list$correlation)<1 , ]
  new_g <- graph_from_data_frame(only_sig, T)
  bg = make_brainGraph(new_g, atlas = "aal116")
  richclub_coef[i] = rich_club_coeff(bg)$phi  
  mean_dist[i] = mean_distance(bg)
}


results = data.frame("Data" = x, "Rich_Club_Coefficient" = richclub_coef,
                     "Avg_path_length" = mean_dist)




results.matrix = as.matrix(results[,-1])

z = c()
kval = 2:10
for (i in kval) {
  y = kmeans(results.matrix, i)
  z[i] = mean(y$withinss)
}
WCSS = z[!is.na(z)]
plot(kval, WCSS , type = "b", main = "k-value for Graph Metrics")

fin_clust = kmeans(results.matrix, 4, nstart = 50)
results$cluster = fin_clust$cluster

results$stimuli = gsub(".csv", "", substring(results$Data, 35))
dat = results[,c(4,5)]

table(dat)

