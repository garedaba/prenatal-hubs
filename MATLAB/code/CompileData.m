
%% Read in demographic data, identify individuals to use

dHCP_meta = readtable('dHCP_subdata.xlsx');
SES = dHCP_meta.session_id;
SUB = dHCP_meta.participant_id;
load('uBrain_ParcOrder.mat')

sub_age = dHCP_meta.birth_age; 

% Find the term neonates

IsTerm = sub_age>=37;

IsTermInd = find(IsTerm);

TermScan_age = dHCP_meta.scan_age(IsTerm);
TermRadscore = dHCP_meta.radiology_score(IsTerm);
termSUB = dHCP_meta.participant_id(IsTerm);
[U,~,ic] = unique(termSUB);
a_counts = accumarray(ic,1);
dupSub = find(a_counts>1);

% Find term neonates with a good radiological score

ToUse = TermRadscore<=2;

% Find any duplicate individuals, use their oldest scan

for i = 1:length(dupSub)
    sub_scans = find(ismember(termSUB,U{dupSub(i)}));
    [~,I] = max(TermScan_age(sub_scans));
    sub_scans(I) = [];
    ToUse(sub_scans) = false;
end

% Get the demographic data for the sample

DemographicData = table;
DemographicData.participant_id = dHCP_meta.participant_id(IsTermInd(ToUse));
DemographicData.session_id = dHCP_meta.session_id(IsTermInd(ToUse));
DemographicData.BirthAge = dHCP_meta.birth_age(IsTermInd(ToUse));
DemographicData.ScanAge = TermScan_age(ToUse);
DemographicData.sex = dHCP_meta.sex(IsTermInd(ToUse));

save('DemographicData.mat','DemographicData')

%%

mkdir .\data\compiled

vertSizes = [60 90 120];

for v = 1

V = vertSizes(v);
order = ParcOrder.(['vert',num2str(V)]);
N = length(order);
sc_indv_all = zeros(N,N,363);
len_indv_all = zeros(N,N,363);

h = waitbar(0);

for i = 1:363
    ses = SES(i);
    sub = SUB{i};
    filename = ['.\data\raw\',num2str(V),'\SC\',sub,'_',num2str(ses),'_ubrain_subdiv_',num2str(V),'_sc.txt'];
    filename2 = ['.\data\raw\',num2str(V),'\LEN\',sub,'_',num2str(ses),'_ubrain_subdiv_',num2str(V),'_len.txt'];
    
    %if exist(filename,"file") == 2

    % Because of the smoothing, the matrices aren't perfectly symmetrical.
    % We make them by adding the upper and lower triangles of the matrix
    a = dlmread(filename);
    A = a(order,order);
    Asim = (A+A')/2;
    sc_indv_all(:,:,i) = Asim;
   
    l = dlmread(filename2);
    L = l(order,order);
    Lsim = (L+L')/2;
    len_indv_all(:,:,i) = Lsim./Asim;

    %end  
    waitbar(i / 363, h, ['Compiled ', num2str(i), ' of 363']);
end

sc_indv_term = sc_indv_all(:,:,IsTermInd(ToUse));

len_indv_term = len_indv_all(:,:,IsTermInd(ToUse));

save(['.\data\compiled\Term_ToUse_uBrain',num2str(V),'_SC_data.mat'],'sc_indv_term')
save(['.\data\compiled\Term_ToUse_uBrain',num2str(V),'_LEN_data.mat'],'len_indv_term')

end