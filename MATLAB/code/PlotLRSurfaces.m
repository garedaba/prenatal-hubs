function PlotLRSurfaces(surfaces,vertex_id,data,cmap,data_label,climits,BoundaryType)

% This is just a example for how to plot the medial and lateral sides of a
% surface in the same plot

% Inputs:
%
% surface = a structure with two fields: vertices (the vertices making up 
% the surface) and faces (the faces of the surface)
%
% vertex_id = the roi id of each vertex
%
% data = either data for each individual roi or data for each vertex.
% If you don't want any data to be displayed for a roi or vertex, set that
% value to NaN. Note that this assumes a roi with a vertex_id has no data
% to plot. Additionally, if the vertex_ids are non sequential (e.g., like
% what you get from an .annot file) then data can take the form of a ROI*2
% matrix, where ROI is the number of regions, each row is a particular 
% region with the first column being the data to plot and the second being
% the region ID (should correspond to what is in vertex_id)
%
% cmap = an N*3 matrix specifying the RGB values making up the colormap to
% use
%
% data_label = (optional) the name of the data being plotted
%
% Output
%
% p_left = patch object for the surface plotted on the left
%
% p_right = patch object for the surface plotted on the right
%
% c = colorbar object

if min(size(data)) == 1
    if size(data,2) > size(data,1)
        data = data';
    end
end

if nargin < 6 
    if iscell(data)
       climits = [nanmin(nanmin(data{1}),nanmin(data{2})) nanmax(nanmax(data{1}),nanmax(data{2}))];
    else
    climits = [nanmin(data) nanmax(data)];
    end
end

if nargin < 7
    BoundaryType = 'midpoint';
end

LH_parc = unique(vertex_id{1}(vertex_id{1}~=0));
RH_parc = unique(vertex_id{2}(vertex_id{2}~=0));

H_inds{1} = 1:length(LH_parc);
H_inds{2} = (1:length(RH_parc))+length(LH_parc);

xpos_start = [3/5 1/5];

figure('Position',[0   0   560   580])

for i = 1:2

    if i == 1
surface.faces = surfaces.lh_faces;
surface.vertices = surfaces.lh_vertices;
    elseif i == 2
surface.faces = surfaces.rh_faces;
surface.vertices = surfaces.rh_vertices;
    end
    if iscell(data)
    data2plot = data{i};
    else
    data2plot = data(H_inds{i},:);
    end


ax_sub1 = axes('Position',[0.005 xpos_start(i) .49 2/5]);
p_left = plotSurfaceROIBoundary(surface,vertex_id{i},data2plot,BoundaryType,cmap,1,climits);
camlight(80,-10);
camlight(-80,-10);
view([-90 0])

axis off
axis image

ax_sub2 = axes('Position',[.505 xpos_start(i) .489 2/5]);
p_right = plotSurfaceROIBoundary(surface,vertex_id{i},data2plot,BoundaryType,cmap,1,climits);
camlight(80,-10);
camlight(-80,-10);
view([90 0])
axis off
axis image

end

colormap(cmap)
if climits(1)~=climits(2)
caxis(climits);
end
c = colorbar('Location','southoutside');
%set(c, 'xlim', [nanmin(data) nanmax(data)],'Position',[.1 .23 .8 .05],'FontSize',20);
set(c, 'Position',[.1 .146 .8 .05],'FontSize',20);
if exist('data_label','var')
    c.Label.String = data_label;
end

Llabel = annotation('textbox',[.45 .8 .1 .2],'String','Left','HorizontalAlignment','center','FontSize',20,'EdgeColor','none');

Rlabel = annotation('textbox',[.45 .4 .1 .2],'String','Right','HorizontalAlignment','center','FontSize',20,'EdgeColor','none');
