function MakeRCHubPlot(V,thr)

L = gifti('week-40_hemi-left_space-dhcpSym_dens-32k_midthickness.surf.gii');
R = gifti('week-40_hemi-right_space-dhcpSym_dens-32k_midthickness.surf.gii');

Rsurf.vertices = double(R.vertices);
Rsurf.faces = double(R.faces);
Lsurf.vertices = double(L.vertices);
Lsurf.faces = double(L.faces);

LParcID = dlmread(['uBrain',num2str(V),'verts.txt']);
ROIperHemi = max(LParcID);
RParcID = LParcID;
TotalROI = ROIperHemi*2;

ubrain = gifti('dHCP.week36.R.ubrain.label.gii');
ubrainparc_id = ubrain.labels.key;
ubrain_parc = double(ubrain.cdata);
ubrain_cmap = ubrain.labels.rgba(2:30,1:3); 

ubrain_region_names = ubrain.labels.name;

load(['GrpAvg_uBrain',num2str(V),'_thr_',num2str(thr),'.mat'],'D','GrpAvg')

A = double(GrpAvg>0);

N = length(GrpAvg);

parc_orig_ind = zeros(N/2,1);
parc_orig_indR = zeros(N/2,1);
for i = 1:N/2
   parc_orig_ind(i)  = mode(ubrain_parc(LParcID==i));
   parc_orig_indR(i)  = mode(ubrain_parc(RParcID==i));
end

Dvec = triu2vec(D);

deg = double(sum(A,2));

threshold = prctile(deg,90);
disp(['uBrain',num2str(V),' thr = ',num2str(thr), ', degree 90th percentile = ',num2str(threshold)])

%%
TL = subplot(12,12,[1 2 13 14 25 26]);
p_left = plotSurfaceROIBoundary(Rsurf,ubrain_parc,ubrain_parc,'faces',ubrain_cmap,1,[0.5 29.5]);
camlight(80,-10);
camlight(-80,-10);
view([-90 0])
axis off
axis image
TR = subplot(12,12,[1 2 13 14 25 26]+2);
p_left = plotSurfaceROIBoundary(Rsurf,ubrain_parc,ubrain_parc,'faces',ubrain_cmap,1,[0.5 29.5]);
camlight(80,-10);
camlight(-80,-10);
view([90 0])
axis off
axis image


BL = subplot(12,12,[1 2 13 14 25 26]+36);
p_left = plotSurfaceROIBoundary(Rsurf,RParcID,ubrain_parc,'faces',ubrain_cmap,1,[0.5 29.5]);
camlight(80,-10);
camlight(-80,-10);
view([-90 0])
axis off
axis image
BR = subplot(12,12,[1 2 13 14 25 26]+38);
p_left = plotSurfaceROIBoundary(Rsurf,RParcID,ubrain_parc,'faces',ubrain_cmap,1,[0.5 29.5]);
camlight(80,-10);
camlight(-80,-10);
view([90 0])
axis off
axis image

pos = get(TL,'Position');
TL.Position(1) = pos(1)-.015;
pos = get(TR,'Position');
TR.Position(1) = pos(1)-.015;
pos = get(BL,'Position');
BL.Position(1) = pos(1)-.015;
pos = get(BR,'Position');
BR.Position(1) = pos(1)-.015;

%%
matPlot = subplot(12,12,[5:8 17:20 29:32 41:44 53:56 65:68]);

roi_ubrain_id = [parc_orig_ind; parc_orig_indR];

