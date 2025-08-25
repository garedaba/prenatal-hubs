V = 90;

load(['Term_ToUse_uBrain',num2str(V),'_SC_data.mat'],'sc_indv_term')
load(['Term_ToUse_uBrain',num2str(V),'_LEN_data.mat'],'len_indv_term')

load('DemographicData.mat')
%%

thr = .15;

GrpAvg = MakeGroupAverage(sc_indv_term,thr);

Ages = 37:44;

GrpAvgAge = zeros([length(GrpAvg) length(GrpAvg) length(Ages)]);
NperAgeRange = zeros([length(Ages) 1]);

ScanAge = DemographicData.ScanAge;

for i = 1:length(Ages)
age = Ages(i);
Select = ScanAge >= age & ScanAge < age+1;

termdata2use = sc_indv_term(:,:,Select);

GrpAvgAge(:,:,i) = MakeGroupAverage(termdata2use,thr);

NperAgeRange(i) = sum(Select);
end

%%

Niter = 100;

DegCorrBoot = zeros(208,Niter);

deg = sum(GrpAvg>0,2);

h = waitbar(0);

TotalIter = 208*Niter;

iterN = 0;
t= 0;

for i = 1:208

for iter = 1:Niter

tic

if DegCorrBoot(i,iter) == 0

Select = randi(208,[i 1]);

termdata2use = sc_indv_term(:,:,Select);

B = MakeGroupAverage(termdata2use,thr);

degB = sum(B>0,2);

DegCorrBoot(i,iter) = corr(deg,degB);

iterN = iterN + 1;

t = (t+toc)/iterN;

waitbar(iterN / TotalIter, h, ['Finished iteration ', num2str(iter), '/50 of ',num2str(i),'/208 (time per iteraion = ',num2str(t),')']);

end

end

end

save('SensitivityResult.mat','DegCorrBoot','GrpAvgAge','GrpAvg','NperAgeRange','Ages')