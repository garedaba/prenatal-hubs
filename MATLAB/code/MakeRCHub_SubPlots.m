function MakeRCHub_SubPlots(V,thr,saveloc)

if nargin < 3
    saveloc = './figures';
end

load(['GrpAvg_uBrain',num2str(V),'_thr_',num2str(thr),'.mat'],'D','GrpAvg')

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

%%

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

%%

fontSize = 12;

load(['RC_uBrain',num2str(V),'_thr_',num2str(thr),'.mat'],'PhiNorm','PhiTrue','PhiRand')

figure('Position',[10 10 573 462])

RFLcmap = [227 26 28; ...
            254 196 79; ...
            54 144 192]./255;

subplot(3,1,1)

histogram(deg, 'BinMethod', 'integers', 'FaceColor', 'k');
    %xlabel('Degree');
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
ax.Position(1) = pos(1)+.03;
ax.Position(2) = pos(2)+.01;

subplot(3,1,2)

hold on
p1 = plot(1:length(PhiTrue),nanmean(PhiRand),'-','Color',[.5 .5 .5],'LineWidth', 2.5);
p2 = plot(1:length(PhiTrue),PhiTrue,'-','Color','k','LineWidth', 2.5);
%xlabel('Node degree (k)')
ylabel('RC coeffecient') % left y-axis
xlim([0 max(deg)])
ylimits = ylim;
plot([threshold threshold],ylimits,'--','Color','k')
ylim(ylimits)
box on
set(gca,'Fontsize',fontSize)

pos = get(gca,'Position');
ax = gca;
ax.Position(1) = pos(1)+.03;
ax.Position(2) = pos(2)+.01;

subplot(3,1,3)

p3 = plot(1:length(PhiTrue),PhiNorm,'Color',RFLcmap(1,:),'LineWidth', 2.5);
xlim([0 max(deg)])
ylabel('Normalised RC') % right y-axis
xlabel('Node degree (k)')
ylimits = ylim;
hold on
plot([threshold threshold],ylimits,'--','Color','k')
ylim(ylimits)
pos = get(gca,'Position');

set(gca,'Fontsize',fontSize)

ax = gca;
ax.Position(1) = pos(1)+.03;
ax.Position(2) = pos(2)+.01;

exportgraphics(gcf,[saveloc,'/RC_uBrian',num2str(V),'_thr_',num2str(thr),'.png'],'Resolution',300)
%%

figure('Position',[10 10 573 462])

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

colormap(connCmap)
c = colorbar;
c.Label.String = 'Connectivity strength';  
c.FontSize = 14;
set(gca,'ColorScale','log')
clim([1 max(GrpAvg(:))])

axis off
axis square

rectangle('Position',[CLuRowSz+.5 CLuRowSz+.5 N N])

title(['Connectivity matrix (',num2str(thr*100),'% density)'])
set(gca,'Fontsize',14)

exportgraphics(gcf,[saveloc,'/ConnMat_uBrian',num2str(V),'_thr_',num2str(thr),'.png'],'Resolution',300)

%%

richNodes = deg > threshold;

degThr = double(richNodes);
degThrLeft = degThr(1:(N/2));
degThrRight = degThr((N/2)+1:N);

degLeftRight = degThrLeft + (degThrRight*2);

lines_cmap = lines(7);

cmap_LR = [lines_cmap(1,:);lines_cmap(7,:);lines_cmap(4,:)];

degLeftRight(degLeftRight==0)=NaN;

[~,~,cbar] = ExampleSurfacePlotFunction(Lsurf,LParcID,degLeftRight,cmap_LR,'',[.5 3.5]);
cbar.TickLabels = {'Left','Right','Both'};
cbar.Ticks = [1 2 3];

%exportgraphics(gcf,['HubLoc_uBrian',num2str(V),'_thr_',num2str(thr),'.png'],'Resolution',300)
print([saveloc,'/HubLoc_uBrian',num2str(V),'_thr_',num2str(thr),'.png'],'-dpng','-r300')

close all


