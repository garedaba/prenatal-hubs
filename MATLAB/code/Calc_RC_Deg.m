%% Gets the mean degree for each ubrain parcel and calculate the rich-club 
% coefficients for the subdivided parcellation 

load('ubrain_subdiv_ParcOrder.mat')

vertSizes = [60 90 120];

runRC = 1;

RCiters = 100;

for v = 1:3

V = vertSizes(v);

if runRC

    for thr = [.05 .15 .25]
    
        load(['GrpAvg_subdiv',num2str(V),'_thr_',num2str(thr),'.mat'],'D','GrpAvg')
    
        A = double(GrpAvg>0);
        
        [PhiTrue, PhiRand] = rich_club_analysis_normalized(A,RCiters);
        
        PhiNorm = PhiTrue./nanmean(PhiRand);
        
        save(['./data/RC_subdiv',num2str(V),'_thr_',num2str(thr),'.mat'],'PhiNorm','PhiTrue','PhiRand')
    
    end

end

run = 1;

if run
    
    V = 90;
    thr = 0.15;
    order = ParcOrder.(['vert',num2str(V)]);
    N = length(order);
    
    load(['GrpAvg_subdiv',num2str(V),'_thr_',num2str(thr),'.mat'],'D','GrpAvg')
       
    LParcID = dlmread(['uBrain',num2str(V),'verts.txt']);
    ROIperHemi = max(LParcID);
    RParcID = LParcID;
    TotalROI = ROIperHemi*2;
        
    deg = sum(GrpAvg>0);
    
    hubness = double(deg>=prctile(deg,90));
        
    Linds = 1:ROIperHemi;
    Rinds = ROIperHemi+1:TotalROI;
    
    ubrain = gifti('dHCP.week36.R.ubrain.label.gii');
    ubrainparc_id = ubrain.labels.key;
    
    ubrain_parc = double(ubrain.cdata);
    
    dataMatL = zeros(29,2);
    dataMatR = zeros(29,2);
    parc_orig_ind = zeros(N/2,1);
    parc_orig_indR = zeros(N/2,1);

    for i = 1:N/2
       parc_orig_ind(i)  = mode(ubrain_parc(LParcID==i));
       parc_orig_indR(i)  = mode(ubrain_parc(RParcID==i));
    end
    
    for i = 1:29
        
        dataMatL(i,1) = mean(deg(parc_orig_ind==i));
        dataMatL(i,2) = sum(parc_orig_ind==i);
        Rinds = find(parc_orig_indR==i)+(N/2);
        
        dataMatR(i,1) = mean(deg(Rinds));
        dataMatR(i,2) = length(Rinds);
    end
    
    ubrain_name = ubrain.labels.name(2:30)';  
    T = array2table(dataMatL);
    T2 = table(ubrain_name);
    T3 = [T2 T];
    T3.Properties.VariableNames = {'Region','mean_degree','Nsubparc'};
    writetable(T3,['./data/ubrain_subdiv',num2str(V),'_hubness_left.xlsx'])
    T = array2table(dataMatR);
    T2 = table(ubrain_name);
    T3 = [T2 T];
    T3.Properties.VariableNames = {'Region','mean_degree','Nsubparc'};
    writetable(T3,['./data/ubrain_subdiv',num2str(V),'_hubness_right.xlsx'])

end


end