topcluster = map_values_to_colormap(roi_ubrain_id', ubrain_cmap,[1 29],1);
sidecluster = map_values_to_colormap(roi_ubrain_id, ubrain_cmap,[1 29],1);

GrpAvgLog = log(GrpAvg);
valsU = triu2vec(GrpAvgLog);
valsUExist = valsU(~isinf(valsU));
vals_log_range = [log(1) max(valsUExist)];

connCmap = make_alpha_cmap([0.6350 0.0780 0.1840],1024);
%connCmap2 = heat(1024);
connMat = map_values_to_colormap(GrpAvgLog, connCmap,vals_log_range);

CLuRowSz = round(N/15);
CLuRowSz1 = CLuRowSz+1;

fullMat = ones(N+CLuRowSz,N+CLuRowSz,3);

fullMat(1:CLuRowSz,CLuRowSz1:end,:) = repmat(topcluster,[CLuRowSz,1,1]);
fullMat(CLuRowSz1:end,1:CLuRowSz,:) = repmat(sidecluster,[1,CLuRowSz,1]);
fullMat(CLuRowSz1:end,CLuRowSz1:end,:) = connMat;

imagesc(fullMat)

pos = get(matPlot,'Position');
matPlot.Position(1) = pos(1)-.005; 

colormap(connCmap)
c = colorbar;
c.Label.String = 'Connectivity strength';  
c.FontSize = 14;
set(gca,'ColorScale','log')
clim([1 max(GrpAvg(:))])

axis off

rectangle('Position',[CLuRowSz+.5 CLuRowSz+.5 N N])


%%
% if skip == 0
% [PhiTrue, PhiRand] = rich_club_analysis_normalized(A,10);
% end
% PhiNorm = PhiTrue./nanmean(PhiRand);

fontSize = 12;

load(['RC_uBrain',num2str(V),'_thr_',num2str(thr),'.mat'],'PhiNorm','PhiTrue','PhiRand')

RFLcmap = [227 26 28; ...
            254 196 79; ...
            54 144 192]./255;

subplot(12,12,[9:12 21:24])

histogram(deg, 'BinMethod', 'integers', 'FaceColor', 'k');
   % xlabel('Degree');
    ylabel('Frequency')
    title('Degree Distribution');
    %grid on;
    xlim([0 max(deg)])
ylimits = ylim;
hold on
plot([threshold threshold],ylimits,'--','Color','k')
ylim(ylimits)

set(gca,'Fontsize',fontSize)

pos = get(gca,'Position');
ax = gca;
ax.Position(1) = pos(1)+.05;
ax.Position(3) = pos(3)-.02;
ax.Position(2) = pos(2)+.01;

ax.XRuler.TickLabelGapOffset = -3;

subplot(12,12,[9:12 21:24]+24)

hold on
p1 = plot(1:length(PhiTrue),nanmean(PhiRand),'-','Color',[.5 .5 .5],'LineWidth', 2.5);
p2 = plot(1:length(PhiTrue),PhiTrue,'-','Color','k','LineWidth', 2.5);
%xlabel('Node degree (k)')
ylabel({'Rich-club','coeffecient'}) % left y-axis
xlim([0 max(deg)])
ylimits = ylim;
plot([threshold threshold],ylimits,'--','Color','k')
ylim(ylimits)

set(gca,'Fontsize',fontSize)
box on
pos = get(gca,'Position');
ax = gca;
ax.Position(1) = pos(1)+.05;
ax.Position(3) = pos(3)-.02;
ax.Position(2) = pos(2)+.01;

ax.XRuler.TickLabelGapOffset = -3;
subplot(12,12,[9:12 21:24]+48)

p3 = plot(1:length(PhiTrue),PhiNorm,'Color',RFLcmap(1,:),'LineWidth', 2.5);
xlim([0 max(deg)])
ylabel({'Normalised','rich-club'}) % right y-axis
xlabel('Node degree (k)')
ylimits = ylim;
hold on
plot([threshold threshold],ylimits,'--','Color','k')
ylim(ylimits)
pos = get(gca,'Position');

set(gca,'Fontsize',fontSize)

ax = gca;
ax.Position(1) = pos(1)+.05;
ax.Position(3) = pos(3)-.02;
ax.Position(2) = pos(2)+.01;

ax.XRuler.TickLabelGapOffset = -3;
%%

richNodes = deg > threshold; % Define rich nodes based on threshold

% Identify connection types
richEdges = A .* (richNodes * richNodes'); % Rich-rich connections
localEdges = A .* (~richNodes * ~richNodes'); % Local-local connections
feederEdges = A .* ((richNodes * ~richNodes') | (~richNodes * richNodes')); % Feeder connections

richEdges_vec = triu2vec(richEdges);
localEdges_vec = triu2vec(localEdges);
feederEdges_vec = triu2vec(feederEdges);

RFLcmap = [227 26 28; ...
            254 196 79; ...
            54 144 192]./255;


d_range = [0 max(Dvec)];

subplot(12,12,[73:76 85:88])

histogram(Dvec(richEdges_vec==1),'BinMethod', 'integers','FaceColor',RFLcmap(1,:))
    %xlabel('Edge length');
    ylabel('Frequency');
    xlim(d_range)

    ylimits = ylim;
    new_ylimits = [0 ylimits(2)*1.2];
    text(5,ylimits(2)*1.1,'Rich','FontSize',16,'Color',RFLcmap(1,:),'FontWeight','bold')
    ylim(new_ylimits)
set(gca,'Fontsize',fontSize)


ax = gca;
ax.XRuler.TickLabelGapOffset = -3;

subplot(12,12,[73:76 85:88]+24)
histogram(Dvec(feederEdges_vec==1),'BinMethod', 'integers','FaceColor',RFLcmap(2,:))
%xlabel('Edge length');
ylabel('Frequency');
xlim(d_range)

   ylimits = ylim;
    new_ylimits = [0 ylimits(2)*1.2];
    text(5,ylimits(2)*1.1,'Feeder','FontSize',16,'Color',RFLcmap(2,:),'FontWeight','bold')
    ylim(new_ylimits)
set(gca,'Fontsize',fontSize)

ax = gca;
ax.XRuler.TickLabelGapOffset = -3;

subplot(12,12,[73:76 85:88]+48)
histogram(Dvec(localEdges_vec==1),'BinMethod', 'integers','FaceColor',RFLcmap(3,:))
    xlabel('Edge length');
    ylabel('Frequency');
    xlim(d_range)

       ylimits = ylim;
    new_ylimits = [0 ylimits(2)*1.2];
    text(5,ylimits(2)*1.1,'Local','FontSize',16,'Color',RFLcmap(3,:),'FontWeight','bold')
    ylim(new_ylimits)
set(gca,'Fontsize',fontSize)

ax = gca;
ax.XRuler.TickLabelGapOffset = -3;

%%

degThr_cmap = [.5 .5 .5; [255,255,178;...
254,204,92;...
253,141,60;...
227,26,28]./255 ];

degThr = double(richNodes);
degThrLeft = degThr(1:(N/2));
degThrRight = degThr((N/2)+1:N);

subplot(12,12,[77 78 89 90 101 102])

p_left = plotSurfaceROIBoundary(Lsurf,LParcID,degThrLeft,'faces',[.5 .5 .5; degThr_cmap(5,:)],1,[-0.5 1.5]);
camlight(80,-10);
camlight(-80,-10);
view([-90 0])
axis off
axis image

subplot(12,12,[77 78 89 90 101 102]+2)

p_left = plotSurfaceROIBoundary(Lsurf,LParcID,degThrLeft,'faces',[.5 .5 .5; degThr_cmap(5,:)],1,[-0.5 1.5]);
camlight(80,-10);
camlight(-80,-10);
view([90 0])
axis off
axis image

subplot(12,12,[77 78 89 90 101 102]+(3*12))

p_left = plotSurfaceROIBoundary(Rsurf,RParcID,degThrRight,'faces',[.5 .5 .5; degThr_cmap(5,:)],1,[-0.5 1.5]);
camlight(80,-10);
camlight(-80,-10);
view([-90 0])
axis off
axis image

pos = get(gca,'Position');
ax = gca;
ax.Position(2) = pos(2)+.03;

subplot(12,12,[77 78 89 90 101 102]+(3*12)+2)


p_left = plotSurfaceROIBoundary(Rsurf,RParcID,degThrRight,'faces',[.5 .5 .5; degThr_cmap(5,:)],1,[-0.5 1.5]);
camlight(80,-10);
camlight(-80,-10);
view([90 0])
axis off
axis image

pos = get(gca,'Position');
ax = gca;
ax.Position(2) = pos(2)+.03;

%%

Hubness_cmap = [255,255,204;...
255,237,160;...
254,217,118;...
254,178,76;...
253,141,60;...
252,78,42;...
227,26,28;...
189,0,38;...
128,0,38]./255;


hubness_thr = .1;

nColors = 256;
hub_cmap = interp1(linspace(0,1,size(Hubness_cmap,1)), Hubness_cmap, linspace(0,1,nColors), 'linear');

lines_cmap = lines(7);
Hubness_cmap = [.5 .5 .5; lines_cmap(7,:)];

isHub = double(richNodes);

parcs_ubrain{1} = ubrain_parc;

hubness = zeros(29*2,0);

for i = 1:29
    
    Rinds = find(parc_orig_indR==i)+(N/2);
    
    hubness(i) = mean(isHub(parc_orig_ind==i));
    hubness(i+29) = mean(isHub(Rinds));

end


camp_values_mapped = linspace(0,1,nColors);
colorThrRange = [1 find(camp_values_mapped<hubness_thr)];

hub_cmap(colorThrRange,:) = repmat([.5 .5 .5],[length(colorThrRange) 1]);

hubness_colormapped = map_values_to_colormap(hubness,hub_cmap,[0 1]);

isHub = hubness==0 | hubness<hubness_thr;
NnonHub = sum(isHub);

hubness_colormapped(isHub,:) = repmat([.5 .5 .5],[NnonHub 1]);

TopL = subplot(12,12,[81 82 93 94 105 106]);

p_left = plotSurfaceROIBoundary(Lsurf,ubrain_parc,hubness_colormapped,'faces',hub_cmap,1,[0 1]);
camlight(80,-10);
camlight(-80,-10);
view([-90 0])
axis off
axis image

TopR = subplot(12,12,[81 82 93 94 105 106]+2);

p_left = plotSurfaceROIBoundary(Lsurf,ubrain_parc,hubness_colormapped,'faces',hub_cmap,1,[0 1]);
camlight(80,-10);
camlight(-80,-10);
view([90 0])
axis off
axis image

BotL = subplot(12,12,[81 82 93 94 105 106]+(3*12));

p_left = plotSurfaceROIBoundary(Rsurf,ubrain_parc,hubness_colormapped,'faces',hub_cmap,1,[0 1]);
camlight(80,-10);
camlight(-80,-10);
view([-90 0])
axis off
axis image


BotR = subplot(12,12,[81 82 93 94 105 106]+(3*12)+2);

p_left = plotSurfaceROIBoundary(Rsurf,ubrain_parc,hubness_colormapped,'faces',hub_cmap,1,[0 1]);
camlight(80,-10);
camlight(-80,-10);
view([90 0])
axis off
axis image


pos = get(TopR,'Position');
TopR.Position(1) = pos(1)+.03;

pos = get(TopL,'Position');
TopL.Position(1) = pos(1)+.03;

pos = get(BotL,'Position');
BotL.Position(1) = pos(1)+.03;
BotL.Position(2) = pos(2)+.03;

pos = get(BotR,'Position');
BotR.Position(1) = pos(1)+.03;
BotR.Position(2) = pos(2)+.03;

pos1 = get(BotL,'Position');
pos2 = get(BotR,'Position');
colormap(BotR,hub_cmap)
c = colorbar(BotR,'Location','southoutside','FontSize',16);
c.Label.String = 'Hubness';
c.Position = [pos1(1) .1  (pos2(1)+pos2(3))-pos1(1) .0265]; 

%%
annotation(gcf,'textbox',...
    [0.0950393518518519 0.9010706638116 0.0207013888888889 0.0342612419700213],...
    'String',{'A'},...
    'FitBoxToText','off','FontSize',24,'EdgeColor','none');


annotation(gcf,'textbox',...
    [0.36 0.9010706638116 0.0207013888888889 0.0342612419700213],...
    'String',{'B'},...
    'FitBoxToText','off','FontSize',24,'EdgeColor','none');


annotation(gcf,'textbox',...
    [0.66 0.9010706638116 0.0207013888888889 0.0342612419700213],...
    'String',{'C'},...
    'FitBoxToText','off','FontSize',24,'EdgeColor','none');

annotation(gcf,'textbox',...
    [0.0950393518518519 0.5010706638116 0.0207013888888889 0.0342612419700213],...
    'String',{'D'},...
    'FitBoxToText','off','FontSize',24,'EdgeColor','none');


annotation(gcf,'textbox',...
    [0.38 0.48 0.0207013888888889 0.0342612419700213],...
    'String',{'E'},...
    'FitBoxToText','off','FontSize',24,'EdgeColor','none');

annotation(gcf,'textbox',...
    [0.68 0.48 0.0207013888888889 0.0342612419700213],...
    'String',{'F'},...
    'FitBoxToText','off','FontSize',24,'EdgeColor','none');

%exportgraphics(gcf,['Subdiv',num2str(V),'_thr_',num2str(thr),'.png'],'Resolution',300)
%exportgraphics(gcf,['Subdiv',num2str(V),'_thr_',num2str(thr),'.pdf'],'ContentType','vector')