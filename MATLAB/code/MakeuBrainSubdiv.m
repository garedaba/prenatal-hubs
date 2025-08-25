%% JFC lets fix this parcellation

L = gifti('week-40_hemi-left_space-dhcpSym_dens-32k_vinflated.surf.gii');
Lsurf.vertices = double(L.vertices);
Lsurf.faces = double(L.faces);

ubrain = gifti('dHCP.week36.R.ubrain.label.gii');
ubrainparc_id = ubrain.labels.key;
ubrain_cmap = ubrain.labels.rgba(2:30,1:3);  
ubrainparc = double(ubrain.cdata);

L = gifti('week-40_hemi-left_space-dhcpSym_dens-32k_sphere.surf.gii');
vertices_sphere = double(L.vertices);
faces = double(L.faces);

% Find ROIs which are discontinuous

[ubrainparc_continuous,ubrainparc_continuous_roi_newold] = findContROI(ubrainparc,faces);

Lwm = gifti('week-40_hemi-left_space-dhcpSym_dens-32k_wm.surf.gii');
vertices_wm = double(Lwm.vertices);

DesiredVertSize = [60 90 120];
for Psize = 1:3

DesiredSize = DesiredVertSize(Psize);
new_parc = zeros(size(ubrainparc_continuous));
for i = 1:size(ubrainparc_continuous_roi_newold,1)
    %ignore_verts = find(ubrainparc_continuous~=i);
    in_roi = find(ubrainparc_continuous==i);
    if length(in_roi) > DesiredSize/2
        data2cluster = vertices_sphere(in_roi,:);
        parc_temp = get_even_clusters(data2cluster, DesiredSize)+1;
        current_maxroi = max(new_parc);
        new_parc(in_roi) = parc_temp+current_maxroi;
    end
end

[new_parc_continuous,roi_newold] = findContROI(new_parc,faces);

nparc = max(new_parc_continuous);

parc_nverts = zeros(nparc,1);

for i = 1:nparc
    parc_nverts(i) = length(find(new_parc_continuous==i));
end

vert2fix = find(ismember(new_parc_continuous,find(parc_nverts< (DesiredSize/3)) ));

parc_verts = reassignParcIDs(new_parc_continuous,faces,vert2fix,ubrainparc_continuous);

%ExampleSurfacePlotFunction(Lsurf,parc_verts,ubrainparc,ubrain_cmap,'Parcellation',[0.5 29.5],'midpoint');

ubrain_subdiv{Psize} = parc_verts;

end

for i = 1:3
    dlmwrite(['uBrain',num2str(DesiredVertSize(i)),'verts.txt'],ubrain_subdiv{i})
end

%% Make .annot file

% ct is a struct
% ct.numEntries = number of Entries
% ct.orig_tab = name of original ct
% ct.struct_names = list of structure names (e.g. central sulcus and so on)
% ct.table = n x 5 matrix. 1st column is r, 2nd column is g, 3rd column
% is b, 4th column is transparency (1 - alpha), 5th column is resultant integer
% values calculated from r + g*2^8 + b*2^16.
DesiredVertSize = [60 90 120];
for i = 1:3
    parc_data = dlmread(['uBrain',num2str(DesiredVertSize(i)),'verts.txt']);
    nparc = max(parc_data);
ct.numEntries = nparc+1;
ct.orig_tab = '';
struct_names = cell(ct.numEntries,1);
struct_names{1} = 'unknown';
for j = 1:nparc
    struct_names{j+1} = ['L_',num2str(j)];
end
ct.struct_names = struct_names;
RGB = make_unique_RGB(ct.numEntries);
RGB(1,:) = [0 0 0];
index = RGB(:,1)+RGB(:,2)*2^8+RGB(:,3)*2^16;
ct.table = [RGB zeros(nparc+1,1) index];
label = my_changem(parc_data,index,0:nparc);
label(parc_data==0)=0;
vertices = 0:length(label)-1;
write_annotation(['lh.uBrain',num2str(DesiredVertSize(i)),'verts.annot'], vertices', label, ct)
for j = 1:nparc
    struct_names{j+1} = ['R_',num2str(j)];
end
ct.struct_names = struct_names;
write_annotation(['rh.uBrain',num2str(DesiredVertSize(i)),'verts.annot'], vertices', label, ct)
end
