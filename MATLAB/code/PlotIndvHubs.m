
V = 90;
thr = 0.15;

load(['IndvHubResult_uBrain',num2str(V),'_thr_',num2str(thr),'.mat'],'isHub')

load(['GrpAvg_uBrain',num2str(V),'_thr_',num2str(thr),'.mat'],'GrpAvg')

A = GrpAvg>0;


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

surfaces.lh_vertices = Lsurf.vertices;
surfaces.lh_faces = Lsurf.faces;
surfaces.rh_vertices = Rsurf.vertices;
surfaces.rh_faces = Rsurf.faces;

vertex_id{1} = LParcID;
vertex_id{2} = LParcID;

Hubness_cmap = [255,255,204;...
255,237,160;...
254,217,118;...
254,178,76;...
253,141,60;...
252,78,42;...
227,26,28;...
189,0,38;...
128,0,38]./255;

% To make the plot easier to read, set any region with a hubness of less
% than 10% (i.e., was identified as a hub in less than 10% of participants)
% to 0
hubness_thr = .1;

nColors = 256;
hub_cmap = interp1(linspace(0,1,size(Hubness_cmap,1)), Hubness_cmap, linspace(0,1,nColors), 'linear');

hubness = mean(isHub);

camp_values_mapped = linspace(0,1,nColors);
colorThrRange = [1 find(camp_values_mapped<hubness_thr)];
hub_cmap(colorThrRange,:) = repmat([.5 .5 .5],[length(colorThrRange) 1]);
hubness_colormapped = map_values_to_colormap(hubness,hub_cmap,[0 1]);
isNotHub = hubness==0 | hubness<hubness_thr;
NnonHub = sum(isNotHub);
hubness_colormapped(isNotHub,:) = repmat([.5 .5 .5],[NnonHub 1]);

PlotLRSurfaces(surfaces,vertex_id,hubness_colormapped,hub_cmap,'Hubness across individuals',[0 1],'faces')

exportgraphics(gcf,['./figures/IndvHubs.png'],'Resolution',300)

figure('Position',[0    0    668    540])
grpDeg = sum(A);
grbHub = double(grpDeg >prctile(grpDeg, 90));
scatter(grpDeg,hubness,100,grbHub,'filled','MarkerEdgeColor','k','LineWidth',2)
colormap([.5 .5 .5; 128/255,0,38/255])
xlabel('Group averaged degree')
ylabel('Hubness across individuals')
set(gca,'Fontsize',20)
exportgraphics(gcf,['./figures/IndvHubsVsGrpHubs.png'],'Resolution',300)
