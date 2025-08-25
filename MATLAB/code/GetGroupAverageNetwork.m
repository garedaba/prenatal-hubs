
for V = [60 90 120]

load(['Term_ToUse_subdiv',num2str(V),'_SC_data.mat'],'sc_indv_term')
load(['Term_ToUse_subdiv',num2str(V),'_LEN_data.mat'],'len_indv_term')

    for thr = [.05 .15 .25]
    
    [GrpAvg, Connsum] = MakeGroupAverage(sc_indv_term,thr);

    A = GrpAvg>0;

    len_indv_term_mean = nansum(len_indv_term,3)./Connsum;
    len_indv_term_mean(isnan(len_indv_term_mean))=0;
    D = len_indv_term_mean.*double(A).*~eye(length(A));

    save(['./data/GrpAvg_subdiv',num2str(V),'_thr_',num2str(thr),'.mat'],'D','GrpAvg')
    
    end

end