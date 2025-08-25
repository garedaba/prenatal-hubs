V = 90;
thr = .15;

load(['Term_ToUse_uBrain',num2str(V),'_SC_data.mat'],'sc_indv_term')
load(['Term_ToUse_uBrain',num2str(V),'_LEN_data.mat'],'len_indv_term')

load(['GrpAvg_uBrain',num2str(V),'_thr_',num2str(thr),'.mat'],'D','GrpAvg')

A = double(GrpAvg>0);

degA = sum(A>0,2);

%%

IndvCorrWithGrp = zeros(size(sc_indv_term,3),1);

for i = 1:size(sc_indv_term,3)
    
    sub2use = sc_indv_term(:,:,i);
    B = strength_threshold(sub2use,thr);
    degB = sum(B>0,2);
    
    IndvCorrWithGrp(i) = corr(degA,degB);

end

%%

isHub = zeros(size(sc_indv_term,3),length(A));
for i = 1:size(sc_indv_term,3)
    IndvA = double(strength_threshold(squeeze(sc_indv_term(:,:,i)),thr)>0);
    deg = sum(IndvA);
    threshold = prctile(deg, 90);
    isHub(i,:) = deg > threshold; % Define hub nodes based on threshold (i.e., top 10% of nodes by degree)
end

save(['./data/IndvHubResult_uBrain',num2str(V),'_thr_',num2str(thr),'.mat'],'isHub','IndvCorrWithGrp')